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
    }
 
    onLoad: ->
        @_init()
        @_addEditBoxEventHandler(@m_input_code, "code")
        @_addEditBoxEventHandler(@m_input_time, "time")
    _init: ->
        @m_query_node.active = true
        @m_industry_node.active = false
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
        cc.director.loadScene('welcome')

    onLookIndustryInfo: ->
        TDGA?.onEvent("lookIndustryInfo")
        cocosAnalytics?.CAEvent?.onEvent({eventName:"查看行业对比"})
        @m_query_node.active = false
        @m_industry_node.active = true
        @onClickButton()
        @m_industry_info.string = JSON.stringify(@_industryInfo, null, 4)

    onIndustryReturn: ->
        @m_query_node.active = true
        @m_industry_node.active = false

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
        return @_balanceObj[stockCode].getAdvanceReceiptsPercent()

    _getReceivableTurnOverDays: (stockCode)->
        receivableValueTable = @_balanceObj[stockCode].getReceivableValue()
        inComeValueTable = @_profitObj[stockCode].getIncomeValue()
        daysTable = []
        for receivableValue, index in receivableValueTable
            break if index >= receivableValueTable.length - 1
            days = 360 / inComeValueTable[index] * (receivableValue + receivableValueTable[index + 1]) / 2
            daysTable.push days

        day = utils.getAverage(daysTable)
        return day

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
            roe = ((netProfitsTable[index] / ((netAssets + netAssetsTable[index + 1]) / 2)) * 100).toFixed(2) + "%"
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
        infoTable.push "\nPE:   " + @_profitObj[stockCode].getPE() + "\t对应股价:#{@_profitObj[stockCode].getSharePrice()}"
        infoTable.push "\n总资产：#{utils.getValueDillion(@_balanceObj[stockCode].getTotalAssets()[0])}"
        infoTable.push "\n总市值：#{utils.getValueDillion(@_balanceObj[stockCode].getTotalMarketValue() / 10000)}"
        infoTable.push "\n资产负债表Top10（最新期）: #{@_balanceObj[stockCode].getTop10()}"
        infoTable.push "\n投资性资产占比: " + @_balanceObj[stockCode].getInvestAssets() + "%"
        infoTable.push "\n有息负债（单）: #{@_balanceObj[stockCode].getInterestDebt()}%"
        infoTable.push "\n应收账款周转天数(历年平均): #{@_getReceivableTurnOverDays(stockCode)}, #{@_getIndustryAverage(stockCode, "应收账款")}"
        infoTable.push "\n预收账款占总资产比例（历年平均）: #{@_getAdvanceReceiptsPercent(stockCode)}%， #{@_getIndustryAverage(stockCode, "预收账款")}"
        infoTable.push "\n存货周转率（单）:#{@_getInventoryTurnoverRatio(stockCode)}%, #{@_getIndustryAverage(stockCode, "存货")}%"
        infoTable.push "\n净利润（多）： " + utils.getValueDillion(@_profitObj[stockCode].getNetProfitTable())
        infoTable.push "\n毛利率（单）: #{@_profitObj[stockCode].getSingleYearGrossProfitRatio()}, #{@_getIndustryAverage(stockCode, "毛利率")}%"
        infoTable.push "\n净利率（单）: #{@_profitObj[stockCode].getSingleYearNetProfitRatio()}, #{@_getIndustryAverage(stockCode, "净利率")}%"
        infoTable.push "\n年净利润增长率:   " + @_profitObj[stockCode].getNetProfitYoy()
        infoTable.push "\n净利润复合增长率:   " + @_profitObj[stockCode].getNetProfitAddRatio() + "%"
        infoTable.push "\n现金流量比净利润:   " + @_getNetProfitQuality(stockCode) + "平均:#{utils.getAverage(@_getNetProfitQuality(stockCode))}"
        infoTable.push "\n历年ROE:   " + @_getROE(stockCode) + "平均: #{utils.getAverage(@_getROE(stockCode))}%"
        infoTable.push "\n" + @_getStaffInfo(stockCode)
        infoTable.push "\n统计时间： #{@_balanceObj[stockCode].getExistYears()}"
        @_getIndustryAverage(stockCode, "平均月薪")
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
                console.log(staffInfo[2])
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
            ratioTable.push (workCashFlowTable[index] / netProfit).toFixed(2)
        ratioTable

    _getInventoryTurnoverRatio: (stockCode)->
        averageInventory = @_balanceObj[stockCode].getSingleYearAverageInventory()
        operatingCosts = @_profitObj[stockCode].getOperatingCosts()[0]
        ratio = (operatingCosts / averageInventory).toFixed(2)
        ratio

    _getIndustryAverage: (stockCode, type)->
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
                        value = @_getInventoryTurnoverRatio(stockCode)
                        sameIndustryInfoObj[stockCode] = value
                        sameIndustryInfo.push value
                    when "应收账款"
                        value = @_getReceivableTurnOverDays(stockCode)
                        sameIndustryInfoObj[stockCode] = value
                        sameIndustryInfo.push value
                    when "预收账款"
                        value = @_getAdvanceReceiptsPercent(stockCode)
                        sameIndustryInfoObj[stockCode] = value
                        sameIndustryInfo.push value
                    when "毛利率"
                        value = @_profitObj[stockCode].getSingleYearGrossProfitRatio()
                        sameIndustryInfoObj[stockCode] = value
                        sameIndustryInfo.push value
                    when "净利率"
                        value = @_profitObj[stockCode].getSingleYearNetProfitRatio()
                        sameIndustryInfoObj[stockCode] = value
                        sameIndustryInfo.push value
                    when "平均月薪"
                        value = (@_getStaffInfo(stockCode, true) * 10000).toFixed(2)
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

    onLoad300: ->
        @_loadTableByType("hs300")
    onLoad500: ->
        @_loadTableByType("zz500")
    onLoad1000: ->
        @_loadTableByType("zz1000")
    onLoadAll: ->
        @_loadTableByType("allA")
}
