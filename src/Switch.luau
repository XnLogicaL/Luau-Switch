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

type _VType<_Ret> = _Ret | any?

export type Switch<_Ret> = {
    Case: <_Args...>(
        self: Switch<_Ret>,
        value: _VType<_Ret>,
        handler: (_Args...) -> _VType<_Ret>?,
        _Args...
    ) -> Switch<_Ret>;

    Default: <_Args...>(
        self: Switch<_Ret>,
        handler: (_Args...) -> _VType<_Ret>?,
        _Args...
    ) -> Switch<_Ret>;

    Destroy: (self: Switch<_Ret>) -> ();
    __call: (self: Switch<_Ret>) -> _VType<_Ret>;
}

export type SwitchConstructor = {
    new: <_Ty>(value: _Ty) -> Switch<_Ty>;
}

local Switch = {}
Switch.__index = Switch

function Switch:Case(value, handler, ...)
    local currentCase = self._CasesHead
    
    while self._CasesHead._Next ~= nil do
        currentCase = self._CasesHead._Next
    end

    currentCase._Next = {
        _Value = value;
        _Callback = handler;
        _Args = {...};
        _Next = nil;
    }

    return self
end

function Switch:Default(handler, ...)
    self.Default = {
        _Callback = handler;
        _Args = {...};
    }
    
    return self
end

function Switch:__call()
    if self._Started then
        error("attempt to call switch twice")
    end

    self._Started = true
    self._UseDefault = true

    local ret
    local currentCase = self._CasesHead

    while currentCase._Next ~= nil do
        self._UseDefault = false

        if self._Value == currentCase._Value then
            ret = currentCase._handler(table.unpack(currentCase._Args))

            if ret ~= nil then
                break
            end
        end

        currentCase = currentCase._Next
    end

    if self._UseDefault and self._Default ~= nil then
        self._Default._Callback(
            table.unpack(self._Default._Args)
        )
    end

    self:Destroy()

    return ret
end

function Switch:Destroy()
    table.clear(self)
    setmetatable(self, nil)
end

function Switch.new(value)
    local self = setmetatable({}, Switch)

    self._Value = value
    self._Default = nil
    self._Started = false
    self._UseDefault = true
    self._CaseHead = {}

    return table.freeze(self)
end

return Switch :: SwitchConstructor
