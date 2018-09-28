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
        game: null
    }

    onLoad: ->
        @_isDown = false

    onBeginContact: (contact, selfCollider, otherCollider) ->
        if otherCollider.node.name is "ground"
            @_isDown = true

    update: (dt) ->
        if @_isDown
            this.getComponent(cc.RigidBody).active = false
            this.getComponent(cc.RigidBody).linearVelocity = cc.Vec2.ZERO
            points = []
            points.push this.node.position
            points.push cc.v2(329, -455)
            points.push cc.v2(329, 520)
            points.push cc.v2(0, 425)
            this.node.runAction(cc.sequence(
                cc.cardinalSplineTo(3, points, 1)
                cc.callFunc(
                    =>
                        this.getComponent(cc.RigidBody).active = true
                        this.node.group = "ballInPrepare"
                        this.getComponent(cc.PhysicsCollider).apply()
                        this.game.ballReturn()
                )
            ))
            @_isDown = false
        # do your update here
}
