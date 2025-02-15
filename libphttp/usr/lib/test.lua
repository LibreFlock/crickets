--[[local bstd = require("bstdlib")
local state = 0

bstd.switch(state) {
    bstd.case(0) (function ()
        print("state 1")
        return bstd.stop()
    end),
    bstd.case(1) (function()
        print("state 2")
        return bstd.stop()
    end),
    bstd.case(2) (function ()
        print("state 3")
        return bstd.stop()
    end)
}]]

local phttp = require("phttp")
--[[local g = "[%a%d-]+$" -- "[%a%d%%%-._~$&'%(%)%*%+,;=:@/]+"
for w in string.gmatch("Sus: ok", g) do
    print("match:", w)
end]]

--[[local parser = phttp.request_parser()
local f, err = parser:line("GET /sus HTTP/1.1")
print(f, err)
print("verb:", parser.parsed.verb)
print("pathname:", parser.parsed.pathname)
print("httpver:", parser.parsed.http_version)
local f, err = parser:line("Content-Type: text/html")
print("funny", f, err)
print(parser.parsed.headers[1].name)
print(parser.parsed.headers[1].value)
local f, err = parser:line("")
print(f, err)
local f, err = parser:line("amog")
print(f, err)]]
local parser = phttp.response_parser()
local f, err = parser:line("HTTP/1.1 101 Switching Protocols")
print(f, err)
print(parser.parsed.http_version)
print(parser.parsed.status_code)
print(parser.parsed.status_message)
local f, err = parser:line("Content-Type: text/lua")
print(f, err)
print(parser.parsed.headers[1].name)
print(parser.parsed.headers[1].value)
local f, err = parser:line("")
print(f, err)
local f, err = parser:line("wswswsws")
print(f, err)
