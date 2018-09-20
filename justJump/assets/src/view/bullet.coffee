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
    }

    onLoad: ->
        this.scheduleOnce(@_shoot.bind(@))
        this.node.getComponent(cc.PhysicsBoxCollider).name = "bullet"

    _shoot: ->
        

    onBeginContact: (contact, selfCollider, otherCollider) ->
        if otherCollider.name is "monster"
            selfCollider.node.removeFromParent()
            otherCollider.node.removeFromParent()
        return
    update: (dt) ->
        # do your update here
}
