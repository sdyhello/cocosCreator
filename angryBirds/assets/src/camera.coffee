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
        game: null
    }

    lateUpdate: (dt) ->
        return unless this.game?
        return unless this.game.getPlayerIsRunning()
        targetPos = this.player.convertToWorldSpaceAR(cc.Vec2.ZERO)
        pos = this.node.parent.convertToNodeSpaceAR(targetPos)
        this.node.position = pos
        return
}
