-- Example of state machine logic using Lua objects 

function blink1()

    gpio.write(4, gpio.LOW)
    uart.write(0, "State 1: ")
    if n > 9 then -- some trigger to escape current state 
        n = 0
        return BlinkyStates:Change("BlinkTwice")
    end
    uart.write(0, "blinking once every second\n\r")
    blinky1:register("1000", tmr.ALARM_SINGLE, blink1)
    blinky1:start()
    n = n + 1
    gpio.write(4, gpio.HIGH)

end 

function blink1stop()

    blinky1:unregister() 
    n = 0 

end

function blink2()

    gpio.write(4, gpio.LOW)
    uart.write(0, "State 2: ")
    if n > 9 then 
        return BlinkyStates:Change("BlinkThrice")
    end
    uart.write(0, "blinking twice every second\n\r")
    blinky2:register("500", tmr.ALARM_SINGLE, blink2)
    blinky2:start()
    n = n + 1
    gpio.write(4, gpio.HIGH)

end 

function blink2stop() 

    blinky2:unregister() 
    n = 0 

end

function blink3()

    gpio.write(4, gpio.LOW)
    uart.write(0, "State 3: ")
    uart.write(0, "blinking three times a second\n\r")
    blinky3:register("333", tmr.ALARM_SINGLE, blink3)
    blinky3:start()
    gpio.write(4, gpio.HIGH)

end 

StateMachine = {}
StateMachine.__index = StateMachine
function StateMachine:Create()
    local this =
    {
        mEmpty =  -- template for creating new states
        {
            HandleInput = function() end,
            Update = function() end,
            Enter = function() end,
            Exit = function() end
        },
        mCurrent = nil,
        mStates = {}
    }
    this.mCurrent = this.mEmpty
    setmetatable(this, self)
    return this
end

function StateMachine:Change(stateName)
    assert(self.mStates[stateName]) -- state must exist!
    self.mCurrent:Exit()
    self.mCurrent = self.mStates[stateName]
    self.mCurrent:Enter()
end

function StateMachine:Update() -- could also handle data transfer between updates 
    self.mCurrent:Update()
end

function StateMachine:Add(id, state)
    self.mStates[id] = state
end

function StateMachine:Remove(id)

    if self.mCurrent == self.mStates[id] then
        self.mCurrent = self.mEmpty
    end

    self.mStates[id] = nil
end

function StateMachine:Clear()
    self.mStates = {}
    self.mCurrent = self.mEmpty
end

n = 0
gpio.mode(4, gpio.OUTPUT)

blinky1 = tmr.create()
blinky2 = tmr.create()
blinky3 = tmr.create()

BlinkyStates = StateMachine:Create()

blinkONE = {
            HandleInput = function() end,
            Update = function() end,
            Enter = blink1,
            Exit = blink1stop 
           }

blinkTWO = {
            HandleInput = function() end,
            Update = function() end,
            Enter = blink2,
            Exit = blink2stop 
           }

blinkTHR = {
            HandleInput = function() end,
            Update = function() end,
            Enter = blink3,
            Exit = function() end
           }

BlinkyStates:Add("BlinkOnce", blinkONE) 
BlinkyStates:Add("BlinkTwice", blinkTWO) 
BlinkyStates:Add("BlinkThrice", blinkTHR) 

-- initialize by changing into first desired state
BlinkyStates:Change("BlinkOnce")
