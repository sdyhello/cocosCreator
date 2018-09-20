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

    onLoad: ->
        @_score = 0
        @_initEvent()

    _initEvent: ->
        cc.director.on("set_score",
            (event) =>
                @_score = event.score
        )

        cc.director.on("get_score",
            (event) =>
                event.cb(@_score)
        )
        cc.director.on("game_over",
            ->
                cc.director.loadScene("gameOver")
        )
}
