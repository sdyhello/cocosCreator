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
        highScore: cc.Label
    }

    update: (dt) ->
        # do your update here

    onPlayGame: ->
        cc.director.loadScene("game")

    onRank: ->
        cc.director.loadScene("friends")

    onLoad: ->
        fastTime = cc.sys.localStorage.getItem("fast_time") or 10000
        useStep = cc.sys.localStorage.getItem("use_step") or 10000
        @highScore.string = "最快用时: " + fastTime + "秒, " + "#{useStep} 步"
        kvData = { key: "fastTime", value: fastTime + "" }
        kvDataStep = { key: "useStep", value: useStep + "" }
        wx?.setUserCloudStorage(
            {
                KVDataList: [kvData, kvDataStep]
                success: ->
                    console.log("set user cloud ok")
                fail: (res) ->
                    console.log("fail:#{JSON.stringify res}")
            }
        )
}
