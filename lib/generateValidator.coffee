generateObjectValidator = require "./generateObjectValidator"

generateValidator = (options) ->
    # To use:
    # rv.export(value)
    # rv.parse(value)

    if options.isValidator then return options # It's already a validator - nothing to do...

    rv =
        isValidator: true
        export: (val) -> return this._export.validate val, true
        parse: (val) -> return this._parse.validate val, false

    if options.gen || options.val
        # Have overrides - need to generate 2 routines
        rv._export = generateObjectValidator options.export, options
        rv._parse = generateObjectValidator options.parse, options
    else
        rv._export = rv._parse = generateObjectValidator {}, options

    return rv

module.exports = generateValidator
