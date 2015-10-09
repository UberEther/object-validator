allowedClauseToCondition = (allowed, fieldName) ->
    switch
        when allowed instanceof RegExp
            return "#{fieldName}.test(val)"
        when typeof allowed == "function"
            return "#{fieldName}(val)"
        when Array.isArray allowed
            return "#{fieldName}.indexOf(val) >= 0"
        else
            return "val === #{fieldName}"

module.exports = allowedClauseToCondition