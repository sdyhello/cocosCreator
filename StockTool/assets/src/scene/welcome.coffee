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
    }

    update: (dt) ->
        # do your update here

    onLoad: ->
        TDGA?.onEvent("welcome")
        cocosAnalytics?.CAAccount?.loginStart()
        cocosAnalytics?.CAEvent?.onEvent({eventName:"欢迎界面"})
        CAEvent?.onEvent({eventName:"进入欢迎界面"})
        StockInfoTable.initStockInfo()

    onQuery: ->
        cc.director.loadScene('query')
    onFilter: ->
        cc.director.loadScene('filter')
    onHelp: ->
        cc.director.loadScene('help')
}   
