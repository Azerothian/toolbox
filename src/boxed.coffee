Promise = require "bluebird"
Bookshelf = require "bookshelf"
knex = require "knex"
util = require "util"
Checkit = require "checkit"
log = require("./util").log


class Field
  constructor: () ->
    @validation = []
    @generation = {}
  #comparator: (func) =>
  #	@validation.comparator = func
  #	return @
  primary: (status = true) =>
    @generation.primary = status
    return @
  max_length: (len = 0) =>
    @generation.length = len
    @validation.push "maxLength:#{len}"
    return @
  min_length: (len = 0) =>
    @validation.min_length = len
    @validation.push "minLength:#{len}"
    return @
  required: () =>
    @validation.push "required"
    @generation.not_null = true
    return @
  number: () =>
    @validation.push "number"
    return @
  date: () =>
    @validation.push "date"
    return @
  boolean: () =>
    @validation.push "boolean"
    return @
  #choices: (arr = {}) =>
  #	@validation.choices = arr
  #	return @
  #comparator: (func) =>
  #	@validation.comparator = func
  #	return @


class StringField extends Field
  constructor: () ->
    super
    @name = "String"
  table_generator: (boxed ,table, tableName, fieldName, model) =>
    return table.string(fieldName, @generation.length)

class TextField extends Field
  constructor: () ->
    super
    @name = "Text"
  table_generator: (boxed, table, tableName, fieldName, model) ->
    return table.text(fieldName)

class IntField extends Field
  constructor: () ->
    super
    @name = "Int"
    @number()
  table_generator: (boxed, table, tableName, fieldName, model) ->
    return table.integer(fieldName)

class DateTimeField extends Field
  constructor: () ->
    super
    @name = "DateTime"
    @date()
  table_generator: (boxed, table, tableName, fieldName, model) ->
    return table.dateTime(fieldName)

class BooleanField extends Field
  constructor: () ->
    super
    @name = "Boolean"
    @boolean()
  table_generator: (boxed, table, tableName, fieldName, model) ->
    return table.boolean(fieldName)

class IncrementField extends Field
  constructor: () ->
    super
    @name = "Increment"
  table_generator: (boxed, table, tableName, fieldName, model) ->
    return table.increments(fieldName)

class HasManyField extends Field
  constructor: (@targetModelName) ->
    super
    @name = "HasMany"
  table_generator: (boxed ,table, tableName, fieldName, model) ->
    #return table.integer("#{fieldName}")
    return null
  orm_generator: (boxed, tableName, fieldName, dataModel, ormModel) =>
    targetModelName = @targetModelName
    return () ->
      return this.hasMany boxed.getModel(targetModelName),


class HasOneField extends Field
  constructor: (@targetModelName) ->
    super
    @name = "HasOne"
  table_generator: (boxed,table, tableName, fieldName, model) =>
    return table.integer("#{fieldName}_id")
  orm_generator: (boxed, tableName, fieldName, dataModel, ormModel) =>
    targetTableName = @targetModelName
    return () ->
      return this.hasOne boxed.getModel(targetTableName)

class BelongsToField extends Field
  constructor: (@targetModelName) ->
    super
    @name = "BelongsTo"
  table_generator: (boxed,table, tableName, fieldName, model) =>
    return table.integer("#{fieldName}_id")
  orm_generator: (boxed, tableName, fieldName, dataModel, ormModel) =>
    targetTableName = @targetModelName
    return () ->
      return this.belongsTo boxed.getModel(targetTableName)



class Boxed
  constructor: (@connection) ->
    @models = []
    if @connection?
      @config(@connection).then () =>


  config: (@connection) =>
    return new Promise (resolve, reject) =>
      if not @connection?
        throw "Boxed unable to continue, connection was not provided"
      @knex = knex @connection
      @db = Bookshelf @knex
      return resolve()

  getModel: (tableName) =>
    return @models[tableName]

  createModels: (models) =>
    return new Promise (resolve, reject) =>
      arr = []
      for m of models
        arr.push @createModel(models[m])
      return Promise.all(arr).then resolve, reject

  createModel: (model, options) =>
    return new Promise (resolve, reject) =>
      if not model.tableName?
        return reject("tableName was not set on the model provided")
      if not model.fields?
        return reject("fields was not set on the model provided")
      if @models[model.tableName]?
        return resolve @getNewModel(model.tableName, options)

      m = @db.Model
      ormModel = {
        tableName: model.tableName
      }
      validationModel = {}

      for fieldName of model.fields
        if model.fields[fieldName].orm_generator?
          ormModel[fieldName] = model.fields[fieldName].orm_generator(@, model.tableName, fieldName, model, ormModel)
        if model.fields[fieldName].validation.length > 0
          validationModel[fieldName] = model.fields[fieldName].validation

      checkit = new Checkit(validationModel)
      ormModel.save = (data) ->
        saveModel = this
        return new Promise (resolve, reject) ->
          return checkit.run(saveModel.attributes).then (validated) ->
            return m.prototype.save.apply(saveModel, [data])
              .then resolve,reject
              .catch reject
          .catch Checkit.Error, (err) ->
            #console.log(err.toJSON())
            return reject(err)

      @models[ormModel.tableName] = @db.Model.extend(ormModel)

      return resolve @getNewModel(ormModel.tableName, options)


  getNewModel: (tableName, options) =>
    return new @models[tableName](options)
  generateModels: (models) =>
    return new Promise (resolve, reject) =>
      arr = []
      for m of models
        arr.push @generateModel(models[m])
      return Promise.all(arr).then resolve, reject

  generateModel: (model) =>
    @knex.schema.dropTableIfExists(model.tableName).then () =>
      return @knex.schema.createTable model.tableName, (table) =>
        for fieldName of model.fields
          current = model.fields[fieldName]
          column = current.table_generator(@knex, table, model.tableName, fieldName, model)
          if column?
            if current.generation.primary?
              column.primary()
            if current.generation.not_null?
              column.notNullable()

Boxed.StringField = (data = {}) -> return new StringField(data)
Boxed.TextField = (data = {}) -> return new TextField(data)
Boxed.IntField = (data = {}) -> return new IntField(data)
Boxed.IncrementField = (data = {}) -> return new IncrementField(data)
Boxed.DateTimeField = (data = {}) -> return new DateTimeField(data)
Boxed.BooleanField = (data = {}) -> return new BooleanField(data)

Boxed.HasManyField = (data = {}) -> return new HasManyField(data)
Boxed.HasOneField = (data = {}) -> return new HasOneField(data)
Boxed.BelongsToField = (data = {}) -> return new BelongsToField(data)
module.exports = Boxed
