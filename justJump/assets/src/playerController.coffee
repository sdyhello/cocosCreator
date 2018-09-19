MOVE_LEFT = 1
MOVE_RIGHT = 2

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
        maxSpeed: 100,
        jumps: 2,
        acceleration: 400,
        jumpSpeed: 200,
        drag: 600
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

    _initData: ->
        this._moveFlags = 0
        this._up = false
        this.body = this.getComponent(cc.RigidBody)
        @_accRatio = 0
        return
    
    onKeyDown: (event) ->
        switch(event.keyCode)
            when cc.macro.KEY.a
                this._moveFlags |= MOVE_LEFT
            when cc.macro.KEY.d
                this._moveFlags |= MOVE_RIGHT
            when cc.macro.KEY.w
                if (!this._upPressed)
                    this._up = true
                this._upPressed = true
        return

    onKeyUp: (event) ->
        switch(event.keyCode)
            when cc.macro.KEY.a
                this._moveFlags &= ~MOVE_LEFT
            when cc.macro.KEY.d
                this._moveFlags &= ~MOVE_RIGHT
            when cc.macro.KEY.w
                this._upPressed = false
        return

    onDeviceMotionEvent: (event) ->
        @_accRatio = event.acc.x

    _addSpeed: (speed, dt) ->
        speed.x -= this.acceleration * @_accRatio
        if(speed.x > this.maxSpeed)
            speed.x = this.maxSpeed
        else if(speed.x < -this.maxSpeed)
            speed.x = -this.maxSpeed
        return speed

    _slowDown: (speed, dt) ->
        d = this.drag * dt
        if(Math.abs(speed.x) <= d)
            speed.x = 0
        else
            if speed.x > 0
                dis = d
            else
                dis = -d
            speed.x -= dis
        return speed

    _dealJump: (speed) ->
        if(Math.abs(speed.y) < 1)
            this.jumps = 2
        
        if (this.jumps > 0 && this._up)
            speed.y = this.jumpSpeed
            this.jumps--
        return speed

    _checkBorder: (speed, dt) ->
        playerPos = this.node.convertToWorldSpaceAR(cc.Vec2.ZERO)
        if playerPos.x < 0
            speed.x = this.acceleration * dt
        else if playerPos.x > cc.winSize.width
            speed.x = -this.acceleration * dt
        return speed

    update: (dt) ->
        speed = this.body.linearVelocity
        if @_accRatio is 0
            speed = @_slowDown(speed, dt)
        else
            speed = @_addSpeed(speed, dt)
        # speed = @_dealJump(speed)
        speed = @_checkBorder(speed, dt)
        this.body.linearVelocity = speed
        return
}
