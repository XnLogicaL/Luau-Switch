-- Basic switch statement
local Switch = require(game.ReplicatedStorage.Switch)

local myValue = "Hello, world!"

local switch = Switch.new(myValue)
    :Case("Yo", function()
        print("This won't run!")
    end)
    :Case("Hello, world!", function()
        print("This will run!")
    end)
    :Default(function()
        print("It was neither??")
    end)

switch() -- Output: "This will run!"
switch() -- Output: "Error: switch has already been evaluated!"