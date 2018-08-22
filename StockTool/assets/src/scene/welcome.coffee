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
        m_exit_node: cc.Node,
    }

    update: (dt) ->
        # do your update here

    onLoad: ->
        TDGA?.onEvent("welcome")
        cocosAnalytics?.CAEvent?.onEvent({eventName:"打开欢迎界面"})
        if cc.sys.isNative
            @m_exit_node.active = true
        else
            @m_exit_node.active = false
        StockInfoTable.preloadCsv()

    onQuery: ->
        cc.director.loadScene('query')
    onFilter: ->
        cc.director.loadScene('filter')
    onHelp: ->
        cc.director.loadScene('help')
    onExit: ->
        cc.director.popScene()
}       
