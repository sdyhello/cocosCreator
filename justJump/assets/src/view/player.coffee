MOVE_LEFT = 1
MOVE_RIGHT = 2

cc.Class {
    extends: cc.Component

    properties: {
        
    }

    onLoad: ->
        @_setSystemEvent()
        @_initData()
        return

    _setSystemEvent: ->
        cc.systemEvent.on(cc.SystemEvent.EventType.KEY_DOWN, this.onKeyDown, this)
        cc.systemEvent.on(cc.SystemEvent.EventType.KEY_UP, this.onKeyUp, this)
        cc.systemEvent.on(cc.SystemEvent.EventType.DEVICEMOTION, this.onDeviceMotionEvent, this)
        cc.systemEvent.setAccelerometerEnabled(true)
        return

    onKeyDown: (event) ->
        switch event.keyCode
            when cc.macro.KEY.a
                @_accX += 0.1
            when cc.macro.KEY.d
                @_accX -= 0.1
        return

    onKeyUp: (event) ->
        @_accX = 0

    _initData: ->
        this._accRatio = 1500
        @_accX = 0
        this.node.getComponent(cc.PhysicsBoxCollider).name = "player"
        this.body = this.getComponent(cc.RigidBody)
        sysInfo = wx?.getSystemInfoSync()

        console.log("sysInfo:#{JSON.stringify sysInfo}")
        return

    onDeviceMotionEvent: (event) ->
        @_accX = event.acc.x

    _checkBorder: (speed, dt) ->
        playerPos = this.node.convertToWorldSpaceAR(cc.Vec2.ZERO)
        if playerPos.x < 0
            speed.x = 10
        else if playerPos.x > cc.winSize.width
            speed.x = -10
        return speed

    _changePosInBorder: ->
        playerPos = this.node.convertToWorldSpaceAR(cc.Vec2.ZERO)
        nodePos = this.node.parent.convertToNodeSpaceAR(playerPos)
        if playerPos.x < 0
            this.node.setPosition(nodePos.x + cc.winSize.width, nodePos.y)
        else if playerPos.x > cc.winSize.width
            this.node.setPosition(nodePos.x - cc.winSize.width, nodePos.y)
        return

    _controllDir: ->
        speed = this.body.linearVelocity
        speed.x = -@_accX * @_accRatio
        this.body.linearVelocity = speed
        
    update: (dt) ->
        @_controllDir()
        @_changePosInBorder()
        return
}
