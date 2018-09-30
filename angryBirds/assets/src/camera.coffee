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
        player: cc.Node
        pencil: cc.Node
        game: null
    }

    lateUpdate: (dt) ->
        return unless this.game?
        return unless this.game.getEraserIsRunning()
        pos = @_getFollowPos()
        pos.x = 0 if pos.x < 0
        pos.y = 0 if pos.y < 0
        if pos.x + cc.winSize.width - 10 > 3200
            pos.x = 3200 - cc.winSize.width + 10
        this.node.position = pos
        return

    _getFollowPos: ->
        if this.game.isCameraFollowPencil()
            targetPos = this.pencil.convertToWorldSpaceAR(cc.Vec2.ZERO)
            pos = this.node.parent.convertToNodeSpaceAR(targetPos)
        else
            targetPos = this.player.convertToWorldSpaceAR(cc.Vec2.ZERO)
            pos = this.node.parent.convertToNodeSpaceAR(targetPos)
        return pos

}
