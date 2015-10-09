defaultTypes = require "./defaultTypes"
defaultFieldTypes = require "./defaultFieldTypes"
allowedClauseToCondition = require "./allowedClauseToCondition"

generateFieldValidator = (name, type, allowed, disallowed) ->
    # Result is: { validate: function (value, useExport) { ... } }

    # String type?  Well lookup the actual type
    if typeof type != "object" then type = defaultTypes[type] || defaultTypes[defaultFieldTypes[name]]
    if !type then throw new Error "Unable to locate type for #{name}"

    rv = type: type
    method = ""

    if type.isValidator
        # This is a chained validator...so chain on!
        method += "if (useExport) val = this.type.export(val); else val = this.type.parse(val);"
    else
        # This is a basic field - so process it...
        if type.verify then method += "if (!this.type.verify(val)) throw new Error('Illegal value for '+name);"

        if type.export
            method += "if (useExport) val = this.type.export(val);"
            if type.parse then method += "else val = this.type.parse(val);"
        else if type.parse
            method += "if (!useExport) val = this.type.parse(val);"

    if allowed || disallowed
        method += "if (val === null || val === undefined) return val;"

        # While it might be odd for a chanined validator to enforce allow/disallow, no reason to not support it...
        if allowed
            rv.allowed = allowed
            method += "if (!(#{allowedClauseToCondition(allowed, "this.allowed")})) throw new Error('Not an allowed value for '+name);"
        else if disallowed
            rv.disallowed = disallowed
            method += "if (#{allowedClauseToCondition(disallowed, "this.disallowed")}) throw new Error('Disallowed value for '+name);"

    method += "return val;"

    rv.validate = new Function "name", "val", "useExport", method

    return rv

module.exports = generateFieldValidator