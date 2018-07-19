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
        m_totalScore: cc.Label,
    }

    update: (dt) ->
        # do your update here

    onLoad: ->
        totalScore = cc.sys.localStorage.getItem("totalScore") or 0
        @m_totalScore.string = "恭喜你完成测试，你的得分是： #{totalScore}"
}
