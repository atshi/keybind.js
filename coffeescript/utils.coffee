class Utils
    @typeIsArray = ( value ) ->
        value and
            typeof value is 'object' and
            value instanceof Array and
            typeof value.length is 'number' and
            typeof value.splice is 'function' and
            not ( value.propertyIsEnumerable 'length' )

    @cloneObject = (obj) ->
        if typeof obj == 'string' or typeof obj == 'number'
            return obj

        newObj = if @typeIsArray(obj) then [] else {}
        for own key, value of obj
            if obj[key] && typeof obj[key] == "object"
                newObj[key] = @cloneObject obj[key]
            else
                newObj[key] = obj[key]
        return newObj

    @mergeInto = (obj, into) ->
        for own key, value of obj
            if into[key]?
                if @typeIsArray(into[key]) and into[key].length > 0
                    into[key] = into[key].concat obj[key]
                else
                    @mergeInto obj[key], into[key]
            else
                into[key] = @cloneObject obj[key]
