-- Advanced switch statement
local Switch = require(game.ReplicatedStorage.Switch)

local myTable = {
    myValue = "Cool string!"
}

local switch = Switch.new(myTable.myValue)
	:Case("Cool string!", function()
		myTable.myValue = "Not-so-cool string :("
	end)
	:Case("Hello, world!", function()
		print("This will (not anymore) run!")
	end)
	:Default(function()
		print("This string is not cool :(")
	end)

switch() -- Output: "This string is not cool :("