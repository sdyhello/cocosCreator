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
        m_rank_1: cc.Label,
        m_rank_2: cc.Label,
        m_rank_3: cc.Label,
        m_rank_4: cc.Label,
        m_rank_5: cc.Label,
        m_rank_6: cc.Label,
        m_rank_7: cc.Label,
        m_rank_8: cc.Label,
        m_rank_9: cc.Label,
        m_rank_10: cc.Label,
    }

    update: (dt) ->
        # do your update here
    onLoad: ->
        @_init_all_rank()
        highScoreTable = cc.sys.localStorage.getItem("high_score_table") or []
        for highScore, index in highScoreTable
            @["m_rank_#{index + 1}"].string = "第#{index + 1}名: #{highScore}"
        return

    _init_all_rank: ->
        for index in [1..10]
            @["m_rank_#{index}"].string = "第#{index}名: --"
        return

    onReturn: ->
        cc.director.loadScene('memoryWelcome')
}
