cc.Class {
    extends: cc.Component

    properties: {
        impulse: cc.v2(0, 3000)
    }

    onLoad: ->
        this.node.getComponent(cc.PhysicsBoxCollider).name = "impulse_platform"
        @_createAction() if Math.random() > 0.8
        
    _createAction: ->
        ac1 = cc.moveBy(1, 200, 0)
        ac2 = cc.moveBy(1, -200, 0)
        this.node.runAction(cc.repeatForever(cc.sequence(ac1, ac2)))

    onBeginContact: (contact, selfCollider, otherCollider) ->
        manifold = contact.getWorldManifold()
        return if manifold.normal.y isnt 1
        body = otherCollider.body
        body.linearVelocity = cc.v2()
        body.applyLinearImpulse(this.impulse, body.getWorldCenter(), true)
        return
}
