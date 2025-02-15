# libphttp
HTTP parser library for Lua. Requires at least bstdlib a0.2.0 with switch cases enabled.
### Usage
**For requests:** Create a parser with `phttp.request_parser()` then you can call its `parser:line(text: string)`, this will parse a single line of http. It'll return `reachedBody: boolean, errMsg: string?`. When `reachedBody` is true that means it reached the body part of the HTTP request and you should start processing the body. It also means you can now access `parser.parsed` containing all the juicy data.
- `parsed.verb: string` HTTP verb. (like GET, POST, etc)
- `parsed.pathname: string` The path. (e.g. /sus/amogus)
- `parsed.http_version: string` HTTP version of the request. (Only HTTP/1.0 and HTTP/1.1 are supported currently.)
- `parsed.headers: {name=string, value=string}[]` All the headers of the request as a indexed table.  

**For responses:** Again, create a parser with `phttp.response_parser()`, allowing you to call `parser:line(text: string)`, this is basically the same as the request parser, except that the `parsed` table is different.
- `http_version: string`
- `status_code: number` Status code of the response (e.g. 200, 300...)
- `status_message: string` Status *message* of the response, specified by the server. (e.g. OK, Not Found, Forbidden...)
- `headers: {name=string, value=string}[]` Response headers.