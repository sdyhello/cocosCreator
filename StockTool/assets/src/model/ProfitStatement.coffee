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

	getProfitTotal: -> @getValue(@_data["利润总额(万元)"])

	getIncomeProfit: -> @getValue(@_data["营业利润(万元)"])

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
			addRatio.push ((profit - profitTable[index + 1]) / profitTable[index + 1] * 100).toFixed(2)
		addRatio

	getNetProfitRatio: ->
		netProfit = @getNetProfitAllTable()
		incomeValue = @getIncomeValue()
		utils.getRatioTable(netProfit, incomeValue)

	getGrossProfitRatio: ->
		incomeValueTable = @getIncomeValue()
		operatingCostsTable = @getOperatingCosts()
		grossProfitRatioTable = []
		for incomeValue, index in incomeValueTable
			grossProfitRatio = ((incomeValue - operatingCostsTable[index]) / incomeValue * 100).toFixed(2)
			grossProfitRatioTable.push grossProfitRatio
		grossProfitRatioTable

	getPE: ->
		earnPerShare = @getValue(@_data["基本每股收益"], true)[0]
		price = @getSharePrice()
		PE = (price / earnPerShare).toFixed(2)
		PE

	getCoreProfit: ->
		a = @getValue(@_data["营业收入(万元)"])
		b = @getValue(@_data["营业成本(万元)"])
		c = @getValue(@_data["营业税金及附加(万元)"])
		d = @getValue(@_data["销售费用(万元)"])
		e = @getValue(@_data["管理费用(万元)"])
		f = @getValue(@_data["财务费用(万元)"])
		coreProfitTable = []
		for value, index in a
			operatingProfit = a[index] - b[index] - c[index] - d[index] - e[index] - f[index]
			coreProfitTable.push operatingProfit
		
		return coreProfitTable

	getOperatingProfitRatio: ->
		coreProfit = @getCoreProfit()[0]
		a = @getValue(@_data["营业收入(万元)"])[0]
		operatingProfitRatio = ((coreProfit / a ) * 100).toFixed(2)
		operatingProfitRatio

	getCoreProfitRatio: ->
		totalProfit = @getProfitTotal()[0]
		coreProfit = @getCoreProfit()[0]
		coreProfitRatio = (coreProfit / totalProfit * 100 ).toFixed(2)
		coreProfitRatio

	getExpenseRatio: ->
		sellingFeeTable = @getValue(@_data["销售费用(万元)"])
		manageFeeTable = @getValue(@_data["管理费用(万元)"])
		moneyFeeTable = @getValue(@_data["财务费用(万元)"])
		incomeValueTable = @getValue(@_data["营业收入(万元)"])

		expenseRatioTable = []
		for incomeValue, index in incomeValueTable
			totalFee = sellingFeeTable[index] + manageFeeTable[index] + moneyFeeTable[index]
			expenseRatio = (totalFee / incomeValue * 100).toFixed(2)
			expenseRatioTable.push expenseRatio
		expenseRatioTable

	getOperatingProfitAddRatio: ->
		coreProfitTable = @getIncomeProfit()
		ratioTable = []
		for value, index in coreProfitTable
			break if index >= coreProfitTable.length - 1
			ratio = ((value - coreProfitTable[index + 1]) / coreProfitTable[index + 1] * 100).toFixed(2)
			ratioTable.push ratio
		return ratioTable

	getSellingFeeRatio: ->
		sellingFeeTable = @getValue(@_data["销售费用(万元)"])
		incomeValueTable = @getValue(@_data["营业收入(万元)"])
		utils.getRatioTable(sellingFeeTable, incomeValueTable)

	getManageFeeRatio: ->
		manageFeeTable = @getValue(@_data["管理费用(万元)"])
		incomeValueTable = @getValue(@_data["营业收入(万元)"])
		utils.getRatioTable(manageFeeTable, incomeValueTable)

	getMoneyFeeRatio: ->
		moneyFeeTable = @getValue(@_data["财务费用(万元)"])
		incomeValueTable = @getValue(@_data["营业收入(万元)"])
		utils.getRatioTable(moneyFeeTable, incomeValueTable)

	getIncomeValueAddRatio: ->
		incomeValueTable = @getIncomeValue()
		ratioTable = []
		for value, index in incomeValueTable
			break if index >= incomeValueTable.length - 1
			ratio = ((value - incomeValueTable[index + 1]) / incomeValueTable[index + 1] * 100).toFixed(2)
			ratioTable.push ratio
		return ratioTable

module.exports = ProfitStatement