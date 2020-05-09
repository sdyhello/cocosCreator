BalanceSheet    = require '../model/BalanceSheet'
ProfitStatement    = require '../model/ProfitStatement'
CashFlowStatement    = require '../model/CashFlowStatement'
utils = require '../tools/utils'
global = require "../globalValue"
StockInfoTable = require '../StockInfoTable'
cc.Class {
    extends: cc.Component

    properties: {
        # foo:
        #   default: null      # The default value will be used only when the component attaching
        #                        to a node for the first time
        #   type: cc
        #   serializable: true # [optional], default is true
        #   visible: true      # [optional], default is true
        #   displayName: 'Foo' # [optional], default is property name
        #   readonly: false    # [optional], default is false
        m_info : cc.Label,
        m_input_code: cc.EditBox,
        m_input_time: cc.EditBox,
        m_tips: cc.Label,
        m_query_node: cc.Node,
        m_industry_node: cc.Node,
        m_industry_info: cc.Label,
        m_baseInfo_node: cc.Node,
        m_baseInfo_info: cc.Label,
    }
 
    onLoad: ->
        @_init()
        @_addEditBoxEventHandler(@m_input_code, "code")
        @_addEditBoxEventHandler(@m_input_time, "time")
    _init: ->
        @m_query_node.active = true
        @m_industry_node.active = false
        @m_baseInfo_node.active = false
        TDGA?.onEvent("query")
        cocosAnalytics?.CAEvent?.onEvent({eventName:"打开查询界面"})
        @_balanceObj = {}
        @_profitObj = {}
        @_cashFlowObj = {}
        @_industryInfo = {}
        @_stockCode = cc.sys.localStorage.getItem("stockCode_new") or "600519"
        @m_input_time.placeholder = global.year
        @m_input_code.placeholder = @_stockCode

    _addEditBoxEventHandler: (editboxObj, type)->
        editboxEventHandler = new cc.Component.EventHandler()
        editboxEventHandler.target = @node
        editboxEventHandler.component = "query"
        editboxEventHandler.handler = "onTextChanged"
        editboxEventHandler.customEventData = type
        editboxObj.editingDidEnded.push(editboxEventHandler)

    onTextChanged: (editbox, customEventData)->
        if customEventData is "code"
            if editbox.string isnt ""
                @_stockCode = editbox.string
        else if customEventData is "time"
            year = parseInt(editbox.string)
            if isNaN(year)
                return
            global.year = year
        return

    onReturn: ->
        stockInfo = []
        @m_info.string = @_lookAllStock(stockInfo)
        # cc.director.loadScene('welcome')

    onLookIndustryInfo: ->
        TDGA?.onEvent("lookIndustryInfo")
        cocosAnalytics?.CAEvent?.onEvent({eventName:"查看行业对比"})
        @m_query_node.active = false
        @m_industry_node.active = true
        @m_baseInfo_node.active = false
        @onClickButton()
        stockCode = @_stockCode
        @_getIndustryAverage(stockCode, "预收账款")
        @_getIndustryAverage(stockCode, "应收账款")
        @_getIndustryAverage(stockCode, "存货")
        @_getIndustryAverage(stockCode, "应付账款")
        @_getIndustryAverage(stockCode, "现金周转")
        @_getIndustryAverage(stockCode, "毛利率")
        @_getIndustryAverage(stockCode, "净利率")
        @_getIndustryAverage(stockCode, "核心利润率")
        @_getIndustryAverage(stockCode, "费用率")
        @_getIndustryAverage(stockCode, "平均月薪")
        @m_industry_info.string = JSON.stringify(@_industryInfo, null, 4)

    onIndustryReturn: ->
        @m_query_node.active = true
        @m_industry_node.active = false
        @m_baseInfo_node.active = false

    onLookBaseInfo: ->
        TDGA?.onEvent("lookCoreInfo", {"info": @_profitObj[@_stockCode]?.getBaseInfo()})
        @m_query_node.active = false
        @m_industry_node.active = false
        @m_baseInfo_node.active = true
        @_getBaseInfo()

    onBaseInfoReturn: ->
        @m_query_node.active = true
        @m_industry_node.active = false
        @m_baseInfo_node.active = false

    onClickButton: ->
        if isNaN(Number(@_stockCode)) or @_stockCode is ""
            if @_queryByName(@_stockCode) and @_stockCode isnt ""
                cc.sys.localStorage.setItem("stockCode_new", @_stockCode)
                info = @getStockDetailInfo(@_stockCode)
                @m_info.string = info
            else
                @m_info.string = "\n\n\n请输入数字的股票代码,或正确的股票名称，不能含有其他符号"
        else if @isStockExist(@_stockCode)
            cc.sys.localStorage.setItem("stockCode_new", @_stockCode)
            info = @getStockDetailInfo(@_stockCode)
            @m_info.string = info
        else
            @m_info.string = "你输入的股票代码在系统中不存在，请检查重新输入。"

    _queryByName: (name)->
        infoTable = StockInfoTable.getAllA()
        for info in infoTable
            if info[1].indexOf(name) isnt -1
                @_stockCode = info[0].slice(2, 8)
                console.log("stockCode:#{@_stockCode}, type:#{typeof @_stockCode}")
                return true
        return false

    isStockExist: (stockCode)->
        stockTable = utils.getStockTable("allA")
        for stock in stockTable
            if stock.indexOf("" + stockCode) isnt -1
                return true
        return false

    _getAdvanceReceiptsPercent: (stockCode)->
        return @_balanceObj[stockCode].getAdvanceReceiptsPercent()[0]

    _getReceivableTurnOverDays: (stockCode)->
        ratioTable = @_getRecievableTurnRatio(stockCode)
        daysTable = []
        for ratio in ratioTable
            daysTable.push (360 / ratio).toFixed(2)
        return daysTable

    _getRecievableTurnRatio: (stockCode) ->
        receivableValueTable = @_balanceObj[stockCode].getReceivableValue()
        inComeValueTable = @_profitObj[stockCode].getIncomeValue()
        daysTable = []
        for receivable, index in receivableValueTable
            averageRecievable = (receivableValueTable[index] + receivableValueTable[index + 1]) / 2
            day = (inComeValueTable[index] / averageRecievable).toFixed(2)
            daysTable.push day
        return daysTable

    _isAllTableLoadFinish: (stockCode)->
        balance = @_balanceObj[stockCode]?.isLoadFinish()
        profit = @_profitObj[stockCode]?.isLoadFinish()
        cashFlow = @_cashFlowObj[stockCode]?.isLoadFinish()
        return balance and profit and cashFlow

    _getROE: (stockCode)->
        netAssetsTable = @_balanceObj[stockCode].getNetAssets()
        netProfitsTable = @_profitObj[stockCode].getNetProfitTable()
        roeTable = []
        for netAssets, index in netAssetsTable
            break if index >= netAssetsTable.length - 1
            roe = ((netProfitsTable[index] / ((netAssets + netAssetsTable[index + 1]) / 2)) * 100).toFixed(2)
            roeTable.push roe + "\t"
        return roeTable

    _loadFileToObj: (stockCode)->
        @_balanceObj[stockCode] = new BalanceSheet(stockCode)
        @_profitObj[stockCode] = new ProfitStatement(stockCode)
        @_cashFlowObj[stockCode] = new CashFlowStatement(stockCode)

    getStockDetailInfo: (stockCode)->
        infoTable = []
        unless @_isAllTableLoadFinish(stockCode)
            @_loadFileToObj(stockCode)
            return "\n\n\n\n\n\n\t\t\t\t\t加载了------#{stockCode}------所需文件，请重新点击----“获取信息”-----来查看信息！"
        infoTable.push "基本信息:   " + @_profitObj[stockCode].getBaseInfo()
        # infoTable.push "\n折现估值：#{@_getArkadValuePercent(stockCode)}, #{@_getIndustryAverage(stockCode, "估值比")}"
        infoTable.push "\nPE:   " + @_profitObj[stockCode].getPE() + "\t对应股价:#{@_profitObj[stockCode].getSharePrice()}"
        infoTable.push "\n总资产：#{utils.getValueDillion(@_balanceObj[stockCode].getTotalAssets()[0])}"
        infoTable.push "\n总市值：#{utils.getValueDillion(@_balanceObj[stockCode].getTotalMarketValue() / 10000)}"
        # infoTable.push "\n资产负债表Top10: #{@_balanceObj[stockCode].getTop10()}"
        @_getScore(stockCode, infoTable)
        infoTable.push "\n投资性资产占比: " + @_balanceObj[stockCode].getInvestAssets() + "%"
        infoTable.push "\n有息负债: #{@_balanceObj[stockCode].getInterestDebt()[0]}%"
        infoTable.push "\n资本开支占净利润比：#{@_getCapitalExpenditureRatio(stockCode)}%"
        infoTable.push "\n赚的钱是从股东那拿的钱的几倍：#{@_balanceObj[stockCode].getNetAssetsStruct()}"
        infoTable.push "\n商誉:#{utils.getValueDillion(@_balanceObj[stockCode].getGoodWill())}, 占总资产比例:#{@_getGoodWillPercent(stockCode)}%"
        infoTable.push "\n预收账款占总资产比例: #{@_getAdvanceReceiptsPercent(stockCode)}%"
        infoTable.push "\n应收账款周转天数: #{@_getReceivableTurnOverDays(stockCode)[0]}"
        infoTable.push "\n存货周转天数:#{@_getInventoryTurnoverDays(stockCode)[0]}天"
        infoTable.push "\n应付账款周转天数:#{@_getPayableTurnoverDays(stockCode)[0]} 天"
        infoTable.push "\n现金周转天数：#{@_getCashTurnoverDays(stockCode)} 天"
        infoTable.push "\n净利润（多）： " + utils.getValueDillion(@_profitObj[stockCode].getNetProfitTable())
        infoTable.push "\n毛利率（单）: #{@_profitObj[stockCode].getGrossProfitRatio()[0]}"
        infoTable.push "\n净利率（单）: #{@_profitObj[stockCode].getNetProfitRatio()[0]}"
        infoTable.push "\n核心利润率 : #{@_profitObj[stockCode].getOperatingProfitRatio()[0]} %" 
        infoTable.push "\n核心利润占利润总额比例:#{@_profitObj[stockCode].getCoreProfitRatio()} %"
        infoTable.push "\n 三项费用率：#{@_profitObj[stockCode].getExpenseRatio()[0]} %"
        infoTable.push "\n年净利润增长率:   " + @_profitObj[stockCode].getNetProfitYoy()
        infoTable.push "\n净利润复合增长率:   " + @_profitObj[stockCode].getNetProfitAddRatio() + "%"
        infoTable.push "\n营收含金量: #{@_getIncomeQuality(stockCode)}, 平均：#{utils.getAverage(@_getIncomeQuality(stockCode))}"
        infoTable.push "\n现金流量比净利润:   " + @_getNetProfitQuality(stockCode) + "平均:#{utils.getAverage(@_getNetProfitQuality(stockCode))}"
        infoTable.push "\n历年ROE:   " + @_getROE(stockCode) + "平均: #{utils.getAverage(@_getROE(stockCode))}%"
        infoTable.push "\nROE分解----->净利率: #{@_profitObj[stockCode].getNetProfitRatio()[0]}, 总资产周转率:#{@_getTotalAssetsTurnoverRatio(stockCode)[0]}, 财务杠杆:#{@_balanceObj[stockCode].getFinancialLeverage()[0]}"
        infoTable.push "\n" + @_getStaffInfo(stockCode)
        infoTable.push "\n统计时间： #{@_balanceObj[stockCode].getExistYears()}"
        
        TDGA?.onEvent("queryStockInfo", {"info": @_profitObj[stockCode].getBaseInfo()})
        cocosAnalytics?.CAEvent?.onEvent({eventName:"查询个股", info: @_profitObj[stockCode].getBaseInfo()})
        
        console.log(infoTable)
        infoTable

    _getStaffInfo: (stockCode, isGetNumber)->
        staffNumber = 0
        staffInfoTable = StockInfoTable.getStaffInfo()
        for staffInfo in staffInfoTable
            if(staffInfo[0].indexOf(stockCode) isnt -1)
                staffNumber = staffInfo[2]
                break
        @_getAllPayStaffMoney(stockCode, staffNumber, isGetNumber)

    _getAllPayStaffMoney: (stockCode, staffNumber, isGetNumber)->
        value1 = @_balanceObj[stockCode].getStaffPayment()
        value2 = @_cashFlowObj[stockCode].getPayStaffCash()
        totalValue = value1 + value2
        average = (totalValue / staffNumber / 12).toFixed(2)
        string = "薪酬总额：#{utils.getValueDillion(totalValue)}，占净利润比例：#{(totalValue / @_profitObj[stockCode].getNetProfitTable()[0]).toFixed(2)}，员工人数：#{staffNumber}人, 平均月薪：#{average}万元"
        if isGetNumber
            return average
        return string

    _getNetProfitQuality: (stockCode)->
        netProfitTable = @_profitObj[stockCode].getNetProfitTable()
        workCashFlowTable = @_cashFlowObj[stockCode].getWorkCashFlow()
        ratioTable = []
        for netProfit , index in netProfitTable
            ratioTable.push (workCashFlowTable[index] / netProfit * 100).toFixed(2)
        ratioTable

    _getReceivableInIncomeRatio: (stockCode) ->
        receivableTable = @_balanceObj[stockCode].getReceivableValue()
        incomeValueTable = @_profitObj[stockCode].getIncomeValue()
        utils.getRatioTable(receivableTable, incomeValueTable)

    _getIncomeQuality: (stockCode) ->
        incomeValueTable = @_profitObj[stockCode].getIncomeValue()
        sellGoodsGetMoneyTable = @_cashFlowObj[stockCode].getSellGoodsMoney()
        utils.getRatioTable(sellGoodsGetMoneyTable, incomeValueTable)

    _getInventoryTurnoverDays: (stockCode) ->
        inventoryRatioTable = @_getInventoryTurnoverRatio(stockCode)
        daysTable = []
        for ratio in inventoryRatioTable
            daysTable.push (360 / ratio).toFixed(2)
        return daysTable

    _getInventoryTurnoverRatio: (stockCode) ->
        averageInventory = @_balanceObj[stockCode].getAverageInventoryTable()
        operatingCosts = @_profitObj[stockCode].getOperatingCosts()
        utils.getRatioTable(operatingCosts, averageInventory, 1)

    _getPayableTurnoverRatio: (stockCode) ->
        averagePayable = @_balanceObj[stockCode].getAveragePayable()
        operatingCosts = @_profitObj[stockCode].getOperatingCosts()
        utils.getRatioTable(operatingCosts, averagePayable, 1)

    _getPayableTurnoverDays: (stockCode) ->
        payableRatioTable = @_getPayableTurnoverRatio(stockCode)
        daysTable = []
        for ratio in payableRatioTable
            daysTable.push (360 / ratio).toFixed(2)
        return daysTable

    _getCashTurnoverDays: (stockCode) ->
        receivableTurnoverDays = @_getReceivableTurnOverDays(stockCode)[0]
        inventoryTurnoverDays = @_getInventoryTurnoverDays(stockCode)[0]
        payableTurnoverDays = @_getPayableTurnoverDays(stockCode)[0]
        cashTurnoverDays = parseFloat(receivableTurnoverDays) + parseFloat(inventoryTurnoverDays) - parseFloat(payableTurnoverDays)
        cashTurnoverDays.toFixed(2)

    _getTotalAssetsTurnoverRatio: (stockCode) ->
        averageTotalAssets = @_balanceObj[stockCode].getAverageTotalAssets()
        inComeValueTable = @_profitObj[stockCode].getIncomeValue()
        utils.getRatioTable(inComeValueTable, averageTotalAssets, 1)

    _getCapitalExpenditureRatio: (stockCode) ->
        capitalExpenditure = @_cashFlowObj[stockCode].getCapitalExpenditure()
        netProfit = @_profitObj[stockCode].getNetProfitAllTable()
        captialSummation = utils.getSummation(capitalExpenditure)
        netProfitSummation = utils.getSummation(netProfit)
        return (captialSummation / netProfitSummation * 100).toFixed(2)

    _getAssetsPercent: (stockCode) ->
        assetsNameTable = ["货币资金", "应收票据", "应收账款", "交易性金融资产", "预付款项", "其他应收款", "存货",
            "长期股权投资", "固定资产", "在建工程", "无形资产", "商誉", "长期待摊费用",
            "其他非流动资产", "短期借款", "应付账款", "预收账款", "其他应付款", "长期借款",
            "未分配利润", "权益乘数", "有息负债", "营收含金量", "核心利润占比", "ROE"
            ]
        for assetName in assetsNameTable
            @_assetsTotalObject[assetName] ?= []
            switch assetName
                when "货币资金"
                    assets = Number(@_balanceObj[stockCode].getCashValuePercent()[0])
                when "应收票据"
                    assets = Number(@_balanceObj[stockCode].getYingShouPiaoJuPercent()[0])
                when "应收账款"
                    assets = Number(@_balanceObj[stockCode].getYingShouPercent()[0])
                when "交易性金融资产"
                    assets = Number(@_balanceObj[stockCode].getStockAssetsInTotalAssets()[0])
                when "预付款项"
                    assets = Number(@_balanceObj[stockCode].getYuFuPercent()[0])
                when "其他应收款"
                    assets = Number(@_balanceObj[stockCode].getQiTaYingShouPercent()[0])
                when "存货"
                    assets = Number(@_balanceObj[stockCode].getChunHuoPercent()[0])
                when "长期股权投资"
                    assets = Number(@_balanceObj[stockCode].getChangeQiGuQuanPercent()[0])
                when "固定资产"
                    assets = Number(@_balanceObj[stockCode].getFixedAssetsWithTotalAssetsRatio()[0])
                when "在建工程"
                    assets = Number(@_balanceObj[stockCode].getZaiJiangPercent()[0])
                when "无形资产"
                    assets = Number(@_balanceObj[stockCode].getWuXingPercent()[0])
                when "商誉"
                    assets = Number(@_balanceObj[stockCode].getShangYuPercent()[0])
                when "长期待摊费用"
                    assets = Number(@_balanceObj[stockCode].getChangQiDaiTanPercent()[0])
                when "其他非流动资产"
                    assets = Number(@_balanceObj[stockCode].getQiTaFeiLiuDongPercent()[0])
                when "短期借款"
                    assets = Number(@_balanceObj[stockCode].getDuanQiJieKuanPercent()[0])
                when "应付账款"
                    assets = Number(@_balanceObj[stockCode].getYingFuPercent()[0])
                when "预收账款"
                    assets = Number(@_balanceObj[stockCode].getAdvanceReceiptsPercent()[0])
                when "其他应付款"
                    assets = Number(@_balanceObj[stockCode].getQiTaYingFuPercent()[0])
                when "长期借款"
                    assets = Number(@_balanceObj[stockCode].getChangeQiJieKuanPercent()[0])
                when "未分配利润"
                    assets = Number(@_balanceObj[stockCode].getWeiFenPeiPercent()[0])
                when "权益乘数"
                    assets = Number(@_balanceObj[stockCode].getFinancialLeverage()[0])
                when "有息负债"
                    assets = Number(@_balanceObj[stockCode].getInterestDebt()[0])
                when "营收含金量"
                    assets = Number(@_getIncomeQuality(stockCode)[0])
                when "核心利润占比"
                    assets = Number(@_profitObj[stockCode].getCoreProfitRatio()[0])
                when "ROE"
                    assets = Number(@_getROE(stockCode)[0])
            if isNaN(assets)
                assets = 0
                cc.log("ERROR, assets is 0")
                return
            @_assetsTotalObject[assetName].push assets
        return

    _calcAverage: ->
        for assetName, assetTable of @_assetsTotalObject
            total = 0
            for asset in assetTable
                total += asset
            continue if assetTable.length is 0
            cc.log("ASSETS assetName:#{assetName}, length:#{assetTable.length}, #{total / assetTable.length}")
        return

    _lookAllStock: (stockInfo) ->
        @_assetsTotalObject = {}
        for stockCode in utils.getStockTable("allA")
            stockCode = stockCode.slice(2, 8)
            continue unless @_isAllTableLoadFinish(stockCode)
            # @_getAssetsPercent(stockCode)
            stockInfo.push @_getScore(stockCode, [])
        # @_calcAverage()
        return stockInfo

    _getIndustryAverage: (stockCode, type) ->
        industry = @_balanceObj[stockCode].getIndustry()
        sameIndustryInfo = []
        sameIndustryStockCode = []
        sameIndustryInfoObj = {}
        
        for stockCode in utils.getStockTable("allA")
            stockCode = stockCode.slice(2, 8)
            continue unless @_isAllTableLoadFinish(stockCode)
            
            if (@_balanceObj[stockCode].getIndustry() is industry)
                sameIndustryStockCode.push stockCode
                switch type
                    when "存货"
                        value = @_getInventoryTurnoverDays(stockCode)[0]
                        sameIndustryInfoObj[stockCode] = value
                        sameIndustryInfo.push value
                    when "应收账款"
                        value = @_getReceivableTurnOverDays(stockCode)[0]
                        sameIndustryInfoObj[stockCode] = value
                        sameIndustryInfo.push value
                    when "预收账款"
                        value = @_getAdvanceReceiptsPercent(stockCode)
                        sameIndustryInfoObj[stockCode] = value
                        sameIndustryInfo.push value
                    when "毛利率"
                        value = @_profitObj[stockCode].getGrossProfitRatio()[0]
                        sameIndustryInfoObj[stockCode] = value
                        sameIndustryInfo.push value
                    when "净利率"
                        value = @_profitObj[stockCode].getNetProfitRatio()[0]
                        sameIndustryInfoObj[stockCode] = value
                        sameIndustryInfo.push value
                    when "平均月薪"
                        value = (@_getStaffInfo(stockCode, true) * 10000).toFixed(2)
                        sameIndustryInfoObj[stockCode] = value
                        sameIndustryInfo.push value
                    when "应付账款"
                        value = @_getPayableTurnoverDays(stockCode)[0]
                        sameIndustryInfoObj[stockCode] = value
                        sameIndustryInfo.push value
                    when "现金周转"
                        value = parseFloat(@_getReceivableTurnOverDays(stockCode)[0]) + parseFloat(@_getInventoryTurnoverDays(stockCode)[0]) - parseFloat(@_getPayableTurnoverDays(stockCode)[0])
                        value = value.toFixed(2)
                        sameIndustryInfoObj[stockCode] = value
                        sameIndustryInfo.push value
                    when "核心利润率"
                        value = @_profitObj[stockCode].getOperatingProfitRatio()[0]
                        sameIndustryInfoObj[stockCode] = value
                        sameIndustryInfo.push value
                    when "费用率"
                        value = @_profitObj[stockCode].getExpenseRatio()[0]
                        sameIndustryInfoObj[stockCode] = value
                        sameIndustryInfo.push value
                    when "估值比"
                        value = @_getArkadValuePercent(stockCode)
                        sameIndustryInfoObj[stockCode] = value
                        sameIndustryInfo.push value
        info1 = "\t#{sameIndustryInfo.length}家同行"
        info2 = "平均值：" + utils.getAverage(sameIndustryInfo)
        sortedObjKeys = Object.keys(sameIndustryInfoObj).sort(
            (a, b)->
                if type is "应收账款"
                    return sameIndustryInfoObj[a] - sameIndustryInfoObj[b]
                return sameIndustryInfoObj[b] - sameIndustryInfoObj[a]
        )
        topStockCode = sortedObjKeys[0]
        info3 = "\t最高:" + topStockCode + "---" + @_balanceObj[topStockCode].getStockName() + "：#{sameIndustryInfoObj[topStockCode]}"
        
        orderInfo = []
        for key, index in sortedObjKeys
            info = "#{index + 1}、" + @_balanceObj[key].getBaseInfo() + ":    " + sameIndustryInfoObj[key] 
            if key is @_stockCode
                orderInfo.push "--------" + info + "--------"
                continue
            orderInfo.push info
            break if index >= 49

        console.log(type, orderInfo)
        @_industryInfo["总市值排行"] = @_getIndustryBaseInfo(sameIndustryStockCode)
        @_industryInfo[type] = orderInfo
        return info1 + info2 + info3

    _getIndustryBaseInfo: (sameIndustryStockCode)->
        sameIndustryStockCode.sort(
            (a, b)=>
                return @_balanceObj[b].getTotalMarketValue() - @_balanceObj[a].getTotalMarketValue()
        )
        infoTable = []
        for stock, index in sameIndustryStockCode
            info = "#{index + 1}、" + "#{@_balanceObj[stock].getBaseInfo()} + <-- PE: #{@_profitObj[stock].getPE()}--总市值：#{utils.getValueDillion(@_balanceObj[stock].getTotalMarketValue() / 10000)}-->"
            if stock is @_stockCode
                infoTable.push "--------" + info + "--------"
                continue
            infoTable.push info
            break if index >= 49
        return infoTable

    _getGoodWillPercent: (stockCode) ->
        totalAssets = @_balanceObj[stockCode].getTotalAssets()[0]
        goodWill = @_balanceObj[stockCode].getGoodWill()
        percent = (goodWill / totalAssets * 100).toFixed(2)
        percent

    _loadTable: (dir)->
        totalIndex = 0
        stockTable = utils.getStockTable(dir)
        beginTime = new Date()
        @_loadingFileStatus = true
        loadFile = =>
            return unless global.canLoad
            global.canLoad = false
            if totalIndex >= stockTable.length
                @unschedule(loadFile)
                now = new Date()
                dis = now - beginTime
                @m_tips.string = "load over , use time #{dis // 1000 }s"
                @_loadingFileStatus = false
                return
            stockCode = stockTable[totalIndex]
            isExist = @_checkStockExist(stockCode)
            if isExist
                stockCode = stockCode.slice(2, 8)
                @m_tips.string = "loading ...#{stockCode}... #{totalIndex}/#{stockTable.length}"
                if @_balanceObj[stockCode]?.isLoadFinish()
                    global.canLoad = true
                else
                    @_loadFileToObj(stockCode)
            else
                global.canLoad = true
            totalIndex++

        @schedule(loadFile, 0)
        loadFile()

    _checkStockExist: (stockCode)->
        return stockCode in utils.getStockTable("allA")

    _loadTableByType: (dir)->
        return if @_loadingFileStatus
        global.canLoad = true
        @_loadTable(dir)

    _getArkadValuePercent: (stockCode) ->
        netProfitTable = @_profitObj[stockCode].getNetProfitTable(true, true)
        totalNetProfit = 0
        for i in [0..2]
            totalNetProfit += parseInt(netProfitTable[i])
        
        averageNetProfit = totalNetProfit / 10000 / 3
        ArkadVaule = averageNetProfit / 0.02
        totalMarketValue = @_balanceObj[stockCode].getTotalMarketValue() / 100000000
        return (totalMarketValue / ArkadVaule).toFixed(2)

    _getBaseInfo: ->
        infoTable = []
        stockCode = @_stockCode
        infoTable.push "基本信息：          #{@_profitObj[stockCode].getBaseInfo()}"
        infoTable.push "\n时间:           #{@_profitObj[stockCode].getTimeTitle()}"
        
        # infoTable.push "\n扣非净利润增长率: "
        infoTable.push "\n----------------------  资产负债表Top 10 ----------------------------"
        infoTable.push "\n#{JSON.stringify(@_balanceObj[stockCode].getTop10AllYearPercent(), null, 4) }"

        infoTable.push "\n----------------------营运能力----------------------------"
        
        infoTable.push "\n  货币资金/总资产: #{utils.addTabInTable(@_balanceObj[stockCode].getCashValuePercent())}"
        infoTable.push "\n应收账款占收入比: #{utils.addTabInTable(@_getReceivableInIncomeRatio(stockCode))}"
        infoTable.push "\n          有息负债率: #{utils.addTabInTable(@_balanceObj[stockCode].getInterestDebt())}"
        infoTable.push "\n固定资产/总资产:  #{utils.addTabInTable(@_balanceObj[stockCode].getFixedAssetsWithTotalAssetsRatio())}"    
        infoTable.push "\n预收账款/总资产:  #{utils.addTabInTable(@_balanceObj[stockCode].getAdvanceReceiptsPercent())}"
        infoTable.push "\n  应收款周转率:  #{utils.addTabInTable(@_getRecievableTurnRatio(stockCode))}"
        infoTable.push "\n应收款周转天数: #{utils.addTabInTable(@_getReceivableTurnOverDays(stockCode))}"
        infoTable.push "\n    存货周转率:     #{utils.addTabInTable(@_getInventoryTurnoverRatio(stockCode))}"
        infoTable.push "\n  存货周转天数:     #{utils.addTabInTable(@_getInventoryTurnoverDays(stockCode))}"
        infoTable.push "\n   应付款周转率:   #{utils.addTabInTable(@_getPayableTurnoverRatio(stockCode))}"
        infoTable.push "\n应付款周转天数:    #{utils.addTabInTable(@_getPayableTurnoverDays(stockCode))}"

        infoTable.push "\n----------------------利润表----------------------------"
        
        infoTable.push "\n     营业收入:     #{utils.getValueDillion(@_profitObj[stockCode].getIncomeValue())}"
        infoTable.push "\n营业收入增长:   #{utils.addTabInTable(@_profitObj[stockCode].getIncomeValueAddRatio())}"
        infoTable.push "\n       净利润：     #{utils.getValueDillion(@_profitObj[stockCode].getNetProfitTable())}"
        infoTable.push "\n净利润增长率:    #{utils.addTabInTable(@_profitObj[stockCode].getNetProfitYoy())}"
        infoTable.push "\n        核心利润:    #{utils.getValueDillion(@_profitObj[stockCode].getCoreProfit())}"
        infoTable.push "\n核心润增长率:   #{utils.addTabInTable(@_profitObj[stockCode].getCoreProfitAddRatio())}"
        infoTable.push "\n  核心利润率:    #{utils.addTabInTable(@_profitObj[stockCode].getCoreProfitRatio())}"
        
        infoTable.push "\n      毛利率 :      #{utils.addTabInTable(@_profitObj[stockCode].getGrossProfitRatio())}"
        infoTable.push "\n      净利率 :      #{utils.addTabInTable(@_profitObj[stockCode].getNetProfitRatio())}"
        infoTable.push "\n三项费用率:       #{utils.addTabInTable(@_profitObj[stockCode].getExpenseRatio())}"
        infoTable.push "\n销售费用率:       #{utils.addTabInTable(@_profitObj[stockCode].getSellingFeeRatio())}"
        infoTable.push "\n管理费用率:       #{utils.addTabInTable(@_profitObj[stockCode].getManageFeeRatio())}"
        infoTable.push "\n财务费用率:       #{utils.addTabInTable(@_profitObj[stockCode].getMoneyFeeRatio())}"

        infoTable.push "\n----------------------现金流量表----------------------------"
        infoTable.push "\n  经营活动现金净额: #{utils.getValueDillion(@_cashFlowObj[stockCode].getWorkCashFlow())}"
        infoTable.push "\n购建资产支付的现金: #{utils.getValueDillion(@_cashFlowObj[stockCode].getCapitalExpenditure())}"
        infoTable.push "\n销、劳现金/营业收入:#{utils.addTabInTable(@_getIncomeQuality(stockCode))}"
        infoTable.push "\n    经营现金/净利润:  #{utils.addTabInTable(@_getNetProfitQuality(stockCode))}"

        infoTable.push "\n----------------------净资产收益率----------------------------"
        infoTable.push "\n 净资产收益率: #{utils.addTabInTable(@_getROE(stockCode))}"
        infoTable.push "\n      净利润率: #{utils.addTabInTable(@_profitObj[stockCode].getNetProfitRatio())}"
        infoTable.push "\n 总资产周转率: #{utils.addTabInTable(@_getTotalAssetsTurnoverRatio(stockCode))}"
        infoTable.push "\n      权益乘数: #{utils.addTabInTable(@_balanceObj[stockCode].getFinancialLeverage())}"#---#
        
        # infoTable.push "\n总资产增长率:"
        console.log("baseInfo:#{infoTable}")
        @m_baseInfo_info.string = infoTable
    onLoad300: ->
        @_loadTableByType("hs300")
    onLoad500: ->
        @_loadTableByType("zz500")
    onLoad1000: ->
        @_loadTableByType("zz1000")
    onLoadAll: ->
        @_loadTableByType("allA")

    _calcScore: (itemName, selfNum, average, infoTable) ->
        moreIsGoodItem = ["货币资金", "交易性金融资产", "预收账款", "应付账款", "营收含金量", "核心利润占比", "ROE" ]
        middleItem = ["长期股权投资", "在建工程", "权益乘数", "未分配利润", "应收票据"]
    
        disNum = selfNum - average
        score = 0
        if Math.abs(disNum) < 3 and not (itemName in middleItem)
            score += 5
            infoTable.push "\n#{itemName}(#{average}) 正常 + 5"
        else if itemName in moreIsGoodItem
            if disNum > 0
                score += disNum
                infoTable.push "\n#{itemName}(#{average}) 比平均多, 加分（#{disNum.toFixed(2)})----------"
            else
                score -= Math.abs(disNum)
                infoTable.push("\n#{itemName}(#{average}) 比平均少，减分 (-#{Math.abs(disNum.toFixed(2))})----------")
        else if itemName in middleItem
            score += 0
            if disNum > 0
                infoTable.push("\n#{itemName}(#{average}) 需要观察，比平均多 (#{disNum.toFixed(2)})----------")
            else
                infoTable.push("\n#{itemName}(#{average}) 需要观察，比平均少 (#{Math.abs(disNum.toFixed(2))})----------")
        else
            if disNum < 0
                score += Math.abs(disNum)
                infoTable.push("\n#{itemName}(#{average}) 比平均少， 加分 (#{Math.abs(disNum).toFixed(2)})----------")
            else
                score -= disNum
                infoTable.push("\n#{itemName}(#{average}) 比平均多, 减分 (-#{Math.abs(disNum.toFixed(2))})----------")
        return score


    _getScore: (stockCode, infoTable) ->
        infoTable.push "\n\n-------------财务面评分------------"
        marketAverageObj = {
            "货币资金": 15.30
            "应收票据": 1.14
            "应收账款": 7.37
            "交易性金融资产": 1.41
            "预付款项": 1.51
            "其他应收款": 1.41
            "存货": 11.59
            "长期股权投资": 5.51
            "固定资产": 15.53
            "在建工程": 2.83
            "无形资产": 3.98
            "商誉": 2.45
            "长期待摊费用": 0.44
            "其他非流动资产": 1.60
            "短期借款": 6.63
            "应付账款": 8.19
            "预收账款": 3.40
            "其他应付款": 2.85
            "长期借款": 5.94
            "未分配利润": 13.87
            "权益乘数": 3.52
            "有息负债": 18.11
            "营收含金量": 104
            "核心利润占比": 65
            "ROE": 17
        }

        assetsNameTable = ["货币资金", "应收票据", "应收账款", "交易性金融资产", "预付款项", "其他应收款", "存货",
            "长期股权投资", "固定资产", "在建工程", "无形资产", "商誉", "长期待摊费用",
            "其他非流动资产", "短期借款", "应付账款", "预收账款", "其他应付款", "长期借款",
             "权益乘数", "有息负债", "营收含金量", "核心利润占比", "ROE"
            ]
        totalScore = 0
        assetsTotalPercent = 0
        debtTotalPercent = 0
        for assetName in assetsNameTable
            switch assetName
                when "货币资金"
                    assetsNum = Number(@_balanceObj[stockCode].getCashValuePercent()[0])
                    assetsTotalPercent += assetsNum
                when "应收票据"
                    assetsNum = Number(@_balanceObj[stockCode].getYingShouPiaoJuPercent()[0])
                    assetsTotalPercent += assetsNum
                when "应收账款"
                    assetsNum = Number(@_balanceObj[stockCode].getYingShouPercent()[0])
                    assetsTotalPercent += assetsNum
                when "交易性金融资产"
                    assetsNum = Number(@_balanceObj[stockCode].getStockAssetsInTotalAssets()[0])
                    assetsTotalPercent += assetsNum
                when "预付款项"
                    assetsNum = Number(@_balanceObj[stockCode].getYuFuPercent()[0])
                    assetsTotalPercent += assetsNum
                when "其他应收款"
                    assetsNum = Number(@_balanceObj[stockCode].getQiTaYingShouPercent()[0])
                    assetsTotalPercent += assetsNum
                when "存货"
                    assetsNum = Number(@_balanceObj[stockCode].getChunHuoPercent()[0])
                    assetsTotalPercent += assetsNum
                when "长期股权投资"
                    assetsNum = Number(@_balanceObj[stockCode].getChangeQiGuQuanPercent()[0])
                    assetsTotalPercent += assetsNum
                when "固定资产"
                    assetsNum = Number(@_balanceObj[stockCode].getFixedAssetsWithTotalAssetsRatio()[0])
                    assetsTotalPercent += assetsNum
                when "在建工程"
                    assetsNum = Number(@_balanceObj[stockCode].getZaiJiangPercent()[0])
                    assetsTotalPercent += assetsNum
                when "无形资产"
                    assetsNum = Number(@_balanceObj[stockCode].getWuXingPercent()[0])
                    assetsTotalPercent += assetsNum
                when "商誉"
                    assetsNum = Number(@_balanceObj[stockCode].getShangYuPercent()[0])
                    assetsTotalPercent += assetsNum
                when "长期待摊费用"
                    assetsNum = Number(@_balanceObj[stockCode].getChangQiDaiTanPercent()[0])
                    assetsTotalPercent += assetsNum
                when "其他非流动资产"
                    assetsNum = Number(@_balanceObj[stockCode].getQiTaFeiLiuDongPercent()[0])
                    assetsTotalPercent += assetsNum
                when "短期借款"
                    assetsNum = Number(@_balanceObj[stockCode].getDuanQiJieKuanPercent()[0])
                    debtTotalPercent += assetsNum
                when "应付账款"
                    assetsNum = Number(@_balanceObj[stockCode].getYingFuPercent()[0])
                    debtTotalPercent += assetsNum
                when "预收账款"
                    assetsNum = Number(@_balanceObj[stockCode].getAdvanceReceiptsPercent()[0])
                    debtTotalPercent += assetsNum
                when "其他应付款"
                    assetsNum = Number(@_balanceObj[stockCode].getQiTaYingFuPercent()[0])
                    debtTotalPercent += assetsNum
                when "长期借款"
                    assetsNum = Number(@_balanceObj[stockCode].getChangeQiJieKuanPercent()[0])
                    debtTotalPercent += assetsNum
                when "未分配利润"
                    assetsNum = Number(@_balanceObj[stockCode].getWeiFenPeiPercent()[0])
                when "权益乘数"
                    assetsNum = Number(@_balanceObj[stockCode].getFinancialLeverage()[0])
                when "有息负债"
                    assetsNum = Number(@_balanceObj[stockCode].getInterestDebt()[0])
                when "营收含金量"
                    assetsNum = Number(@_getIncomeQuality(stockCode)[0])
                    assetsNum = 150 if assetsNum > 150
                when "核心利润占比"
                    assetsNum = Number(@_profitObj[stockCode].getCoreProfitRatio()[0])
                    assetsNum = 100 if assetsNum > 100
                    assetsNum = 30 if assetsNum < 30
                when "ROE"
                    assetsNum = Number(@_getROE(stockCode)[0])
                    assetsNum = 50 if assetsNum > 50
                    assetsNum = 0 if assetsNum < 0
            continue if isNaN(assetsNum)
            totalScore += @_calcScore(assetName, assetsNum, marketAverageObj[assetName], infoTable)

        infoTable.push "\n总得分 :#{totalScore.toFixed(2)}"
        infoTable.push "\n统计资产占比:#{assetsTotalPercent.toFixed(2)}%"
        debtPercent = debtTotalPercent /  @_balanceObj[stockCode].getFuZhaiHeJi()[0]
        debtPercent = (debtPercent * 100).toFixed(2)
        infoTable.push "\n统计负债占总负债:#{debtPercent}%"
        infoTable.push "\n特别提示：因各个行业的资产负债结构不同，故某些行业无法作出正确评分"
        infoTable.push "\n若发现统计资产占比非常低，就说明不适合这套算法。已知不匹配行业：银行，保险，地产"
        infoTable.push "\n\n"

        returnInfo = ""
        if @_stockCode < 1000
            maxScore = @_stockCode
        else
            maxScore = 100
        if totalScore > maxScore
            returnInfo = "\n#{@_balanceObj[stockCode].getBaseInfo()}:总得分 :#{totalScore.toFixed(2)}"
        return returnInfo
}
