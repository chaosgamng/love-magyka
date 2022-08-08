require "Scripts.Node"
require "Scripts.Prototype"

Timer = Node{
    timers = {},
    
    _timer = Prototype{
        name = "Timer",
        start = 0,
        stop = 1,
        step = 1,
        value = 0
    },
    
    set = function(self, name, ...)
        local args = {...}
        
        if #args == 1 then start, stop, step = 1, args[1], 1 end
        if #args == 2 then start, stop, step = args[1], args[2], 1 end
        if #args == 3 then start, stop, step = unpack(args) end
        
        if self.timers ~= nil or self.timers[name] ~= nil then
            ins = true
        else
            ins = false
        end
        
        if ins then
            self.timers[name] = self._timer{start=start, stop=stop, step=step}
        else
            self.timers[name].start = start
            self.timers[name].stop = stop
            self.timers[name].step = step
        end
    end,
    
    get = function(self, name, round)
        timer_value = self.timers[name].value
        
        if round == nil then
            round = true
            step = self.timers[name].step
        else step = round end
        
        if round then value = timer_value - timer_value % step
        else value = timer_value end
        
        return value
    end,
    
    ready = function(self, name)
        return self:get(name, false) >= self.timers[name].stop
    end,
    
    reset = function(self, name)
        self.timers[name].value = self.timers[name].start
    end,
    
    update = function(self, dt)
        for _, t in pairs(self.timers) do
            t.value = t.value + t.step * dt
            
            if (t.step > 0 and t.value > t.stop) or (t.step < 0 and t.value < t.stop) then
                t.value = t.stop
            end
        end
    end,
    
    draw = function(self)
        return
    end
}