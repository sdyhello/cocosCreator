
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
        m_high_score: cc.Label,
    }

    update: (dt) ->
        # do your update here

    onEnterGame: ->
        cc.sys.localStorage.setItem("is_master_challenge", false)
        cc.director.loadScene('memoryGame')

    _initHighScore: ->
        highScoreTable = cc.sys.localStorage.getItem("high_score_table") or []
        highScore = if highScoreTable.length > 0 then highScoreTable[0] else 0
        @m_high_score.string = "最高分: #{highScore}"
        kvData = { key: "score", value: highScore + "" }
        console.log("kvData:#{JSON.stringify kvData}")
        wx?.setUserCloudStorage(
            {
                KVDataList: [kvData]
                success: ->
                    console.log("set user cloud ok")
                fail: (res) ->
                    console.log("fail:#{JSON.stringify res}")
            }
        )

    onLoad: ->
        @_initHighScore()

    onEnterRank: ->
        cc.director.loadScene('memoryFriends')

    onMasterChallenge: ->
        cc.sys.localStorage.setItem("is_master_challenge", true)
        cc.director.loadScene('memoryGame')

    onHelp: ->
        cc.director.loadScene("memoryHelp")

    onBack: ->
        cc.director.loadScene("main")
}
