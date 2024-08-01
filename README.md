# Luau-Switch
A lightweight library to attempts to bring "switch" statements to Roblox.

# What is a "Switch" and why use it? 

A switch statement is similar to an `if` statement, but there are some key differences.
For one, the switch statement evaluates sequentally. Which means that each `case` will be evaluated even though the switches value has been matched.
This creates an opportunity where you can change the value of the switch in runtime and take advantage of multiple switch cases running.

# Examples

First off, we need to require the switch

```lua
local Switch = require(path.to.switch)
```

After that, use the `.new` constructor to create a new switch object.
And pass a value in it.

```lua
local mySwitch = Switch.new(value)
```

Almost all functions in the switch object are chainable, which means that you can attach methods to methods forever.
This makes it so that you don't have to make a new expression everytime you need to add a case to the switch.

```lua
mySwitch
  :Case(someValue, function(_break)
    -- does stuff if the switches value matches the given value.
  end)
```

The `_break` function is used to break out of the switch, which means that the rest of the cases won't be executed. Including the `default` case.

To activate the switch, simply call it:

```lua
local mySwitch = Switch.new()

mySwitch()
```

And finally, to add a default case, simply call `:Default(func)`. The provided callback will be executed if none of the cases are a match.
