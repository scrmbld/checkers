local Set = require("set")
local Coords = require("coords")
local Move = require("move")
local Timer = require("timer")

---Get the midpoint between the two coordinates.
local function getMidpoint(m)
	local half_magnitude = m.magnitude / 2
	return m.start + m.direction * half_magnitude
end

---Returns the number of items in a table
---@param T table
---@return number
local function tableSize(T)
	local count = 0
	for _ in pairs(T) do
		count = count + 1
	end
	return count
end

-- this is our export
local Board = {
	name = "Board"
}

function Board:new(x, y, turn)
	if turn == nil then
		turn = 1
	end

	local newObj = {
		turn = turn,
		x = x,
		y = y,
		sp_background = love.graphics.newImage("images/checkerboard.png"),
		selected = nil,

		state = {
			{ 1, 0, 1, 0, 1, 0, 1, 0 },
			{ 0, 1, 0, 1, 0, 1, 0, 1 },
			{ 0, 0, 0, 0, 0, 0, 0, 0 },
			{ 0, 0, 0, 0, 0, 0, 0, 0 },
			{ 0, 0, 0, 0, 0, 0, 0, 0 },
			{ 0, 0, 0, 0, 0, 0, 0, 0 },
			{ 3, 0, 3, 0, 3, 0, 3, 0 },
			{ 0, 3, 0, 3, 0, 3, 0, 3 },
		},

		p1_remaining = 8,
		p2_remaining = 8,
		p1_taken = 0,
		p2_taken = 0,

		player_directions = { 1, -1 },
		move_count = 0,

		active = false
	}

	newObj.width = newObj.sp_background:getWidth()
	newObj.height = newObj.sp_background:getHeight()

	newObj.cell_h = math.floor(newObj.height / #newObj.state)
	newObj.cell_w = math.floor(newObj.width / #newObj.state[1])

	newObj.game_timer = Timer:new(newObj.x + newObj.width + 20, 20, 600, 0)

	-- TODO: add assets for kings
	newObj.piece_sprites = {
		[1] = love.graphics.newImage("images/red_checker.png"),
		[2] = love.graphics.newImage("images/red_king.png"),
		[3] = love.graphics.newImage("images/blue_checker.png"),
		[4] = love.graphics.newImage("images/blue_king.png"),
	}

	newObj.guides = {
		["pawn_selected"] = love.graphics.newImage("images/pawn_selected.png"),
		["king_selected"] = love.graphics.newImage("images/king_selected.png"),
		["dest"] = love.graphics.newImage("images/destination.png"),
	}

	-- a list of sets of legal moves
	-- each set contains all of the legal moves for one player
	newObj.legal_moves = {}

	-- which `Board.state` cell values are movable pieces
	newObj.movable = Set:new({ 1, 2, 3, 4 })

	self.__index = self

	setmetatable(newObj, self)

	return newObj
end

function Board:update(delta)
	local flag = self.game_timer:update(delta)
	if flag == true then
		if self.turn == 1 then
			print("Blue wins")
			GameOver("Blue wins!")
		else
			print("Red wins")
			GameOver("Red wins!")
		end
	end
end

function Board:draw()
	-- first, draw the board
	love.graphics.draw(self.sp_background, self.x, self.y)
	-- then, draw the pieces
	for i, row in ipairs(self.state) do
		for j, col in ipairs(self.state) do
			-- get the sprite for the current position
			local sp = self.piece_sprites[self.state[i][j]]
			-- compute the current position
			local x = self.cell_w * (j - 1) + self.x
			local y = self.cell_h * (i - 1) + self.y

			-- draw the piece
			if sp then
				love.graphics.draw(sp, x, y)
			end
		end
	end

	-- next, draw the timer
	self.game_timer:draw()

	-- finally, movement guides
	if self.selected then
		self:renderGuides()
	end
end

function Board:renderGuides()
	-- draw the selection highlight
	local x = self.x + self.cell_w * (self.selected.x - 1)
	local y = self.y + self.cell_h * (self.selected.y - 1)

	local cell = self.state[self.selected.y][self.selected.x]

	if cell == 1 or cell == 3 then
		love.graphics.draw(self.guides.pawn_selected, x, y, 0)
	elseif cell == 2 or cell == 4 then
		love.graphics.draw(self.guides.king_selected, x, y, 0)
	end

	-- draw the available moves for the selected piece
	if self.legal_moves == nil or self.selected == nil then
		return
	end
	-- 1. search through all the legal moves for ones where start == selected
	-- get the cell value to determine which move set we should search
	local selected_cell = self.state[self.selected.y][self.selected.x]
	-- figure out which player's move list we should search
	local player_id = 0
	if selected_cell == 1 or selected_cell == 2 then
		player_id = 1
	elseif selected_cell ~= 0 then
		player_id = 2
	end
	assert(player_id == 1 or player_id == 2)

	-- do the search
	local destinations = {}
	for i, v in pairs(self.legal_moves[player_id]) do
		if i == "jump" then
			goto continue
		end
		if v.start == self.selected then
			table.insert(destinations, v.final)
		end
		::continue::
	end

	-- 2. draw the 'dest' thingy at every final coordinate in all the moves fulfilling condition 1
	for _, v in ipairs(destinations) do
		local x = self.x + self.cell_w * (v.x - 1)
		local y = self.y + self.cell_w * (v.y - 1)
		love.graphics.draw(self.guides.dest, x, y)
	end
end

function Board:select(coord)
	if self.selected then
		-- if we click on the same one twice, then just deselect
		if self.selected.x == coord.x and self.selected.y == coord.y then
			self.selected = nil
		end
		-- if we click on an unselected, movable cell, that belongs to the player who is currently player their turn, then select
	elseif self.movable[self.state[coord.y][coord.x]] and self:isTurn(coord) then
		self.selected = coord
	else
		self.selcted = nil
	end
end

---returns true if the two cell values are on the same team, false otherwise
function Board:isFriend(coord_1, coord_2)
	local cell_1 = self.state[coord_1.y][coord_1.x]
	local cell_2 = self.state[coord_2.y][coord_2.x]
	-- bounds checking
	if coord_1.x < 1 or coord_1.y < 1 or coord_1.y > #self.state or coord_1.x > #self.state[1] then
		return false
	end
	if coord_2.x < 1 or coord_2.y < 1 or coord_2.y > #self.state or coord_2.x > #self.state[1] then
		return false
	end

	if (cell_1 == 1 or cell_1 == 2) and (cell_2 == 1 or cell_2 == 2) then
		return true
	end

	if (cell_2 == 3 or cell_2 == 4) and (cell_1 == 3 or cell_1 == 4) then
		return true
	end

	return false
end

---returns true if the two cell values are on opposing teams, false otherwise
function Board:isEnemy(coord_1, coord_2)
	if not self.state then
		return false
	end
	-- bounds checking
	if coord_1.x < 1 or coord_1.y < 1 or coord_1.y > #self.state or coord_1.x > #self.state[1] then
		return false
	end
	if coord_2.x < 1 or coord_2.y < 1 or coord_2.y > #self.state or coord_2.x > #self.state[1] then
		return false
	end

	local cell_1 = self.state[coord_1.y][coord_1.x]
	local cell_2 = self.state[coord_2.y][coord_2.x]

	if cell_1 == 0 or cell_2 == 0 then
		return false
	end

	if (cell_1 == 1 or cell_1 == 2) and (cell_2 == 1 or cell_2 == 2) then
		return false
	end

	if (cell_2 == 3 or cell_2 == 4) and (cell_1 == 3 or cell_1 == 4) then
		return false
	end

	return true
end

---returns true if the piece at a given coordinate belongs to the player whose turn it is, and false otherwise
function Board:isTurn(coord)
	-- bounds checking
	if coord.x < 1 or coord.y < 1 or coord.y > #self.state or coord.x > #self.state[1] then
		return false
	end

	local cell = self.state[coord.y][coord.x]
	if cell == 0 then
		return false
	end
	if self.turn == 1 and (cell == 1 or cell == 2) then
		return true
	end
	if self.turn == 2 and (cell == 3 or cell == 4) then
		return true
	end

	return false
end

---Checks if the provided Move is legal, neglecting the existence of a forcing move such as a jump.
---@return boolean
function Board:isPossible(m)
	-- check that the start square is not out of bounds
	if m.start.x < 1 or m.start.y < 1 or m.start.y > #self.state or m.start.x > #self.state[1] then
		return false
	end
	-- check that the target square is not out of bounds
	if m.final.x < 1 or m.final.y < 1 or m.final.y > #self.state or m.final.x > #self.state[1] then
		return false
	end
	--
	--check that start cell is movable
	local start_cell = self.state[m.start.y][m.start.x]

	if not self.movable[start_cell] then
		return false
	end

	-- check that the target square is not obstructed
	if self.state[m.final.y][m.final.x] ~= 0 then
		return false
	end

	-- check that the distance travelled is a diagonal with component lengths 1
	-- or that it is a valid jump
	if m.magnitude == 1 then
		return true
	elseif m.magnitude == 2 then
		-- it's ok to not use integer division because difference is always divisible by 2
		local middle = getMidpoint(m)

		return self:isEnemy(m.start, middle)
	end

	return false
end

---Finds all legal moves for all players on the board and places them in the Board.legal_moves
function Board:getLegalMoves()
	local p1_moves = {}
	local p2_moves = {}

	if self.multijump ~= nil then
		self:getMultiJumps(self.multijump)
		return
	end

	-- iterate over every square on the board and get all legal moves for the checker piece in that location
	for i, row in ipairs(self.state) do
		for j, cell in ipairs(row) do
			if self.movable[cell] then
				local cell_coords = Coords:new(j, i)
				local to_check = {}

				-- only check moves that are in an allowable direction (i.e., forward, unless the cell contains a king)
				if cell == 1 then
					-- red pawn
					table.insert(to_check, Coords:new(-1, self.player_directions[1]))
					table.insert(to_check, Coords:new(1, self.player_directions[1]))
				elseif cell == 3 then
					-- blue pawn
					table.insert(to_check, Coords:new(-1, self.player_directions[2]))
					table.insert(to_check, Coords:new(1, self.player_directions[2]))
				elseif cell == 2 or cell == 4 then
					-- king, either color
					to_check = {
						Coords:new(-1, 1),
						Coords:new(-1, -1),
						Coords:new(1, -1),
						Coords:new(1, 1),
					}
				end

				for _, v in ipairs(to_check) do
					local current_move = Move:new(cell_coords, cell_coords + v)

					-- if we would have to make a jump to move this direction, then check the jump instead
					if self:isEnemy(current_move.start, current_move.final) then
						current_move = Move:new(current_move.start,
							current_move.start + (current_move.direction + current_move.direction))
					end

					-- check that the current move is possible (i.e., in bounds, not blocked by another piece, etc.)
					if not self:isPossible(current_move) then
						goto continue
					end

					local is_jump = nil
					if current_move.magnitude == 2 then
						is_jump = true
					end

					-- append current move to a moves set
					-- if current move is not a jump and the moves set has a jump, don't append
					if cell == 1 or cell == 2 then
						if is_jump then
							if p1_moves['jump'] == nil then
								p1_moves = {}
							end
							p1_moves['jump'] = true
						end
						if is_jump or p1_moves['jump'] == nil then
							p1_moves[tostring(current_move)] = current_move
						end
					elseif cell == 3 or cell == 4 then
						if is_jump then
							if p2_moves['jump'] == nil then
								p2_moves = {}
							end
							p2_moves['jump'] = true
						end
						if is_jump or p2_moves['jump'] == nil then
							p2_moves[tostring(current_move)] = current_move
						end
					end

					::continue::
				end
			end
		end
	end

	self.legal_moves[1] = p1_moves
	self.legal_moves[2] = p2_moves
end

---Assuming that the piece at position c has just performed a jump, look for a legal multijump
---@param c table A Coords object containing the starting location of the piece to check for a multijump
---@return boolean # true if a jump is found, false otherwise
function Board:getMultiJumps(c)
	local moves = {}
	local cell = self.state[c.y][c.x]
	local to_check = {}

	local jump_found = false

	-- only check moves that are in an allowable direction (i.e., forward, unless the cell contains a king)
	if cell == 1 then
		-- red pawn
		table.insert(to_check, Coords:new(-2, self.player_directions[1] * 2))
		table.insert(to_check, Coords:new(2, self.player_directions[1] * 2))
	elseif cell == 3 then
		-- blue pawn
		table.insert(to_check, Coords:new(-2, self.player_directions[2] * 2))
		table.insert(to_check, Coords:new(2, self.player_directions[2] * 2))
	elseif cell == 2 or cell == 4 then
		-- king, either color
		to_check = {
			Coords:new(-2, 2),
			Coords:new(-2, -2),
			Coords:new(2, -2),
			Coords:new(2, 2),
		}
	end

	for _, v in ipairs(to_check) do
		local current_move = Move:new(c, c + v)

		-- check that the current move is possible (i.e., in bounds, not blocked by another piece, etc.)
		if not self:isPossible(current_move) then
			goto continue
		end

		jump_found = true
		moves[tostring(current_move)] = current_move
		moves['jump'] = true

		::continue::
	end

	self.legal_moves[self.turn] = moves

	return jump_found
end

---given a move, check if the move is a legal move and update the board state if it is
---@return boolean # Returns true if we moved successfully, false otherwise
function Board:move(m)
	-- if the clicked cell is in the list of legal moves, then move
	if self.legal_moves[self.turn][tostring(m)] ~= nil then
		-- move the selected piece to the m.final cell
		self.state[m.final.y][m.final.x] = self.state[m.start.y][m.start.x]
		self.state[m.start.y][m.start.x] = 0

		-- if the move is a jump, remove the piece we just jumped over
		if m.magnitude == 2 then
			local middle = getMidpoint(m)
			self.state[middle.y][middle.x] = 0
			-- check if the current piece has any more legal jumps
			if self:getMultiJumps(m.final) then
				self.multijump = m.final
				return true
			else
				self.multijump = nil
			end
		end

		self:getLegalMoves()

		local ended = self:nextTurn()

		self.move_count = self.move_count + 1

		if ended then
			return true
		end

		if tableSize(self.legal_moves[self.turn]) <= 0 then
			GameOver("Draw")
		end

		return true
	end

	-- we didn't move, don't update legal moves list
	return false
end

function Board:mousepressed(x, y, button)
	self:getLegalMoves()

	-- middle mouse does nothing
	if button == 3 then
		return
	end

	-- if they press right mouse, just deselect and return
	if button == 2 then
		self.selected = nil
		return
	end

	-- figure out what cell they clicked, if any
	local cell_x = math.floor(x / self.cell_w) + 1 -- array starts at 1
	local cell_y = math.floor(y / self.cell_h) + 1
	local clicked = Coords:new(cell_x, cell_y)

	-- decide if we should select or move
	if self.selected then
		local input_move = Move:new(self.selected, clicked)
		self:move(input_move)
		self.selected = nil
		return
	end

	-- if the user clicked on a valid cell
	if clicked.x >= 1 and clicked.x <= #self.state[1] and clicked.y >= 1 and clicked.y <= #self.state then
		-- update the state of the currently clicked cell
		local cell_state = self.state[clicked.y][clicked.x]

		self:select(clicked)

		-- if the user did not click on a valid cell (e.g., they clicked outside of the board)
	else
		self.selected = nil
	end
end

function Board:nextTurn()
	-- update turn
	if self.turn == 1 then
		self.turn = 2
	else
		self.turn = 1
	end


	-- deselect current piece
	self.selected = nil

	-- check for kings
	self:kingCheck()

	-- check if someone has won
	self:countRemaining()
	if self.p1_remaining <= 0 then
		print("Blue wins")
		GameOver("Blue wins!")
		return true
	elseif self.p2_remaining <= 0 then
		print("Red wins")
		GameOver("Red wins!")
		return true
	end

	-- update timer
	self.game_timer:start(self.turn)

	return false
end

---Checks if any non-kings are at the end of the board
function Board:kingCheck()
	local top = self.state[1]
	for i, v in ipairs(top) do
		if v == 3 then
			self.state[1][i] = 4
		end
	end

	local bottom = self.state[#self.state]
	for i, v in ipairs(bottom) do
		if v == 1 then
			self.state[#self.state][i] = 2
		end
	end
end

---computes the remaining pieces on the board for each player
function Board:countRemaining()
	local p1_pieces = Set:new({ 1, 2 })
	local p2_pieces = Set:new({ 3, 4 })
	local p1_count = 0
	local p2_count = 0
	for i, row in ipairs(self.state) do
		for j, cell in ipairs(row) do
			if p1_pieces[cell] == true then
				p1_count = p1_count + 1
			end
			if p2_pieces[cell] == true then
				p2_count = p2_count + 1
			end
		end
	end

	self.p1_taken = self.p1_taken + (self.p2_remaining - p2_count)
	self.p2_taken = self.p2_taken + (self.p1_remaining - p1_count)

	self.p1_remaining = p1_count
	self.p2_remaining = p2_count
end

return Board
