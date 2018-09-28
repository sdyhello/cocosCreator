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
        scoreLabelInGameOver: cc.Label
    }

    onLoad: ->
        cc.director.emit("get_score",
            {
                cb: (score) =>
                    this.scoreLabelInGameOver.string = "你的最后得分: #{score}"
            }
        )

    onRestartGame: ->
        cc.director.loadScene("welcome")
}
