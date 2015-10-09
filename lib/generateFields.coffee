generateFieldValidator = require "./generateFieldValidator"

generateFields = (options) ->
    rv = {}

    for name, type of options.fields || {}
        # Short-circuit for never case...
        if options.req?[name] == "never"
            rv[name] = generateFieldValidator name, "never"
            continue

        rv[name] = generateFieldValidator name, type,
                        options.allowedValues?[name],
                        options.disallowedValues?[name]

    # Inject default...
    rv.__default__ ||= generateFieldValidator "__default__", if options.allowAny then "any" else "never"

    return rv
    
module.exports = generateFields