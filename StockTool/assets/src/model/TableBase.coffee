StockInfoTable = require '../StockInfoTable'
global = require "../globalValue"

class TableBase
	constructor: (@_stockCode)->
		@_data = null
		@_stockInfo = []
		@_dataObj = {}
		@_setStockInfo()
		@_setStockInfoFromCsv()
		@_loadJson()

	getFilePath: ->

	getFirstColTitle: ->

	getStockCode: -> @_stockCode

	getExistYears: -> @_existYears

	isLoadFinish: -> @_data?

	_loadJson: ->
		filePath = @getFilePath()
		cc.loader.loadRes(filePath, (error, data)=>
			unless data?
				console.log("load #{@_stockCode} failed !!")
			dataTable = @_csvToArray(data)
			@_data = dataTable
			@_data.unshift(@_stockInfo)
			@_initTable(@getFirstColTitle())
			global.count += 1
			if global.count is 3
				global.count = 0
				global.canLoad = true
		)

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

	_csvToArray : (strData, strDelimiter )->
	    strDelimiter = (strDelimiter || ",");
	    objPattern = new RegExp(
	        (
	            "(\\" + strDelimiter + "|\\r?\\n|\\r|^)" +
	            "(?:\"([^\"]*(?:\"\"[^\"]*)*)\"|" +
	            "([^\"\\" + strDelimiter + "\\r\\n]*))"
	            ),
	        "gi"
	    )
	    arrData = [[]];
	    arrMatches = null;
	    while (arrMatches = objPattern.exec( strData ))
	        strMatchedDelimiter = arrMatches[ 1 ]
	        if (strMatchedDelimiter.length &&(strMatchedDelimiter != strDelimiter))
	            arrData.push( [] );
	        if (arrMatches[ 2 ])
	            strMatchedValue = arrMatches[ 2 ].replace(new RegExp( "\"\"", "g" ),"\"")
	        else
	            strMatchedValue = arrMatches[ 3 ];
	        arrData[ arrData.length - 1 ].push( strMatchedValue );
	    return arrData

	getStockName: -> @_data["资料"][0]

	getBaseInfo: -> @_stockCode + "------" + @_data["资料"][0] + "------" + @_data["资料"][2]

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

	_getYearValueIndex: ->
		indexTable = []
		for timeStr, index in @_data["报告日期"]
			if timeStr.indexOf("12-31") isnt -1
				indexTable.push(index)
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

	getValue: (data, doNotToInt)->
		return unless data?
		yearIndexTable = @_getYearValueIndex()
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

	_setStockInfoFromCsv: ->
		unless @_priceCsvInfo
			cc.loader.loadRes("price", (error, data)=>
				unless data?
					console.log("load #{@_stockCode} failed !!")
				@_priceCsvInfo = @_csvToArray(data)
				console.log("_priceCsvInfo:#{JSON.stringify @_priceCsvInfo}")
			)
		unless @_priceCsvInfo?
			console.log("_setStockInfoFromCsv is null")
			return
		for info in @_priceCsvInfo
			if info[0].indexOf("" + @_stockCode) isnt -1
				for value in info
					@_stockInfo.push value
				break
		return
		
module.exports = TableBase