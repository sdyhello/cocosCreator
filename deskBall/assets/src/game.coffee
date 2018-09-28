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
        touchNode: cc.Node
        enemyNode: cc.Node
        tipsNode: cc.Label
        barrierNode: cc.Node
        barrierPrefabTable: [cc.Prefab]
    }

    onLoad: ->
        this.playerBody = this.player.getComponent(cc.RigidBody)
        this.enemyBody = this.enemyNode.getComponent(cc.RigidBody)
        @_playerCanShoot = true
        @_isEnemyRuning = false
        @_game_result = null
        @_createListener()
        @_usePhysics()
        @_initBarrier()

    _initBarrier: ->
        xNum = 4
        yNum = 5
        widthDis = cc.winSize.width / xNum
        heightDis = cc.winSize.height / yNum

        for xIndex in [1..xNum]
            for yIndex in [1..yNum]
                posX = @_getRandomInt((xIndex - 1) * widthDis, xIndex * widthDis)
                posY = @_getRandomInt((yIndex - 1) * heightDis, yIndex * heightDis)
                pos = cc.v2(posX,  posY)
                @_createBarrier(pos)
        return

    _selectBarrier: ->
        randomNum = @_getRandomInt(0, this.barrierPrefabTable.length - 1)
        return this.barrierPrefabTable[randomNum]

    _createBarrier: (pos) ->
        barrier = cc.instantiate(@_selectBarrier())
        this.barrierNode.addChild(barrier)
        barrier.setRotation(@_getRandomInt(0, 180))
        barrier.setPosition(pos)

    _createListener: ->
        this.touchNode.on(cc.Node.EventType.MOUSE_DOWN,
            (event) =>
                @_beginTouchPos = event.getLocation()
        )
        
        this.touchNode.on(cc.Node.EventType.MOUSE_UP,
            (event) =>
                @_prepareShoot(event)
        )

        this.touchNode.on(cc.Node.EventType.TOUCH_START,
            (event) =>
                @_beginTouchPos = event.getLocation()
        )

        this.touchNode.on(cc.Node.EventType.TOUCH_END,
            (event) =>
                @_prepareShoot(event)
        )

        cc.director.on("game_win",
            =>
                @_checkGameStatus()
        )

        cc.director.on("game_over",
            =>
                @_checkGameStatus()
        )

        cc.director.on("game_result",
            (options) =>
                options.cb(@_game_result)
        )

    _checkGameStatus: ->
        if @_isEnemyRuning and @_playerCanShoot is false
            @_game_result = false
            cc.director.loadScene("gameOver")
        else
            @_game_result = true
            cc.director.loadScene("gameOver")
        return

    _getRandomInt: (min, max) ->
        Math.floor(Math.random() * (max - min + 1)) + min

    _usePhysics: ->
        cc.director.getPhysicsManager().enabled = true

    _prepareShoot: (event) ->
        return if @_isEnemyRuning
        endPos = event.getLocation()
        subPos = endPos.sub(@_beginTouchPos)
        normal = subPos.normalize()
        length = subPos.mag()
        normal.negSelf()
        @_shoot(normal, length)

    _shoot: (normal, length) ->
        centerPos = this.playerBody.getWorldCenter()
        scaleValue = 20 * length
        scaleVaule = 10000 if scaleValue > 10000
        power = cc.v2(normal.x * scaleValue, normal.y * scaleValue)
        this.playerBody.applyLinearImpulse(power, centerPos, true)
        @_playerCanShoot = false

    _enemyPrepareToShoot: ->
        isXStop = this.playerBody.linearVelocity.x is 0
        isYStop = this.playerBody.linearVelocity.y is 0
        return unless isXStop and isYStop
        return if @_playerCanShoot
        return if @_isEnemyRuning
        centerPos = this.enemyBody.getWorldCenter()

        playerPos = this.player.getPosition()
        enemyPos = this.enemyNode.getPosition()

        subPos = enemyPos.sub(playerPos)
        normal = subPos.normalize()
        if @_getRandomInt(1, 10) > 1
            normal.negSelf()
        speedScale = 8000


        power = cc.v2(normal.x * speedScale, normal.y * speedScale)

        this.enemyBody.applyLinearImpulse(power, centerPos, true)
        @_isEnemyRuning = true

    _dragPlayerSpeed: ->
        return if this.playerBody.linearVelocity.x is 0 and this.playerBody.linearVelocity.y is 0
        if @_isStop(this.playerBody)
            this.playerBody.linearVelocity = cc.v2()
            console.log("player move end")
        return

    _isStop: (body) ->
        isXStop = Math.floor(Math.abs(body.linearVelocity.x)) < 10
        isYStop = Math.floor(Math.abs(body.linearVelocity.y)) < 10
        if isXStop and isYStop
            return true
        return false

    _dragEnemySpeed: ->
        return if this.enemyBody.linearVelocity.x is 0 and this.enemyBody.linearVelocity.y is 0
        if @_isStop(this.enemyBody)
            this.enemyBody.linearVelocity = cc.v2()
            @_isEnemyRuning = false
            @_playerCanShoot = true
            console.log("enemy move end")
        return

    _updateTips: ->
        if @_playerCanShoot
            this.tipsNode.string = "玩家操作阶段"
        else if @_isEnemyRuning
            this.tipsNode.string = "机器人操作阶段"
        return

    update: (dt) ->
        @_updateTime ?= 0
        @_updateTime += dt
        return if @_updateTime < 1
        @_updateTime = 0
        @_dragPlayerSpeed()
        @_dragEnemySpeed()
        @_enemyPrepareToShoot()
        @_updateTips()
        # do your update here
}
