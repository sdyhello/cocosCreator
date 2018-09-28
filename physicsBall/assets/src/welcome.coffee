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

    onLoad: ->
        score = cc.sys.localStorage.getItem("highScore") or 0
        this.highScore.string = "最高分: #{score}"

    onStartGame: ->
        cc.director.loadScene("game")

    update: (dt) ->
        # do your update here
}
