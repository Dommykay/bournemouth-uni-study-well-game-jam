-- I made the original function CreateTweenNumber but google gemini AI fixed an issue with it


function CreateTweenNumber(start_num,end_num,time,start_time,tween_type)
    local tween = {}

    if tween_type == nil then -- Available options are linear, root
        tween_type = "linear"
    end
    
    local duration = time -- 'time' is the duration
    local delay = start_time or 0 -- 'start_time' is the delay

    -- This is the absolute time the tween will begin
    tween.start_time = love.timer.getTime() + delay 
    
    -- *** THIS IS THE FIX ***
    -- The end time is the start time PLUS the duration
    tween.end_time = tween.start_time + duration 
    
    tween.start_num = start_num
    tween.difference = end_num - start_num
    
    -- The time_difference is just the duration
    tween.time_difference = duration
    
    tween.time_from_start = function () return math.max(love.timer.getTime() - tween.start_time, 0) end

    -- Handle potential division by zero if duration is 0
    if duration <= 0 then
        tween.ReturnValue = function () return tween.start_num + tween.difference end
        
    elseif tween_type == "linear" then
        tween.ReturnValue = function () return tween.start_num + (tween.difference * math.min(((tween.time_from_start())/tween.time_difference), 1)) end
        tween.ReturnProgress = function () return math.min(((tween.time_from_start())/tween.time_difference),1) end
            
    elseif tween_type == "root" then
        tween.ReturnValue = function () return tween.start_num + (tween.difference * math.min((((tween.time_from_start())/tween.time_difference)^0.3),1)) end
        tween.ReturnProgress = function () return math.min((((tween.time_from_start())/tween.time_difference)^0.3),1) end
    end
    
    return tween
end

function CreateTweenVector(start_vec,end_vec,time,start_time,tween_type)
    local tween = {}

    tween.x = CreateTweenNumber(start_vec.x, end_vec.x, time, start_time, tween_type)
    tween.y = CreateTweenNumber(start_vec.y, end_vec.y, time, start_time, tween_type)

    tween.ReturnValue = function() return vector.new(tween.x.ReturnValue(),tween.y.ReturnValue()) end
    tween.ReturnProgress = function() return vector.new(tween.x.ReturnProgress(),tween.y.ReturnProgress()) end

    return tween
end

function CreateTweenRBGA(start_rgb,end_rgb,time,start_time,tween_type)
    local tween = {}

    tween.r = CreateTweenNumber(start_rgb.r, end_rgb.r, time, start_time, tween_type)
    tween.g = CreateTweenNumber(start_rgb.g, end_rgb.g, time, start_time, tween_type)
    tween.b = CreateTweenNumber(start_rgb.b, end_rgb.b, time, start_time, tween_type)
    tween.a = CreateTweenNumber(start_rgb.a, end_rgb.a, time, start_time, tween_type)

    tween.ReturnValue = function() return colour.new(tween.r.ReturnValue(),tween.g.ReturnValue(),tween.b.ReturnValue(),tween.a.ReturnValue()) end
    tween.ReturnProgress = function() return colour.new(tween.r.ReturnProgress(),tween.g.ReturnProgress(),tween.b.ReturnProgress(),tween.a.ReturnProgress()) end

    return tween
end