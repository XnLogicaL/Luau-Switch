--[[

    Switch

    License: MIT
    Author: @XnLogicaL (@CE0_OfTrolling)

    Usage:

    `Switch.new`


    ```lua
        local Switch = Switch.new(value)
    ```

    This creates a new switch object that you can start with

    --------------------------------------------------

    `Switch:Case`

    ```lua
        local Switch = Switch.new(value)
            :Case(value, function(breakOut, ...)
                breakOut()
            end)
            :Case(value2, func)
    ```

    The `:Case()` method adds a new possible case to the switch object
    If the `break` argument is called, the switch stops evaluating and initiates cleanup.

    * Chainable.

    --------------------------------------------------

    `Switch:Default`

    ```lua
        local Switch = Switch.new(value)
            :Case(value, func)
            :Case(value2, func)

            :Default(func)
    ```

    The `:Default()` method adds a "base-case" to the switch object, which is run when none of the regular cases are fulfilled
    * Chainable.

    --------------------------------------------------

    And finally, to start the evaluation of the switch, you can call the switch object:

    ```lua
        local Switch = Switch.new(value)
            :Case(value, func)
            :Case(value2, func)

            :Default(func)

        Switch()
    ```

    This evaluates the switch and when it has completed execution, destroys it with `:Destroy()`.

    --------------------------------------------------

    `Switch:Destroy`

    ```lua
        local Switch = Switch.new(value)
        Switch:Destroy()
    ```

    A generic cleanup method to add cleanup compat.

]]

export type _break = () -> ()
export type handler<Args...> = (_break, Args...) -> boolean?

local Switch = {}
Switch.__index = Switch

function Switch:Case<Args...>(value: any, handler: handler<Args...>, ...: Args...)
    self._cases[value] = {
        _callback = handler;
        _args = {...};
    }

    return self
end

function Switch:Default<Args...>(handler: handler<Args...>, ...: Args...)
    self._default = {
        _callback = handler;
        _args = {...};
    }
    
    return self
end

function Switch:__call()
    if self._started then
        error("switch has already been evaluated!")
    end

    self._started = true
    self._use_default = true

    for value, handler in self._cases do
        if value ~= self._value then
            continue
        end

		local _break = handler._callback(
            function()
                return true
            end,
            table.unpack(handler._args)
        )

		self._use_default = false

		if _break ~= nil then
			break
		end
    end

    if self._use_default and self._default ~= nil then
        self._default._callback(
            table.unpack(self._default._args)
        )
    end

    self:Destroy()
end

function Switch:Destroy()
    table.clear(self)
    setmetatable(self, nil)
end

local exports = {}
exports.__index = exports

function exports.new(value: any)
    local self = setmetatable({}, Switch)

    self._value = value

    return self
end

return table.freeze(exports)
