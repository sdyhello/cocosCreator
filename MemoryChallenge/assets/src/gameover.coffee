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
        m_score: cc.Label,
        m_numbers: cc.Label,
    }

    onLoad: ->
        curLevelScore = cc.sys.localStorage.getItem("current_level_score") or 0
        @m_score.string = "游戏得分: #{curLevelScore}"

        numbers = cc.sys.localStorage.getItem("numbers") or ""
        @m_numbers.string = "游戏点: #{numbers}"

    onReturn: ->
        cc.director.loadScene('welcome')
}
