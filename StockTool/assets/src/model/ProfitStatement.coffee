TableBase 	= require "./TableBase"
utils 		= require '../tools/utils'
TitleName 	= require "../title"
global = require "../globalValue"

class ProfitStatement extends TableBase
	getFilePath: ->
		"allA/lrb_#{@_stockCode}"

	getFirstColTitle: ->
		TitleName.getProfitTitle()

	getIncomeValue: -> @getValue(@_data["营业收入(万元)"])

	getOperatingCosts: -> @getValue(@_data["营业成本(万元)"])

	getNetProfitAddRatio: ->
		netProfitTable = @getNetProfitTable()
		addTimes = netProfitTable[0] / netProfitTable[netProfitTable.length - 1]
		addRatio = utils.getCompoundRate(addTimes, global.year)
		addRatio = ((addRatio - 1) * 100).toFixed(2)
		addRatio

	getNetProfitTable : ->
		@getValue(@_data["归属于母公司所有者的净利润(万元)"])

	getNetProfitAllTable : ->
		@getValue(@_data["净利润(万元)"])

	getNetProfitYoy: ->
		profitTable = @getNetProfitTable()
		addRatio = []
		for profit, index in profitTable
			break if index >= profitTable.length - 1
			addRatio.push ((profit - profitTable[index + 1]) / profitTable[index + 1] * 100).toFixed(2) + "%"
		addRatio

	getSingleYearNetProfitRatio: ->
		netProfit = @getNetProfitAllTable()[0]
		incomeValue = @getIncomeValue()[0]
		netProfitRatio = (netProfit / incomeValue * 100).toFixed(2)
		netProfitRatio

	getSingleYearGrossProfitRatio: ->
		incomeValue = @getIncomeValue()[0]
		operatingCosts = @getOperatingCosts()[0]
		grossProfitRatio = ((incomeValue - operatingCosts) / incomeValue * 100).toFixed(2)
		grossProfitRatio

	getPE: ->
		earnPerShare = @getValue(@_data["基本每股收益"], true)[0]
		price = @getSharePrice()
		PE = (price / earnPerShare).toFixed(2)
		PE

	getOperatingProfitRatio: ->
		a = @getValue(@_data["营业收入(万元)"])[0]
		b = @getValue(@_data["营业成本(万元)"])[0]
		c = @getValue(@_data["营业税金及附加(万元)"])[0]
		d = @getValue(@_data["销售费用(万元)"])[0]
		e = @getValue(@_data["管理费用(万元)"])[0]
		f = @getValue(@_data["财务费用(万元)"])[0]
		operatingProfit = a - b - c - d - e - f
		operatingProfitRatio = ((operatingProfit / a ) * 100).toFixed(2)
		operatingProfitRatio


module.exports = ProfitStatement