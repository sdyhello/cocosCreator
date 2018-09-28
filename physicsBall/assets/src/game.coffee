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
        ball: cc.Node
        ballPrefab: cc.Prefab
        barriersPrefabTable: [cc.Prefab]
        score: cc.RichText
        ballNum: cc.RichText
        graphicsNode: cc.Node
    }

    onLoad: ->
        @_gameScore = 0
        @_barrierScore = 1
        @_returnBallCount = 1
        this.ball.group = "ballInPrepare"
        this.ball.getComponent("ball").game = this
        @_ballTable = [this.ball]
        @_barriersTable = []
        cc.director.getPhysicsManager().enabled = true
        @_createListener()
        @_updateScore()
        @_updateBallNumber()

        @_ctx = this.graphicsNode.getComponent(cc.Graphics)
        
    _drawLine: (pos) ->
        @_clearLine()
        @_ctx.moveTo(0, 285)
        @_ctx.lineTo(pos.x, pos.y)
        @_ctx.stroke()

    _clearLine: ->
        @_ctx.clear()

    start: ->
        @_addOneRowBarriers()

    _createListener: ->
        this.node.on(cc.Node.EventType.TOUCH_START, @_onTouchStart.bind(@))
        this.node.on(cc.Node.EventType.TOUCH_MOVE, @_onTouchMove.bind(@))
        this.node.on(cc.Node.EventType.TOUCH_END, @_onTouchEnd.bind(@))
        this.node.on(cc.Node.EventType.TOUCH_CANCEL, @_onTouchCancel.bind(@))
        cc.director.on("get_score", (options) => options.cb(@_gameScore))

    _onTouchStart: (event) ->
        return unless @_isAllBallReturn()
        @_drawLine(this.node.convertToNodeSpaceAR(event.getLocation()))

    _onTouchMove: (event) ->
        return unless @_isAllBallReturn()
        @_drawLine(this.node.convertToNodeSpaceAR(event.getLocation()))

    _onTouchEnd: (event) ->
        @_afterTouchEvent(event)

    _onTouchCancel: (event) ->
        @_afterTouchEvent(event)

    _afterTouchEvent: (event) ->
        @_clearLine()
        return unless @_isAllBallReturn()
        pos = this.node.convertToNodeSpaceAR(event.getLocation())
        subPos = pos.sub(cc.v2(0, 285))
        subPosNormal = subPos.normalize()
        @_shootBalls(subPosNormal)
        return

    _shootBalls: (dir) ->
        @_returnBallCount = 0
        for ball, index in @_ballTable
            ((ball, index) =>
                this.scheduleOnce(
                    =>
                        @_shootBall(ball, dir)
                    index * 0.3
                )
            )(ball, index)
        return

    _shootBall: (ball, dir) ->
        ball.getComponent(cc.RigidBody).active = false
        points = []
        points.push ball.getPosition()
        points.push cc.v2(0, 285)
        ball.runAction(cc.sequence(
            cc.cardinalSplineTo(1, points, 1)
            cc.callFunc(
                ->
                    ball.getComponent(cc.RigidBody).active = true
                    ball.getComponent(cc.RigidBody).gravityScale = 0
                    dir = cc.v2(dir.x * 1000, dir.y * 1000)
                    ball.getComponent(cc.RigidBody).linearVelocity = dir
                    ball.group = "ballInGame"
                    ball.getComponent(cc.PhysicsCollider).apply()
            )
        ))

     _getRandomInt: (min, max) ->
        Math.floor(Math.random() * (max - min + 1)) + min

    _selectBarrier: ->
        randomNum = @_getRandomInt(0, this.barriersPrefabTable.length - 1)
        return this.barriersPrefabTable[randomNum]

    _createBarrier: (pos) ->
        barrier = cc.instantiate(@_selectBarrier())
        this.node.addChild(barrier)
        barrier.setRotation(@_getRandomInt(0, 180))
        barrier.setPosition(pos)
        barrier.getComponent("barrier").game = this
        @_barriersTable.push barrier

    _addOneRowBarriers: ->
        posXBegin = -243
        posXEnd = 237
        posY = -379
        while posXBegin < posXEnd
            posX = posXBegin + @_getRandomInt(100, 200)
            if posX > posXEnd
                break
            pos = cc.v2(posX, posY)
            posXBegin = posX
            @_createBarrier(pos)
        return

    _createBall: (pos) ->
        ball = cc.instantiate(this.ballPrefab)
        this.node.addChild(ball)
        ball.group = "ballInPrepare"
        ball.setPosition(pos)
        ball.getComponent("ball").game = this
        @_ballTable.push ball

    removeBarrier: (barrier) ->
        barrier.removeFromParent()
        index = @_barriersTable.indexOf(barrier)
        if index isnt -1
            @_barriersTable.splice(index, 1)
        return

    addBall: (node) ->
        @removeBarrier(node)
        @_createBall(node.getPosition())
        @_updateBallNumber()

    getBarrierScore: ->
        @_barrierScore += @_getRandomInt(2, 10)
        return @_barrierScore

    ballReturn: ->
        @_returnBallCount++
        if @_isAllBallReturn()
            for barrier in @_barriersTable
                barrier.runAction(cc.moveBy(0.3, cc.v2(0, 100)))
            @_checkGameFail()
            @_addOneRowBarriers()
        return

    _isAllBallReturn: ->
        if @_returnBallCount is @_ballTable.length
            return true
        return false

    addScore: ->
        @_gameScore++
        @_updateScore()

    _updateScore: ->
        this.score.string = "得分: <color=#00ff00>#{@_gameScore}</c>"

    _updateBallNumber: ->
        this.ballNum.string = "拥有球数: <color=#0fffff>#{@_ballTable.length}</color> 个"

    _checkGameFail: ->
        for barrier in @_barriersTable
            if barrier.position.y > 220
                @_saveHighScore()
                cc.director.loadScene("gameOver")
        return

    _saveHighScore: ->
        highScore = cc.sys.localStorage.getItem("highScore") or 0
        if @_gameScore > highScore
            cc.sys.localStorage.setItem("highScore", @_gameScore)
        return

}
