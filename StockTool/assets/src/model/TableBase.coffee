StockInfoTable = require '../StockInfoTable'
global = require "../globalValue"
utils = require '../tools/utils'

class TableBase
	constructor: (@_stockCode)->
		@_data = null
		@_stockInfo = []
		@_dataObj = {}
		@_setStockInfo()
		@_loadJson()

	getFilePath: ->

	getFirstColTitle: ->

	getStockCode: -> @_stockCode

	getExistYears: -> @_existYears

	isLoadFinish: -> @_data?

	_loadJson: ->
		filePath = @getFilePath()
		cc.loader.loadRes(filePath, (error, data)=>
			if error?
				console.log("load #{@_stockCode} failed !!")
				@_setLoadStatus()
				return
			dataTable = utils.csvToArray(data)
			@_data = dataTable
			@_data.unshift(@_stockInfo)
			@_initTable(@getFirstColTitle())
			@_setLoadStatus()
		)

	_setLoadStatus: ->
		global.count += 1
		if global.count is 3
			global.count = 0
			global.canLoad = true
		return

	_initTable: (title)->
		@_replaceFirstColTitle(title)
		@_replaceNullCell()
		@_changeToObj()

	_replaceFirstColTitle : (title)->
		for item, index in @_data
			item[0] = title[index]
		return

	_replaceNullCell: ->
		for item, index in @_data
			for value, count in item
				if value is "--"
					item[count] = 0
		return

	_changeToObj: ->
		for item in @_data
			continue unless item[0]?
			@_dataObj[item[0]] = item.slice(1, item.length)
		@_data = @_dataObj

	getStockName: -> @_data["资料"][0]

	getBaseInfo: -> @_stockCode + "------" + @_data["资料"][0] + "------" + @_data["资料"][2] + "------财报时间" + @getTimeTitle()[0]

	getStockInfo: -> @_data["资料"][0]

	getIndustry: -> @_data["资料"][2]

	getSharePrice: -> @_data["资料"][1]

	getTotalMarketValue: -> @_data["资料"][3]

	_getShowNumber : (number)->
		return "#{(number / 100000).toFixed(2)} 亿"

	getFormatNumberTable: (numberTable)->
		formatTable = []
		for number in numberTable
			formatTable.push @_getShowNumber(number)
		return formatTable

	_getYearValueIndex: (isOnlyYear) ->
		indexTable = []
		isOnlyYear = true
		for timeStr, index in @_data["报告日期"]
			if timeStr.indexOf("12-31") isnt -1
				indexTable.push(index)
		return indexTable if isOnlyYear
		if @_data["报告日期"][0].indexOf("12-31") is -1
			indexTable.unshift 0
		return indexTable

	_getValueLength: (valueLength)->
		if valueLength < global.year
			length = valueLength
		else
			length = global.year
		@_existYears = length
		length

	_formatToInt: (valueTable)->
		intTable = []
		for value in valueTable
			intTable.push parseInt(value)
		return intTable

	getValue: (data, doNotToInt, isOnlyYear)->
		return unless data?
		yearIndexTable = @_getYearValueIndex(isOnlyYear)
		valueTable = []

		for index in yearIndexTable
			valueTable.push data[index]

		valueTable = valueTable.slice(0, @_getValueLength(valueTable.length))
		if doNotToInt
			return valueTable
		return @_formatToInt(valueTable)

	_setStockInfo: ->
		infoTable = StockInfoTable.getAllA()
		for info in infoTable
			if info[0].indexOf("" + @_stockCode) isnt -1
				for value in info
					@_stockInfo.push value
				break
		return

	getTimeTitle: ->
		indexTable = @_getYearValueIndex()
		timeTable = []
		for index in indexTable
			timeTable.push @_data["报告日期"][index]
		timeTable = timeTable.slice(0, @_getValueLength(timeTable.length))
		yearTable = []
		for time in timeTable
			yearTable.push "[#{time.slice(0, 7)}]"
		return yearTable

module.exports = TableBase