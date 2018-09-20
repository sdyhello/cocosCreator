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
        score: cc.Label
    }

    onLoad: ->
        @_setScore()
        
    _setScore: ->
        cc.director.emit("get_score",
            {
                cb: (score) =>
                    @score.string = "得分: #{score}"
            }
        )

    onRePlay: ->
        cc.director.loadScene("game")

    update: (dt) ->
        # do your update here
}
