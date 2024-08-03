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
                return breakOut()
            end)
	    :Case(value, function(breakOut, ...)
                return true -- equivilent to `return breakOut()`
            end)
            :Case(value2, func)
    ```

    The `:Case()` method adds a new possible case to the switch object
    If the `break` argument is called and returned (or `true` is returned), the switch stops evaluating and initiates cleanup.

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

export type Break = () -> ()
export type handler<Args...> = (Args...) -> boolean?

local function mapCases(cases)
    local map = {}
    for k, v in cases do
        map[v._order] = {
            key = k;
            val = v;
        }
    end
    return map
end

local Switch = {}
Switch.__index = Switch

function Switch:Case<Args...>(value: any, handler: handler<Break, Args...>, ...: Args...)
    local order = 0
    local previousMatch = self._cases[value]

    if previousMatch == nil then
        self._current_idx += 1
        order = self._current_idx
    else
        order = previousMatch._order
    end

    self._cases[value] = {
        _callback = handler;
        _args = {...};
        _order = order;
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

    local caseMap = mapCases(self._cases)

    for _, case in caseMap do
        if case.key ~= self._value then
            continue
        end

        local handler = case.val
		local Break = handler._callback(
            function()
                return true
            end,
            table.unpack(handler._args)
        )

		self._use_default = false

		if Break ~= nil then
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
    self._default = nil
    self._current_idx = 0
    self._started = false
    self._use_default = true
    self._cases = {}

    return table.freeze(self)
end

return table.freeze(exports)
