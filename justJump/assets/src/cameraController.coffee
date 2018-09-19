cc.Class {
    extends: cc.Component

    properties: {
        player: cc.Node
    }
    lateUpdate: (dt) ->
        targetPos = this.player.convertToWorldSpaceAR(cc.Vec2.ZERO)
        pos = this.node.parent.convertToNodeSpaceAR(targetPos)
        this.node.position = cc.v2(this.node.position.x, pos.y)
        return
}
