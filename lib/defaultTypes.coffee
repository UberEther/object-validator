uuid = require "node-uuid"

defaultTypes =
    "any": verify: (x) -> true

    "never": verify: (x) -> false

    "ignore":
        verify: (x) -> true
        parse: (x) -> undefined
        export: (x) -> undefined

    "string":
        verify: (x) -> typeof x == "string" && x != ""

    "number":
        verify: (x) -> typeof x == "number" && !isNaN(x)

    "integer":
        verify: (x) -> typeof x == "number" && (x % 1 == 0)

    "identifier": # Generates a v1 UUID
        verify: (x) -> typeof x == "string" && x != ""
        generate: () -> uuid.v1()

    "stringArray": # Exports single string values as a string - Imports single string values as an array
        verify: (x) -> (typeof x == "string" && x != "") || Array.isArray(x)
        parse: (x) -> if typeof x == "string" then [x] else x
        export: (x) -> if Array.isArray(x) && x.length == 1 then x[0] else x

    "timestampSeconds": # Supports both dates and JWT-style numeric dates (seconds from epoch)
        verify: (x) -> typeof x == "number" || (x instanceof Date && !isNaN(x.valueOf()))
        parse: (x) -> if typeof x == "number" then new Date(x * 1000) else x
        export: (x) -> if typeof x == "number" then x else (x.getTime() / 1000)
        generate: () -> Date.now() / 1000

    "expirationSeconds": # If parsing a number, it is a JWT-style numeric date - if exporting from a number, then it is milliseconds till expiration
        verify: (x) -> typeof x == "number" || (x instanceof Date && !isNaN(x.valueOf()))
        parse: (x) -> if typeof x == "number" then new Date(x * 1000) else x
        export: (x) -> if typeof x == "number" then (Date.now() / 1000 + x) else (x.valueOf() / 1000)

    "timestamp": # Supports both dates and JWT-style numeric dates (seconds from epoch)
        verify: (x) -> typeof x == "number" || (x instanceof Date && !isNaN(x.valueOf()))
        parse: (x) -> if typeof x == "number" then new Date(x) else x
        export: (x) -> if typeof x == "number" then x else (x.getTime())
        generate: () -> Date.now()

    "expiration": # If parsing a number, it is a JWT-style numeric date - if exporting from a number, then it is milliseconds till expiration
        verify: (x) -> typeof x == "number" || (x instanceof Date && !isNaN(x.valueOf()))
        parse: (x) -> if typeof x == "number" then new Date(x) else x
        export: (x) -> if typeof x == "number" then (Date.now()+x) else x.valueOf()

module.exports = defaultTypes