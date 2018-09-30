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
    onBeginContact: (contact, selfCollider, otherCollider) ->
        if otherCollider.node.name is "pencil"
            this.game.letCameraFollowPencil()
        return
        
    update: (dt) ->
        # do your update here
}
