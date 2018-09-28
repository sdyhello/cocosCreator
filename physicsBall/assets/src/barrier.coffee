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
        scoreLabel: cc.Label
        game: null
    }
    onLoad: ->
        
    start: ->
        @_score = @game.getBarrierScore()
        @_updateScoreLabel()
        
    _updateScoreLabel: ->
        this.scoreLabel?.string = @_score
        if @_score <= 0
            this.game.removeBarrier(this.node)

    onBeginContact: (contact, selfCollider, otherCollider) ->
        if otherCollider.node.name is "ball"
            this.game.addScore()
            @_descScore()
        if selfCollider.node.name is "addBall"
            this.game.addBall(this.node)
    
    _descScore: ->
        @_score--
        @_updateScoreLabel()

    update: (dt) ->
        # do your update here
}
