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
        if otherCollider.node.name is "cup_left"
            this.game.contackCupLeftOrRight()
        if otherCollider.node.name is "cup_right"
            this.game.contackCupLeftOrRight()
        if otherCollider.node.name is "cup_bottom"
            this.game.contackCupBottom()
        return
}
