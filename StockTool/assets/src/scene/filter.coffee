BalanceSheet    = require '../model/BalanceSheet'
ProfitStatement    = require '../model/ProfitStatement'
CashFlowStatement    = require '../model/CashFlowStatement'
utils = require '../tools/utils'
global = require "../globalValue"



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
        m_filter_1 : cc.Node,
        m_filter_2 : cc.Node,
        m_tips : cc.Label,
        m_input_node: cc.Node,
        m_display_node: cc.Node,
        m_display_label: cc.Label,
    }

    onLoad: ->
        @_editboxObjTable = []
        @_editboxDataObj = {}
        @_filterNameTable = [
            {name: "净利润复合收益率", key: "profitAddRatio"},
            {name: "平均ROE", key: "roe"},
            {name: "市盈率", key: "pe"},
            {name: "应收账款周转天数", key: "receivableTurnoverDays"},
            {name: "预收账款占总资产比例", key: "advanceReceipt"},
            {name: "经营现金流量与净利润比值", key: "netProfitQuality"},
            {name: "有息负债占总资产比例", key: "debt"},
            {name: "统计时间", key: "time"},
            {name: "待开发...", key: ""},
            {name: "待开发...", key: ""},
        ]
        @_editboxDataObj = cc.sys.localStorage.getItem("filterObj") or {
            profitAddRatio: "12"
            roe: "15"
            pe: "60"
            advanceReceipt: "5"
            receivableTurnoverDays: "30"
            netProfitQuality: "0.8"
            debt: "-1"
            time: global.year
            "": "-1"
        }
        for index in [1..5]
            @_setEventHandler(@m_filter_1, index)
            @_setEventHandler(@m_filter_2, index)
        @_initAndLoadTable()

    _initAndLoadTable: ->
        @_balanceObj = {}
        @_profitObj = {}
        @_cashFlowObj = {}
        @_loadTable("hs300")

    _setEventHandler: (node, index)->
        editTitle = node.getChildByName("filterItem_#{index}").getChildByName("filterName")
        editboxNode = editTitle.getChildByName("inputLabel")
        editboxObj = editboxNode.getComponent("cc.EditBox")
        @_editboxObjTable.push editboxObj
        @_addEditBoxEventHandler(editboxObj)
        @_initFilterName(editTitle, @_editboxObjTable.length - 1)
        @_initEditBoxPlaceholder(editboxObj, @_editboxObjTable.length - 1)

    _initEditBoxPlaceholder: (editboxObj, index)->
        editboxObj.placeholder = @_editboxDataObj[@_filterNameTable[index].key]

    _initFilterName: (labelObj, index)->
        labelObj.getComponent(cc.Label).string = @_filterNameTable[index].name

    onReFilter: ->
        @m_input_node.active = true
        @m_display_node.active = false

    onReturn: ->
        cc.director.loadScene('welcome')

    onContinueFilter: ->
        @_filterStock()

    _addEditBoxEventHandler: (editboxObj)->
        editboxEventHandler = new cc.Component.EventHandler()
        editboxEventHandler.target = @node
        editboxEventHandler.component = "filter"
        editboxEventHandler.handler = "onTextChanged"
        editboxEventHandler.customEventData = {key: @_filterNameTable[@_editboxObjTable.length - 1].key}
        editboxObj.editingDidEnded.push(editboxEventHandler)

    onTextChanged: (editbox, customEventData)->
        @_editboxDataObj[customEventData.key] = editbox.string

    onSubmit: ->
        @m_input_node.active = false
        @m_display_node.active = true
        @_filterStock()
        cc.sys.localStorage.setItem("filterObj", JSON.strinfigy(@_editboxDataObj))

    _filterStock: ->
        options = @_editboxDataObj
        profitAddRatio = parseFloat(options.profitAddRatio) or -1
        roe = parseFloat(options.roe) or -1
        pe = parseFloat(options.pe) or -1
        advanceReceipt = parseFloat(options.advanceReceipt) or -1
        receivableTurnoverDays = parseFloat(options.receivableTurnoverDays) or -1
        netProfitQuality = parseFloat(options.netProfitQuality) or -1
        debt = parseFloat(options.debt) or -1
        global.year = parseFloat(options.time) if options.time
        info = @findMatchConditionStock(profitAddRatio, roe, pe, advanceReceipt,
            receivableTurnoverDays, netProfitQuality, debt)
        @m_display_label.string = info

    findMatchConditionStock:(profitAddRatio, roe, pe, advanceReceipt,receivableTurnoverDays, netProfitQuality, debt)->
        matchStockTable = []
        for stockCode in utils.getStockTable("allA")
            stockCode = stockCode.slice(2, 8)
            continue unless @_isAllTableLoadFinish(stockCode)
            continue unless @_filterProfitAddRatio(stockCode, profitAddRatio)
            continue unless @_filterROE(stockCode, roe)
            continue unless @_filterPE(stockCode, pe)
            continue unless @_filterAdvanceReceiptsPercent(stockCode, advanceReceipt)
            continue unless @_filterReceivableTurnoverDays(stockCode, receivableTurnoverDays)
            continue unless @_filterNetProfitQuality(stockCode, netProfitQuality)
            continue unless @_filterInterestDebt(stockCode, debt)
            matchStockTable.push stockCode
        return @_getStockTableInfo(matchStockTable)

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
                @m_tips.string = "load over: use time #{dis // 1000 }s"
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

    _loadFileToObj: (stockCode)->
        @_balanceObj[stockCode] = new BalanceSheet(stockCode)
        @_profitObj[stockCode] = new ProfitStatement(stockCode)
        @_cashFlowObj[stockCode] = new CashFlowStatement(stockCode)

    _isAllTableLoadFinish: (stockCode)->
        balance = @_balanceObj[stockCode]?.isLoadFinish()
        profit = @_profitObj[stockCode]?.isLoadFinish()
        cashFlow = @_cashFlowObj[stockCode]?.isLoadFinish()
        return balance and profit and cashFlow

    _filterNetProfitQuality: (stockCode, netProfitQuality)->
        return true if netProfitQuality is -1
        ratioTable = @_getNetProfitQuality(stockCode)
        aveRatio = utils.getAverage(ratioTable)
        if aveRatio > netProfitQuality
            return true
        return false

    _filterROE: (stockCode, needRoe) ->
        return true if needRoe is -1
        roeTable = @_getROE(stockCode)
        aveRoe = utils.getAverage(roeTable)
        if aveRoe > needRoe
            return true
        return false

    _filterProfitAddRatio: (stockCode, needRatio)->
        return true if needRatio is -1
        profitAddRatio = @_profitObj[stockCode].getNetProfitAddRatio()
        if profitAddRatio > needRatio
            return true
        return false

    _filterPE: (stockCode, maxPe)->
        return true if maxPe is -1
        pe = @_profitObj[stockCode].getPE()
        if 0 < pe < maxPe
            return true
        return false

    _filterInterestDebt: (stockCode, limitInterestDebt)->
        return true if limitInterestDebt is -1
        interestDebt = @_balanceObj[stockCode].getInterestDebt()
        if interestDebt < limitInterestDebt
            return true
        return false

    _filterReceivableTurnoverDays: (stockCode, receivableTurnoverDays)->
        return true if receivableTurnoverDays is -1
        day = @_getReceivableTurnOverDays(stockCode)
        if day < receivableTurnoverDays
            return true
        return false

    _filterAdvanceReceiptsPercent:(stockCode, advanceReceipt) ->
        return true if advanceReceipt is -1
        percent = @_getAdvanceReceiptsPercent(stockCode)
        if percent  >= advanceReceipt
            return true
        return false

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

    _getAdvanceReceiptsPercent: (stockCode)->
        return @_balanceObj[stockCode].getAdvanceReceiptsPercent()

    _getROE: (stockCode)->
        netAssetsTable = @_balanceObj[stockCode].getNetAssets()
        netProfitsTable = @_profitObj[stockCode].getNetProfitTable()
        roeTable = []
        for netAssets, index in netAssetsTable
            break if index >= netAssetsTable.length - 1
            roe = ((netProfitsTable[index] / ((netAssets + netAssetsTable[index + 1]) / 2)) * 100).toFixed(2) + "%"
            roeTable.push roe + "\t"
        return roeTable

    _getNetProfitQuality: (stockCode)->
        netProfitTable = @_profitObj[stockCode].getNetProfitTable()
        workCashFlowTable = @_cashFlowObj[stockCode].getWorkCashFlow()
        ratioTable = []
        for netProfit , index in netProfitTable
            ratioTable.push (workCashFlowTable[index] / netProfit).toFixed(2)
        ratioTable

    _getStockTableInfo: (matchStockTable)->
        stockInfoTable = ["股票代码 \t 基本信息 \t 所属行业 \t 利润增长率 \t 平均ROE \t PE \t 应收 \t 预收 \t 现金流 \t  总数:#{matchStockTable.length}"]
        for stockCode in matchStockTable
            stockInfoTable.push @_getStockInfo(stockCode)
        console.log(stockInfoTable)
        length = stockInfoTable.length
        if stockInfoTable.length > 100
            stockInfoTable = stockInfoTable.slice(0, 100)
            stockInfoTable.push "too many stock:#{length}"
        return stockInfoTable

    _getStockInfo: (stockCode)->
        baseInfo = @_profitObj[stockCode].getBaseInfo()
        profitAddRatio = @_profitObj[stockCode].getNetProfitAddRatio()

        roeTable = @_getROE(stockCode)
        aveRoe = utils.getAverage(roeTable)
        
        PE  = @_profitObj[stockCode].getPE()
        return "\n" + utils.addTab(stockCode) + utils.addTab(baseInfo) +
            utils.addTab("净:#{profitAddRatio}") + 
            utils.addTab("roe:#{aveRoe}") +
            utils.addTab("PE:#{PE}") + 
            utils.addTab("应:#{@_getReceivableTurnOverDays(stockCode)}") +
            utils.addTab("预:#{@_getAdvanceReceiptsPercent(stockCode)}") +
            utils.addTab("现:#{utils.getAverage(@_getNetProfitQuality(stockCode))}") +
            "时:#{@_balanceObj[stockCode].getExistYears()}"

    _loadTableByType: (dir)->
        return if @_loadingFileStatus
        global.canLoad = true
        @_loadTable(dir)

    onLoad500: ->
        @_loadTableByType("zz500")
    onLoad1000: ->
        @_loadTableByType("zz1000")
    onLoadAll: ->
        @_loadTableByType("allA")
}
