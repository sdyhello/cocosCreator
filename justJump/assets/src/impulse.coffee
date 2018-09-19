cc.Class {
    extends: cc.Component

    properties: {
        impulse: cc.v2(0, 3000)
    }

    onBeginContact: (contact, selfCollider, otherCollider) ->
        manifold = contact.getWorldManifold()
        selfCollider.sensor = false
        return if manifold.normal.y isnt 1
        body = otherCollider.body
        body.linearVelocity = cc.v2()
        body.applyLinearImpulse(this.impulse, body.getWorldCenter(), true)
        return
}
