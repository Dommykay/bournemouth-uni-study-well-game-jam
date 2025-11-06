function CreateTweenNumber(start_num,end_num,time,start_time,tween_type)
    local tween = {}

    if tween_type == nil then -- Available options are linear, root
        tween_type = "linear"
    end
    
    if start_time == nil then
        tween.start_time = love.timer.getTime()
    else
        tween.start_time = love.timer.getTime() + start_time
    end
    tween.start_num = start_num
    tween.end_time = time
    tween.difference = end_num - start_num
    tween.time_difference = tween.end_time
    tween.time_from_start = function () return math.max(love.timer.getTime() - tween.start_time, 0) end

    if tween_type == "linear" then
        tween.ReturnValue = function () return tween.start_num + (tween.difference * math.min((tween.time_from_start())/tween.time_difference, 1)) end
    
    elseif tween_type == "root" then
        tween.ReturnValue = function () return tween.start_num + (tween.difference * math.min(((tween.time_from_start())/tween.time_difference)^0.3,1)) end
    end
    return tween
end

function CreateTweenVector(start_vec,end_vec,time,start_time,tween_type)
    local tween = {}

    tween.x = CreateTweenNumber(start_vec.x, end_vec.x, time, start_time, tween_type)
    tween.y = CreateTweenNumber(start_vec.y, end_vec.y, time, start_time, tween_type)
    tween.ReturnValue = function() return vector.new(tween.x.ReturnValue(),tween.y.ReturnValue()) end

    return tween
end

function CreateTweenRBGA(start_rgb,end_rgb,time,start_time,tween_type)
    local tween = {}

    tween.r = CreateTweenNumber(start_rgb.r, end_rgb.r, time, start_time, tween_type)
    tween.g = CreateTweenNumber(start_rgb.g, end_rgb.g, time, start_time, tween_type)
    tween.b = CreateTweenNumber(start_rgb.b, end_rgb.b, time, start_time, tween_type)
    tween.a = CreateTweenNumber(start_rgb.a, end_rgb.a, time, start_time, tween_type)

    tween.ReturnValue = function() return colour.new(tween.r.ReturnValue(),tween.g.ReturnValue(),tween.b.ReturnValue(),tween.a.ReturnValue()) end

    return tween
end