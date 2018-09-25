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
    }

    onLoad: ->
        this.node.getComponent(cc.PhysicsCircleCollider).name = "ball_self"

    onBeginContact: (contact, selfCollider, otherCollider) ->
        if otherCollider.name is "ball_enemy"
            isEnemyXStop = otherCollider.body.linearVelocity.x is 0
            isEnemyYStop = otherCollider.body.linearVelocity.y is 0

            isSelfXStop = selfCollider.body.linearVelocity.x is 0
            isSelfYStop = selfCollider.body.linearVelocity.y is 0

            console.log("status:#{[isEnemyXStop, isEnemyYStop, isSelfXStop, isSelfYStop]}")
            if isEnemyXStop and isEnemyYStop
                cc.director.emit("game_win")
            else if isSelfXStop and isSelfYStop
                cc.director.emit("game_over")
            return

    update: (dt) ->
        # do your update here
}
