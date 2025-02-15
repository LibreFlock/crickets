-- lib parse http/1.1
local bstd = require("bstdlib")
local switch, case, stop = bstd.switch, bstd.case, bstd.stop
local t = {
    compatible_http_versions = { "HTTP/1.0", "HTTP/1.1" },
    verbs = {
        "GET",
        "POST",
        "PATCH",
        "DELETE",
        "OPTIONS",
        "HEAD"
    },
    states = {
        controlData = 0,
        headers = 1,
        body = 2
    },
    path_directory_pattern = "[%a%d%%%-._~$&'%(%)%*%+,;=:@/]+",
    header_name_pattern = "[%a%d-]+",
    status_codes = bstd.enum {
        [100] = "Continue",
        [101] = "Switching Protocols",
        [102] = "Processing",
        [103] = "Early Hints",
        [200] = "OK",
        [201] = "Created",
        [202] = "Accepted",
        [203] = "Non-Authoritative Information",
        [204] = "No Content",
        [205] = "Reset Content",
        [206] = "Partial Content",
        [207] = "Multi-Status",
        [208] = "Already Reported",
        [218] = "This is fine (Apache Web Server)",
        [226] = "IM Used",
        [300] = "Multiple Choices",
        [301] = "Moved Permanently",
        [302] = "Found",
        [303] = "See Other",
        [304] = "Not Modified",
        [306] = "Switch Proxy",
        [307] = "Temporary Redirect",
        [308] = "Resume Incomplete",
        [400] = "Bad Request",
        [401] = "Unauthorized",
        [402] = "Payment Required",
        [403] = "Forbidden",
        [404] = "Not Found",
        [405] = "Method Not Allowed",
        [406] = "Not Acceptable",
        [407] = "Proxy Authentication Required",
        [408] = "Request Timeout",
        [409] = "Conflict",
        [410] = "Gone",
        [411] = "Length Required",
        [412] = "Precondition Failed",
        [413] = "Request Entity Too Large",
        [414] = "Request-URI Too Long",
        [415] = "Unsupported Media Type",
        [416] = "Requested Range Not Satisfiable",
        [417] = "Expectation Failed",
        [418] = "I'm a teapot",
        [419] = "Page Expired (Laravel Framework)",
        [420] = "Method Failure (Spring Framework)",
        [421] = "Misdirected Request",
        [422] = "Unprocessable Entity",
        [423] = "Locked",
        [424] = "Failed Dependency",
        [426] = "Upgrade Required",
        [428] = "Precondition Required",
        [429] = "Too Many Requests",
        [431] = "Request Header Fields Too Large",
        [440] = "Login Time-out",
        [444] = "Connection Closed Without Response",
        [449] = "Retry With",
        [450] = "Blocked by Windows Parental Controls",
        [451] = "Unavailable For Legal Reasons",
        [494] = "Request Header Too Large",
        [495] = "SSL Certificate Error",
        [496] = "SSL Certificate Required",
        [497] = "HTTP Request Sent to HTTPS Port",
        [498] = "Invalid Token (Esri)",
        [499] = "Client Closed Request",
        [500] = "Internal Server Error",
        [501] = "Not Implemented",
        [502] = "Bad Gateway",
        [503] = "Service Unavailable",
        [504] = "Gateway Timeout",
        [505] = "HTTP Version Not Supported",
        [506] = "Variant Also Negotiates",
        [507] = "Insufficient Storage",
        [508] = "Loop Detected",
        [509] = "Bandwidth Limit Exceeded",
        [510] = "Not Extended",
        [511] = "Network Authentication Required",
        [520] = "Unknown Error",
        [521] = "Web Server Is Down",
        [522] = "Connection Timed Out",
        [523] = "Origin Is Unreachable",
        [524] = "A Timeout Occurred",
        [525] = "SSL Handshake Failed",
        [526] = "Invalid SSL Certificate",
        [527] = "Railgun Listener to Origin Error",
        [530] = "Origin DNS Error",
        [598] = "Network Read Timeout Error",
        ["1xx"] = "Information",
        ["2xx"] = "Successful",
        ["3xx"] = "Redirection",
        ["4xx"] = "Client Error",
        ["5xx"] = "Server Error",
    }
}

function t._is_known_verb(str)
    for k, v in ipairs(t.verbs)
    do
        if str:sub(1, #v) == v then
            return true, v
        end
    end
    return false
end
function t._is_compatible_http_version(str)
    return bstd.table.has_value(t.compatible_http_versions, str)
end

function t.request_parser()
    return {
        state = t.states.controlData,
        parsed = {},

        --- Parse a single line
        ---@param self self
        ---@param line string
        ---@return boolean finished, string? err
        line = function (self, line)
            return table.unpack(
                switch(self.state) {
                    case(t.states.controlData) (function() return self:_parse_control_data(line) end),
                    case(t.states.headers) (function()
                        return self:_parse_header(line)
                    end),
                    case(t.states.body) (function()
                        return stop { true }
                    end)
                }
            )
        end,
        _parse_control_data = function(self, line)
            local isValid, verb = t._is_known_verb(line)
            if not isValid then
                return stop { false, "invalid verb" }
            end
            self.parsed.verb = verb
            local pathname = self._read_pathname(string.sub(line, #verb+1))()
            self.parsed.pathname = pathname
            if pathname == nil or pathname == "" then
                return stop { false, "invalid pathname" }
            end
            local httpver = string.gmatch(line, "%a+/%d.%d", #verb + 1 + #pathname + 1)
            self.parsed.http_version = httpver()
            if not t._is_compatible_http_version(self.parsed.http_version) then
                return stop { false, "incompatible http version" }
            end
            self.state = t.states.headers
            return stop { false }
        end,
        _parse_header = function(self, line)
            if line == "" or line == "\n" or line == "\r\n" then
                self.state = t.states.body
                return stop { true }
            end
            if self.parsed.headers == nil then
                self.parsed.headers = {}
            end
            local sep_loc = string.find(line, ":")
            local raw_name = string.sub(line, 1, sep_loc-1)
            local name = string.gmatch(raw_name, t.header_name_pattern)()
            local value = string.sub(line, sep_loc+2)
            --print(raw_name, name)
            if raw_name ~= name then
                return stop { false, "invalid header name" }
            end
            table.insert(self.parsed.headers, {
                name = name,
                value = value
            })
            return stop { false }
        end,
        _read_pathname = function(path)
            return string.gmatch(path, t.path_directory_pattern)
        end
    }
end

function t.response_parser()
    return {
        state = t.states.controlData,
        parsed = {},

        --- Parse a single line
        ---@param self self
        ---@param line string
        ---@return boolean finished, string? err
        line = function (self, line)
            return table.unpack(
                switch(self.state) {
                    case(t.states.controlData) (function() return self:_parse_control_data(line) end),
                    case(t.states.headers) (function()
                        return self:_parse_header(line)
                    end),
                    case(t.states.body) (function()
                        return stop { true }
                    end)
                }
            )
        end,
        _parse_control_data = function(self, line)
            local httpver = string.gmatch(line, "%a+/%d.%d")
            self.parsed.http_version = httpver()
            if not t._is_compatible_http_version(self.parsed.http_version) then
                return stop { false, "incompatible http version" }
            end
            local statusCode = string.gmatch(line, "%d+", #self.parsed.http_version+2)()
            self.parsed.status_code = tonumber(statusCode)
            if statusCode == nil or statusCode == "" then
                return stop { false, "invalid status code" }
            end
            local statusMsg = string.sub(line, #self.parsed.http_version + 1 + #statusCode + 2)
            self.parsed.status_message = statusMsg
            --[[local isValid, verb = t._is_known_verb(line)
            if not isValid then
                return stop { false, "invalid verb" }
            end
            self.parsed.verb = verb
            local pathname = self._read_pathname(string.sub(line, #verb+1))()
            self.parsed.pathname = pathname
            if pathname == nil or pathname == "" then
                return stop { false, "invalid pathname" }
            end
            local httpver = string.gmatch(line, "%a+/%d.%d", #verb + 1 + #pathname + 1)
            self.parsed.http_version = httpver()
            if not t._is_compatible_http_version(self.parsed.http_version) then
                return stop { false, "incompatible http version" }
            end
            self.state = t.states.headers]]
            self.state = t.states.headers
            return stop { false }
        end,
        _parse_header = function(self, line)
            if line == "" or line == "\n" or line == "\r\n" then
                self.state = t.states.body
                return stop { true }
            end
            if self.parsed.headers == nil then
                self.parsed.headers = {}
            end
            local sep_loc = string.find(line, ":")
            local raw_name = string.sub(line, 1, sep_loc-1)
            local name = string.gmatch(raw_name, t.header_name_pattern)()
            local value = string.sub(line, sep_loc+2)
            --print(raw_name, name)
            if raw_name ~= name then
                return stop { false, "invalid header name" }
            end
            table.insert(self.parsed.headers, {
                name = name,
                value = value
            })
            return stop { false }
        end,
        _read_pathname = function(path)
            return string.gmatch(path, t.path_directory_pattern)
        end
    }
end

function t.create_response_header(statusCode, headers, dontIncludeNl)
    local resp = string.format("HTTP/1.1 %d %s\r\n", statusCode, t.status_codes[statusCode])
    
    for k, v in ipairs(headers) do
        resp = resp .. string.format("%s: %s\r\n", v[1], v[2])
    end
    if not dontIncludeNl then resp = resp .. "\r\n" end
    return resp
end

return t