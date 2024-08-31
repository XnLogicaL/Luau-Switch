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
            :Case(value, function(...)
                return false
            end)
            :Case(value2, func)
    ```

    The `:Case()` method adds a new possible case to the switch object
    If the function returns anything other than `nil`, the switch finalizes and returns the return value.

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
        map[v.Order] = {
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
    local previousMatch = self.Cases[value]

    if previousMatch == nil then
        self.CurrentIdx += 1
        order = self.CurrentIdx
    else
        order = previousMatch.Order
    end

    self.Cases[value] = {
        Callback = handler;
        Args = {...};
        Order = order;
    }

    return self
end

function Switch:Default<Args...>(handler: handler<Args...>, ...: Args...)
    self.Default = {
        Callback = handler;
        Args = {...};
    }
    
    return self
end

function Switch:__call()
    if self.Started then
        error("switch has already been evaluated!")
    end

    self.Started = true
    self.UseDefault = true

    local ret
    local caseMap = mapCases(self.Cases)

    for _, case in caseMap do
        if case.key ~= self.Value then
            continue
        end

        local handler = case.value
        local localRet = handler.Callback(table.unpack(handler.Args))

		self.UseDefault = false

		if localRet ~= nil then
			ret = localRet
            break
		end
    end

    if self.UseDefault and self.Default ~= nil then
        self.Default.Callback(
            table.unpack(self.Default.Args)
        )
    end

    self:Destroy()

    return ret
end

function Switch:Destroy()
    table.clear(self)
    setmetatable(self, nil)
end

function Switch.new(value: any)
    local self = setmetatable({}, Switch)

    self.Value = value
    self.Default = nil
    self.CurrentIdx = 0
    self.Started = false
    self.UseDefault = true
    self.Cases = {}

    return table.freeze(self)
end

return Switch
