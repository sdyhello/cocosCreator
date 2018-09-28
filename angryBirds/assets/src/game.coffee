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
        graphicsNode: cc.Node
        camera: cc.Node
    }

    onLoad: ->
        @_initData()
    
    _initData: ->
        cc.director.getPhysicsManager().enabled = true
        @_graphicsObj = this.graphicsNode.getComponent(cc.Graphics)
        this.camera.getComponent("camera").game = this
        @_playerRun = false

        @_createEventListener()

    #<<<<<<<<<<<<<<<<<<<<touchEvent<<<<<<<<<<<<<<<<<<<<
    _createEventListener: ->
        this.node.on(cc.Node.EventType.TOUCH_START, @_onTouchStart.bind(@))
        this.node.on(cc.Node.EventType.TOUCH_MOVE, @_onTouchMove.bind(@))
        this.node.on(cc.Node.EventType.TOUCH_END, @_onTouchEnd.bind(@))
        this.node.on(cc.Node.EventType.TOUCH_CANCEL, @_onTouchCancel.bind(@))

    _onTouchStart: (event) ->
        pos = this.node.convertToNodeSpaceAR(event.getLocation())
        @_touchStartPos = pos

    _onTouchMove: (event) ->
        pos = this.node.convertToNodeSpaceAR(event.getLocation())
        @_drawLine(pos)

    _onTouchCancel: ->
        @_clearLine()

    _onTouchEnd: (event) ->
        @_clearLine()
        pos = this.node.convertToNodeSpaceAR(event.getLocation())
        dir = pos.sub(@_touchStartPos).normalize().negSelf()
        @_shootPlayer(dir)

    _shootPlayer: (dir) ->
        body = this.player.getComponent(cc.RigidBody)
        power = cc.v2(dir.x * 1000, dir.y * 1000)
        body.linearVelocity = power
        @_followPlayer()

    _followPlayer: ->
        @_playerRun = true

    getPlayerIsRunning: -> @_playerRun

    #>>>>>>>>>>>>>>>>>>>>touchEvent>>>>>>>>>>>>>>>>>>>>


    #<<<<<<<<<<<<<<<<<<<<<<<<graphics<<<<<<<<<<<<<<<<<<<<<<<
    _drawLine: (pos) ->
        @_clearLine()
        @_graphicsObj.moveTo(@_touchStartPos.x, @_touchStartPos.y)
        @_graphicsObj.lineTo(pos.x, pos.y)
        @_graphicsObj.stroke()

    _clearLine: ->
        @_graphicsObj.clear()
    #>>>>>>>>>>>>>>>>>>>>>>raphics>>>>>>>>>>>>>>>>>>>>>>
}
