--
-- Author: shimin
-- Date: 2016-05-11 09:37:14
--
--[Comment]


func = func or {}

--序列化
function func.serialize(obj)
    local lua = ""
    local t = type(obj)
    if t == "number" then
        lua = lua .. obj
    elseif t == "boolean" then
        lua = lua .. tostring(obj)
    elseif t == "string" then
        lua = lua .. string.format("%q", obj)
    elseif t == "table" then
        lua = lua .. "{"
    for k, v in pairs(obj) do
        lua = lua .. "[" .. func.serialize(k) .. "]=" .. func.serialize(v) .. ","
    end
    local metatable = getmetatable(obj)
        if metatable ~= nil and type(metatable.__index) == "table" then
        for k, v in pairs(metatable.__index) do
            lua = lua .. "[" .. func.serialize(k) .. "]=" .. func.serialize(v) .. ","
        end
    end
        lua = lua .. "}"
    elseif t == "nil" then
        return nil
    else
        error("can not serialize a " .. t .. " type.")
    end
    return lua
end

--[Comment]
--反序列化
function func.unserialize(lua)
    local t = type(lua)
    if t == "nil" or lua == "" then
        return nil
    elseif t == "number" or t == "string" or t == "boolean" then
        lua = tostring(lua)
    else
        error("can not unserialize a " .. t .. " type.")
    end
    lua = "return " .. lua
    local func = loadstring(lua)
    if func == nil then
        return nil
    end
    return func()
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--直接打印日志
function mslog(fmt, ...)
    local str = string.format(tostring(fmt), ...)
    print(str)
    if msdebug ~= nil then msdebug:addMsg(str) end
end


--打印pbf
function dumppb(msg)
    if DEBUG == nil or DEBUG == 0 then
        return
    end
    local traceback = string.split(debug.traceback("", 2), "\n")
    print("dumppb from: " .. string.trim(traceback[3]))
    
    if msg == nil or msg._fields == nil then
        if dump ~= nil then dump(msg) end
        return
    end

    local result = {}
    local function _dumppb(pb, idt)
        idt = idt .. "   "
        if type(pb) ~= "table" then
            result[#result + 1] = idt .. "<val> = " .. pb .. ","
            return 
        end
        if pb.ListFields == nil then
            result[#result + 1] = idt .. "<val> = " .. pb._message_descriptor.name
            return 
        end
        local sidt = idt .. "   "
        for k,v in pb:ListFields() do
            if k.type == 11 then -- TYPE_MESSAGE
                if k.message_type ~= nil and k.message_type.name ~= nil then
                    result[#result + 1] = string.format("%s%s (%s) = {", idt, k.name, k.message_type.name)
                else
                    result[#result + 1] = string.format("%s%s (%s) = {", idt, k.name, type(v))
                end
                if (k.label == 3 or k.label == 1) and v[1] ~= nil then -- LABEL_REPEATED， LABEL_OPTIONAL
                    for _,spb in ipairs(v) do
                        result[#result + 1] = string.format("%s[ %d ] = {", sidt, _)
                        _dumppb(spb, sidt) 
                        result[#result + 1] = string.format("%s},", sidt)
                    end
                elseif k.label == 2 then -- LABEL_REQUIRED
                    _dumppb(v, idt)
                end
                result[#result + 1] = string.format("%s},", idt)
            else
                if k.label == 3 and type(v) =="table" and v[1] ~= nil then -- LABEL_REPEATED
                    result[#result + 1] = string.format("%s%s = {", idt, k.name)
                    for _,spb in ipairs(v) do
                        result[#result + 1] = string.format("%s[ %d ] = %s,", sidt, _, spb)
                    end
                    result[#result + 1] = string.format("%s},", idt)
                elseif k.label == 2 or k.label == 1 then -- LABEL_REQUIRED
                    local vtype = type(v)
                    if vtype == "userdata" or vtype == "table" then v = vtype end
                    local str = string.format("%s", k.name)
                    result[#result + 1] = string.format("%s%-17s = %s,", idt, str, v)
                end
            end  
        end
    end
    _dumppb(msg, "- ")
    print ("- <val> = {")
    for i, line in ipairs(result) do
        print(line)
    end
    print ("- }")
end
