-- Strips string of leading and trailing spaces and newlines
local function trim(self)
  return string.match(self, '^%s*(.*%S)') or ''
end

local function join(tbl, glue)
    return table.concat(tbl, glue)
end

-- Splits string into pieces
local function split(str, div)
    assert(type(str) == "string" and type(div) == "string", "invalid arguments")
    assert(not string.find("", div, 1), "delimiter matches empty string!")
    local res = {}
    while true do
        local pos1,pos2 = str:find(div)
        if not pos1 then
            res[#res+1] = str
            break
        end
        res[#res+1],str = str:sub(1,pos1-1),str:sub(pos2+1)
    end
    return res
end

local function hex_to_char(x)
  return string.char(tonumber(x, 16))
end

local function decodeUrl(url)
  url = url:gsub("%%(%x%x)", hex_to_char)
  url = url:gsub("%%%%", "%%")
  return url
end

return { 
    split=split, 
    join=join,
    trim=trim,
    decodeUrl=decodeUrl
}
