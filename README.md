[![Build Status](https://travis-ci.org/UberEther/object-validator.svg?branch=master)](https://travis-ci.org/UberEther/object-validator)
[![NPM Status](https://badge.fury.io/js/uberether-object-validator.svg)](http://badge.fury.io/js/uberether-object-validator)

# TODO:
- [ ] Improve unit tests
- [ ] Generators for allowed/disallowed methods to more easily support ranges, regexp, etc
- [ ] Imporve Documentation and examples
- [ ] Specific error types for all thrown errors

# Overview

This library provides a method for generating validators of Javascript objects.  It was originally factored out of [uberether-jwt](https://github.com/UberEther/jwt.git) and thus had an initial focus on the requirements of validating JWTs, but it has use beyond so it was separated into this project.

# EXAMPLES:

## Javascript
```js
// @todo WRITE ME
```

## Coffeescript
```coffeescript
# @todo WRITE ME
```

# APIs:

## generateValidator(schema)

Returns an object with a parse and export method.
- parse(val) will return a new object with all the values verified and normalized.  Errors will be thrown on failures.
- export(val) will will verify fields, generate necessary values, and return a new object with all the new values.  Errors will be thrown on failures.

Generation is reasonably expensive, so please cache the results of this method and reuse it.  The methods are stateless.

```js
var generateValidator = require("uberether-object-validator");

var validator = generateValidator({
	fields: {
		a: "string",
		b: "integer"
	}
});

var valueFromUser = validator.parse(someExternalValue);
var valueToSendToUser = validator.export({ a: "ABC", b: 42 });
```

# defaultTypes
You can ```require("uberether-object-validator/lib/defaultTypes")``` to obtain a hash of type names to their object types.  If a schema specifies a string for the field type, then this value is used.

An object type is a JS object with up to 4 methods (all are optional):
- verify(x) - Returns true if x is valid, false otherwise
- parse(x) - Normalize values of x being parsed from external sources
- export(x) - Normalize values of x being exported to another system
- generate() - Generate a new value for x - must be already normalized for export

```js
var defaultTypes = require("uberether-object-validator/lib/defaultTypes");
defaultTypes.string4 = {
    verify: function(x) { return typeof x == "string" && x.length === 4; }
}
```

# defaultFieldTypes

You can ```require("uberether-object-validator/lib/defaultTypes")``` to obtain a hash of field names to their default types.  If a schema does not specify a type for a field, this value will be used.  Each one may be either a string referencing defaultTypes OR a object type.

You are encouraged to populate this list as sensible for your application.

```js
var defaultFieldTypes = require("uberether-object-validator/lib/defaultFieldTypes");
defaultFieldTypes.auth_time = "timestampSeconds"
```

# Schema structure

## Parse vs Export vs Common Options

All schema options may be specified for just parsing, just export, or common to both.  The schema root is common options, schema.parse are the parsing options, and schema.export are the export options.  This allows you to use separate options for inbound and outbound requests.  

For example: you may want to allow any value for inbound ids, but when sending them out they must be 10 character strings.

```js
var schema = {
	export: { fields: { id: "string10" } },
	parse: { fields: { id: "any" } }
}
```

## __default__
A special field name ```__default__``` may be used for specifying rules on any field not listed in the schema.

## schema.skip
If skip is set truthy, then all validation will be bypassed and the generated method will just return the input parameter.  The object will NOT be closed in this case.

## schema.allowAny
If set truthy, then by default any unspecified field will be allowed.  Unless specified, unrecognized fields will cause the validation to fail.

Specifying fields.__default__ will override this behavoir.

## schema.fields

A hash of all the fields at the top level of the object.  The key is the field name and the value is one of the following:
- A string representing the type from defaultTypes
- A object type object (see defaultTypes)
- A generated validator (for validating child objects)
- If none of the above are valid, then the type from defaultFieldTypes will be used.
- If no default field type is specified, then an error will be thrown.

## schema.pre(val, opts) and schema.post(val, opts)
An optional method to be called before or after validation.
- The first argument is the value (original for pre, processed for post)
- The second is the resolved schema for the object.  This can be used to obtain extra values for the validation.
- The function must return the value to use.

## schema.defaults
Default values to use for returned objects.  The validator clones the defaults and overwrites the values with ones from the input.

## schema.req
A hash specifying the required state of any fields. Valid values for a field are:
- true or "req": Field is required
- "gen": Field is required but may be generated if needed on export
- "genOpt": Field is optional on import but should be generated if needed on export
- "never": Field is never allowed
- Any other value indicates the field is optional (default)

You do NOT need to specify all (or any) fields in req - just specify fields that are not purely optional.

## schema.allowedValues and schema.disallowedValues
Hash of values allowed or disallowed for each field.  Key of the hash is the field name.  Value may be:
- A ```RegExp``` object.  Values will be tested using ```RegExp.test```.
- A function which takes the value as an argument and returns a truthy value if the value matches
- An array.  Array.indexOf is used to check the array for the object
- Otherwise, a simple ```===``` is done against the specified value.

If both allowedFields and disallowedFields are specified, then only allowedFields is used.

# Contributing

Any PRs are welcome but please stick to following the general style of the code and stick to [CoffeeScript](http://coffeescript.org/).  I know the opinions on CoffeeScript are...highly varied...I will not go into this debate here - this project is currently written in CoffeeScript and I ask you maintain that for any PRs.