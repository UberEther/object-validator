util = require "util"
clone = require "clone"
generateFields = require "./generateFields"

generateObjectValidator = (options = {}, defaults = {}) ->
    # Result is: { validate: function (value) { ... } }

    # Merge options and defaults together...
    options = util._extend util._extend({}, defaults), options

    # No validation required - use a noop stub
    if options.skip then return validate: (x) -> x

    # Generate all the individual field validations...
    options._fields = generateFields options

    method = ""

    # Invoke pre method if defined
    if options.pre then method += "val = this.pre(val, this);"

    # Prepare results with defaults...
    if options.defaults
        options.defaults = clone.bind null, options.defaults
        method += "var rv = this.defaults();"
    else method += "var rv = {};"

    # Loop over all provided fields...
    method +=
        "var name, v, t; for (name in val) {"+
            "v = this._fields[name] || this._fields.__default__;"+
            "t = v.validate(name, val[name], useExport);"+
            "if (t !== undefined) rv[name] = t;"+
        "}";

    # Verify we got all the requred fields (or generate if needed)
    if options.req then for name, val of options.req
        if val == "gen"
            if !options._fields[name].type.generate then throw new Error "No generate method available for #{name}"
            method += "if (rv['#{name}'] === undefined) if (useExport) rv['#{name}'] = this._fields['#{name}'].type.generate();"
            if val != "genOpt" then method += "else throw new Error('Missing required field: #{name}');"
        else if val == "req" || val == true || val == "gen"
            method += "if (rv['#{name}'] === undefined) throw new Error('Missing required field: #{name}');"

    # Invoke post method if defined
    if options.post then method += "rv = this.post(rv, this);"

    method += "return rv;"

    options.validate = new Function "val", "useExport", method
    return options

module.exports = generateObjectValidator