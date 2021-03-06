TableBase 	= require "./TableBase"
utils 		= require '../tools/utils'
TitleName 	= require "../title"

class BalanceSheet extends TableBase
	getFilePath: ->
		"allA/zcfzb_#{@_stockCode}"

	getFirstColTitle: ->
		TitleName.getBalanceTitle()

	getCashValue: -> @getValue(@_data["货币资金(万元)"])

	getTotalAssets: -> @getValue(@_data["资产总计(万元)"])

	getNetAssets: -> @getValue(@_data["归属于母公司股东权益合计(万元)"])

	_getNoNeedCalcItems: -> ["资料", "报告日期", "应收出口退税(万元)"]


	getReceivableValue: -> @getValue(@_data["应收账款(万元)"])

	getFixedAssets: -> @getValue(@_data["固定资产(万元)"])

	getInventory: -> @getValue(@_data["存货(万元)"])

	getStockHolderEquity: -> @getValue(@_data["所有者权益(或股东权益)合计(万元)"])

	getStaffPayment: ->
		valueTable = @getValue(@_data["应付职工薪酬(万元)"])
		return valueTable[0] - valueTable[1]

	

	_getTop10Key: ->
		totalAssets = @getTotalAssets()
		assetsPercentTable = {}
		for key , value of @_data
			continue if value[1] is 0
			continue if key in @_getNoNeedCalcItems()
			break if key is "资产总计(万元)"
			keyValue =  @getValue(value, null, true)[0]
			percent =  keyValue / totalAssets[0] * 100
			assetsPercentTable[key] = percent.toFixed(2)
		sortedObjKeys = Object.keys(assetsPercentTable).sort(
			(a, b) ->
				return assetsPercentTable[b] - assetsPercentTable[a]
		)
		console.log("key:#{JSON.stringify sortedObjKeys}")
		useAbleTable = []
		disAbleTable = ["固定资产净值(万元)", "固定资产原值(万元)", "未分配利润(万元)", "盈余公积(万元)", "资本公积(万元)", "少数股东权益(万元)", "实收资本(或股本)(万元)"]
		for key in sortedObjKeys
			continue if key.indexOf("计") isnt -1
			continue if key in disAbleTable
			useAbleTable.push key
		top10Key = useAbleTable.slice(0, 10)
		return top10Key

	getTop10: ->
		totalAssets = @getTotalAssets()
		assetsPercentTable = {}
		for key , value of @_data
			continue if value[0] is 0
			continue if key in @_getNoNeedCalcItems()
			percent = @getValue(value)[0] / totalAssets[0] * 100
			assetsPercentTable[key] = percent.toFixed(2)
		top10Key = @_getTop10Key()
		top10Info = []
		for key in top10Key
			top10Info.push key.slice(0, key.indexOf("(")) + ":" + assetsPercentTable[key] + '%'
		top10Info

	getCurrentRatio: ->
		currentAssetsTable = @getValue(@_data["流动资产合计(万元)"])
		currentDebtsTable = @getValue(@_data["流动负债合计(万元)"])
		currentRatio = []
		for currentAssets, index in currentAssetsTable
			currentRatio.push (currentAssets / currentDebtsTable[index]).toFixed(2)
		currentRatio

	getQuickRatio: ->
		currentAssetsTable = @getValue(@_data["流动资产合计(万元)"])
		currentDebtsTable = @getValue(@_data["流动负债合计(万元)"])
		inventoryTable = @getValue(@_data["存货(万元)"])
		quickRatio = []
		for currentAssets, index in currentAssetsTable
			quickRatio.push ((currentAssets - inventoryTable[index]) / currentDebtsTable[index]).toFixed(2)
		quickRatio
	
	_getAverageData: (dataTable) ->
		averageTable = []
		for value, index in dataTable
			break if index >= dataTable.length - 1
			averageData = (dataTable[index] + dataTable[index + 1]) / 2
			averageTable.push averageData
		averageTable
		
	getAverageInventoryTable: ->
		inventoryTable = @getValue(@_data["存货(万元)"])
		@_getAverageData(inventoryTable)

	getAveragePayable: ->
		payableTable = @getValue(@_data["应付账款(万元)"])
		@_getAverageData(payableTable)

	getAverageTotalAssets: ->
		totalAssetsTable = @getTotalAssets()
		@_getAverageData(totalAssetsTable)

	getInvestAssets: ->
		financial = @getValue(@_data["可供出售金融资产(万元)"])[0]
		endInvest = @getValue(@_data["持有至到期投资(万元)"])[0]
		longInvest = @getValue(@_data["长期股权投资(万元)"])[0]
		return ((financial + endInvest + longInvest) / @getTotalAssets()[0] * 100).toFixed(2)

	getGoodWill: ->
		goodWill = @getValue(@_data["商誉(万元)"])[0]
		goodWill

	

	getNetAssetsStruct: ->
		number1 = @getValue(@_data["实收资本(或股本)(万元)"])[0]
		number2 = @getValue(@_data["资本公积(万元)"])[0]
		number3 = @getValue(@_data["盈余公积(万元)"])[0]
		number4 = @getValue(@_data["未分配利润(万元)"])[0]

		result = (number3 + number4) / (number1 + number2)
		return result.toFixed(2)

	getTop10AllYearPercent: ->
		top10Key = @_getTop10Key()
		totalAssets = @getTotalAssets()
		top10ChangeInfo = []
		maxLength = 7
		totalPercentTable = []

		valueDisplayTable = []

		isAddLine = false

		for key in top10Key
			dataValue = @getValue(@_data[key])
			endPos = key.indexOf("(")
			key = key.slice(0, endPos)
			needLength = maxLength - key.length
			while needLength > 0
				key += "一"
				needLength--
			ratioTable = utils.getRatioTable(dataValue, totalAssets)
			for ratio, ratioIndex in ratioTable
				totalPercentTable[ratioIndex] ?= 0
				totalPercentTable[ratioIndex] += parseFloat(ratio)
				totalPercentTable[ratioIndex] = Math.floor(totalPercentTable[ratioIndex] * 100) / 100

			if ratioTable[0] < 5 and isAddLine is false
				top10ChangeInfo.push "-------------------------------------------------------------------------"
				top10ChangeInfo.push "一一总计一一一:#{utils.addTabInTable(totalPercentTable)}"
				top10ChangeInfo.push "-------------------------------------------------------------------------"
				isAddLine = true
			top10ChangeInfo.push key + ":" + utils.addTabInTable(ratioTable)
			valueDisplayTable.push key + ":" + utils.getValueDillion(dataValue)
		top10ChangeInfo.push "总计一一一一一:#{utils.addTabInTable(totalPercentTable)}"
		top10ChangeInfo.push "总资产增长率一:#{utils.addTabInTable(utils.getAddRatioTable(totalAssets))}"
		top10ChangeInfo.push valueDisplayTable
		return top10ChangeInfo

	
	#货币资金占比（15.92%）
	getCashValuePercent: ->
		cash = @getCashValue()
		chaiChuZiJing = @getValue(@_data["拆出资金(万元)"])
		cash = utils.addTable(cash, chaiChuZiJing)
		totalAssets = @getTotalAssets()
		utils.getRatioTable(cash, totalAssets)

	getYingShouPiaoJuPercent: ->
		singleData  = @getValue(@_data["应收票据(万元)"])
		totalAssetsTable = @getTotalAssets()
		utils.getRatioTable(singleData, totalAssetsTable)
	
	#交易性金融资产占比
	getStockAssetsInTotalAssets: ->
		stockAssets = @getValue(@_data["交易性金融资产(万元)"])
		totalAssetsTable = @getTotalAssets()
		utils.getRatioTable(stockAssets, totalAssetsTable)

	#应收账款
	getYingShouPercent: ->
		singleData  = @getValue(@_data["应收账款(万元)"])
		totalAssetsTable = @getTotalAssets()
		utils.getRatioTable(singleData, totalAssetsTable)
	#预付款项
	getYuFuPercent: ->
		singleData  = @getValue(@_data["预付款项(万元)"])
		totalAssetsTable = @getTotalAssets()
		utils.getRatioTable(singleData, totalAssetsTable)
	#其他应收款
	getQiTaYingShouPercent: ->
		singleData  = @getValue(@_data["其他应收款(万元)"])
		totalAssetsTable = @getTotalAssets()
		utils.getRatioTable(singleData, totalAssetsTable)
	#存货
	getChunHuoPercent: ->
		singleData  = @getValue(@_data["存货(万元)"])
		totalAssetsTable = @getTotalAssets()
		utils.getRatioTable(singleData, totalAssetsTable)
	#长期股权投资
	getChangeQiGuQuanPercent: ->
		singleData  = @getValue(@_data["长期股权投资(万元)"])
		totalAssetsTable = @getTotalAssets()
		utils.getRatioTable(singleData, totalAssetsTable)
	#固定资产占比
	getFixedAssetsWithTotalAssetsRatio: ->
		fixedAssetsTable = @getFixedAssets()
		totalAssetsTable = @getTotalAssets()
		utils.getRatioTable(fixedAssetsTable, totalAssetsTable)
	#在建工程
	getZaiJiangPercent: ->
		singleData  = @getValue(@_data["在建工程(万元)"])
		totalAssetsTable = @getTotalAssets()
		utils.getRatioTable(singleData, totalAssetsTable)
	#无形资产
	getWuXingPercent: ->
		singleData  = @getValue(@_data["无形资产(万元)"])
		totalAssetsTable = @getTotalAssets()
		utils.getRatioTable(singleData, totalAssetsTable)
	#商誉
	getShangYuPercent: ->
		singleData  = @getValue(@_data["商誉(万元)"])
		totalAssetsTable = @getTotalAssets()
		utils.getRatioTable(singleData, totalAssetsTable)
	#长期待摊费用
	getChangQiDaiTanPercent: ->
		singleData  = @getValue(@_data["长期待摊费用(万元)"])
		totalAssetsTable = @getTotalAssets()
		utils.getRatioTable(singleData, totalAssetsTable)
	#其他非流动资产
	getQiTaFeiLiuDongPercent: ->
		singleData  = @getValue(@_data["其他非流动资产(万元)"])
		totalAssetsTable = @getTotalAssets()
		utils.getRatioTable(singleData, totalAssetsTable)
	#短期借款
	getDuanQiJieKuanPercent: ->
		singleData  = @getValue(@_data["短期借款(万元)"])
		totalAssetsTable = @getTotalAssets()
		utils.getRatioTable(singleData, totalAssetsTable)
	#应付账款
	getYingFuPercent: ->
		singleData  = @getValue(@_data["应付账款(万元)"])
		totalAssetsTable = @getTotalAssets()
		utils.getRatioTable(singleData, totalAssetsTable)
	#预收账款占比
	
	getAdvanceReceiptsPercent: ->
		advanceReceiptsTable = @getValue(@_data["预收账款(万元)"])
		totalAssetsTable = @getTotalAssets()
		utils.getRatioTable(advanceReceiptsTable, totalAssetsTable)
	#其他应付款
	getQiTaYingFuPercent: ->
		singleData  = @getValue(@_data["其他应付款(万元)"])
		totalAssetsTable = @getTotalAssets()
		utils.getRatioTable(singleData, totalAssetsTable)
	#长期借款
	getChangeQiJieKuanPercent: ->
		singleData  = @getValue(@_data["长期借款(万元)"])
		totalAssetsTable = @getTotalAssets()
		utils.getRatioTable(singleData, totalAssetsTable)
	#未分配利润
	getWeiFenPeiPercent: ->
		singleData  = @getValue(@_data["未分配利润(万元)"])
		totalAssetsTable = @getTotalAssets()
		utils.getRatioTable(singleData, totalAssetsTable)
	#权益乘数
	getFinancialLeverage: ->
		totalAssetsTable = @getTotalAssets()
		netAssets = @getStockHolderEquity()
		utils.getRatioTable(totalAssetsTable, netAssets, 1)

	#有息负债占比
	getInterestDebt: ->
		value1 = @getValue(@_data["短期借款(万元)"])
		value2 = @getValue(@_data["长期借款(万元)"])
		value3 = @getValue(@_data["应付债券(万元)"])
		totalAssets = @getTotalAssets()
		debtTable = []
		for data, index in value1
			debtTable.push value1[index] + value2[index] + value3[index]
		utils.getRatioTable(debtTable, totalAssets)

	#负债合计
	getFuZhaiHeJi: ->
		value1 = @getValue(@_data["负债合计(万元)"])
		totalAssets = @getTotalAssets()
		utils.getRatioTable(value1, totalAssets)
	

module.exports = BalanceSheet