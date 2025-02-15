-- load namespace
local io = require("io")
local phttp = require("phttp")
local socket = require("socket")
local bstd = require("bstdlib")
-- create a TCP socket and bind it to the local host, at any port
local server = assert(socket.bind("*", 3101))
-- find out which port the OS chose for us
local ip, port = server:getsockname()
-- print a message informing what's up
print("Please connect to localhost on port " .. port)
-- loop forever waiting for clients
while 1 do
  -- wait for a connection from any client
  local client = server:accept()
  local req = phttp.request_parser()
  -- make sure we don't block waiting for this client's line
  client:settimeout(10)
  -- receive the line
    local line, err = client:receive()
  while line ~= nil
  do
    local reachedBody, rerr = req:line(line)
    if rerr then print("parser error:", err) end
    if reachedBody then break end
    line, err = client:receive()
  end
  local filet = "." .. req.parsed.pathname
  if bstd.string.ends_with(filet, "/") then
    filet = filet .. "index.html"
  end
  local h, err = io.open(filet, "r")
  if h == nil then
    print(err)
    local content = "File " .. filet .. " not found."
    --client:send("HTTP/1.1 404 Not Found\r\nContent-Type: text/html\r\nContent-Length: " .. #content .. "\r\n\r\n" .. content)
    client:send(phttp.create_response_header(404, {
        {"Content-Type", "text/plain"},
        {"Content-Length", #content}
    }))
    client:send(content)
  else
    local size = h:seek("end")
    h:seek("set", 0)
    local content = string.format("Hello world from Lua! verb=%q path=%q", req.parsed.verb, req.parsed.pathname)
    --client:send("HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: " .. size .. "\r\n\r\n")
    local type = "text/plain"
    if bstd.string.ends_with(filet, ".html") then type = "text/html" end
    client:send(phttp.create_response_header(200, {
        {"Content-Type", type},
        {"Content-Length", size}
    }))
    local chunkSize = 1024
    local chunks = math.ceil(size / chunkSize)
    --print(chunks)
    for i = 0, chunks, 1
    do
        local text = h:read(chunkSize)
        --print(i, #text)
        if text ~= nil then
            client:send(text)
        end
    end
    h:close()
    end
  --[[local line, err = client:receive()
  -- if there was no error, send it back to the client
  if err then goto cont end
  print(string.format("%q", line))]]
  
  --if not err then client:send(line .. "\n") end
  -- done with client, close the object
  ::cont::
  client:close()
end