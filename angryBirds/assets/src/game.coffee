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

        eraser: cc.Node
        graphicsNode: cc.Node
        pencil: cc.Node
        camera: cc.Node
        powerTips: cc.Label
        angularTips: cc.Label
        eraserPosTips: cc.Label
        tiledMap: cc.TiledMap
        cupPrefab: cc.Prefab
        mainCamera: cc.Node
        winTips: cc.Node
    }

    onLoad: ->
        @_initData()
        @_initGameInOtherPos()
        @_createEventListener()
        @_saveNodePos()
        @_updateErasePosTips()
        @_initTiledMap()
        @_initDefaultCupNode()

    _initDefaultCupNode: ->
        @_defaultCupNode = cc.instantiate(this.cupPrefab)
        this.node.addChild(this._defaultCupNode)
        goodJobTable = cc.sys.localStorage.getItem("goodJob") or []
        goodJobTable = JSON.parse(goodJobTable)
        goodJobIndex = @_getRandomInt(0, goodJobTable.length - 1)
        defaultCupDataObj = goodJobTable[goodJobIndex]
        @_defaultCupDataObj = defaultCupDataObj
        @_defaultCupNode.setPosition(defaultCupDataObj.targetPos)
        this._defaultCupNode.active = false

    _saveNodePos: ->
        @_eraserPos = this.eraser.position
        @_pencilPos = this.pencil.position
        
    _initGameInOtherPos: ->
        this.camera.getComponent("camera").game = this
        this.eraser.getComponent("eraser").game = this
        this.pencil.getComponent("pencil").game = this

    _initData: ->
        cc.director.getPhysicsManager().enabled = true
        @winTips.active = false
        @_graphicsObj = this.graphicsNode.getComponent(cc.Graphics)
        @_isEraserRun = false
        @_cameraFollowPencil = false
        @_gameWin = false
        @_isGuide = false

    #<<<<<<<<<<<<<<<<<<<<touchEvent<<<<<<<<<<<<<<<<<<<<
    _createEventListener: ->
        this.node.on(cc.Node.EventType.TOUCH_START, @_onTouchStart.bind(@))
        this.node.on(cc.Node.EventType.TOUCH_MOVE, @_onTouchMove.bind(@))
        this.node.on(cc.Node.EventType.TOUCH_END, @_onTouchEnd.bind(@))
        this.node.on(cc.Node.EventType.TOUCH_CANCEL, @_onTouchCancel.bind(@))
        @_createEraserEventListener()

    _createEraserEventListener: ->
        this.eraser.on(cc.Node.EventType.TOUCH_START, (event) -> event.stopPropagation())
        this.eraser.on(cc.Node.EventType.TOUCH_END, (event) -> event.stopPropagation())
        this.eraser.on(cc.Node.EventType.TOUCH_MOVE,
            (event) =>
                pos = this.node.convertToNodeSpaceAR(event.getLocation())
                this.eraser.position = pos
                @_updateErasePosTips()
                event.stopPropagation()
        )

    _onTouchStart: (event) ->
        pos = this.node.convertToNodeSpaceAR(event.getLocation())
        @_touchStartPos = pos

    _onTouchMove: (event) ->
        pos = this.node.convertToNodeSpaceAR(event.getLocation())
        subPos = pos.sub(@_touchStartPos)
        length = subPos.mag()
        this.powerTips.string = "power: #{Math.floor(length)}"
        angular = @_getVectorRadians(@_touchStartPos.x, @_touchStartPos.y, pos.x, pos.y)
        this.angularTips.string = "angular: #{Math.floor(angular)}"
        @_drawLine(pos)

    _onTouchCancel: ->
        @_clearLine()

    _onTouchEnd: (event) ->
        @_clearLine()
        pos = this.node.convertToNodeSpaceAR(event.getLocation())
        subPos = pos.sub(@_touchStartPos)
        length = subPos.mag() * 20
        dir = subPos.normalize().negSelf()
        @_shootEraser(length, dir)

    _shootEraser: (length, dir) ->
        body = this.eraser.getComponent(cc.RigidBody)
        power = cc.v2(dir.x * length, dir.y * length)
        body.linearVelocity = power
        @_followeraser()
        @_saveShootInfo(length, power)

    _formatPos: (pos) ->
        cc.v2(Math.floor(pos.x), Math.floor(pos.y))


    _saveShootInfo: (length, power) ->
        targetPos = @_targetCup.getPosition()
        eraserPos = this.eraser.position
        pencilPos = this.pencil.position
        length = length
        power = power
        @_shootInfo = { targetPos, eraserPos, length, power, pencilPos }

    _isExistShootType: (goodJobTable) ->
        for goodJobObj in goodJobTable
            isPosXSame = goodJobObj.targetPos.x is @_shootInfo.targetPos.x
            isPosYSame = goodJobObj.targetPos.y is @_shootInfo.targetPos.y
            isErasePosXSame = goodJobObj.eraserPos.x is @_shootInfo.eraserPos.x
            isErasePosYSame = goodJobObj.eraserPos.y is @_shootInfo.eraserPos.y
            isLengthSame = goodJobObj.length is @_shootInfo.length
            isPowerSame = goodJobObj.power.x is @_shootInfo.power.x
            isPosSame = isPosXSame and isPosYSame and isErasePosXSame and isErasePosYSame
            isOtherSame = isLengthSame and isPowerSame
            if isPosSame and isOtherSame
                console.log("same type")
                return true
        return false

    _saveSuccessShootInfo: ->
        goodJobTable = cc.sys.localStorage.getItem("goodJob") or []
        try
            goodJobTable = JSON.parse(goodJobTable)
        catch
            goodJobTable = []
        return if @_isExistShootType(goodJobTable)
        goodJobTable.push @_shootInfo
        cc.sys.localStorage.setItem("goodJob", JSON.stringify goodJobTable)

    #-------------------status-------------------
    _followeraser: ->
        @_isEraserRun = true

    getEraserIsRunning: -> @_isEraserRun

    letCameraFollowPencil: ->
        @_cameraFollowPencil = true

    isCameraFollowPencil: -> @_cameraFollowPencil

    #>>>>>>>>>>>>>>>>>>>>touchEvent>>>>>>>>>>>>>>>>>>>>


    #<<<<<<<<<<<<<<<<<<<<<<<<graphics<<<<<<<<<<<<<<<<<<<<<<<
    _drawLine: (pos) ->
        @_clearLine()
        subPos = pos.sub(@_touchStartPos).negSelf()
        normal = subPos.normalize()
        lineLength = 389
        eraserPos = this.eraser.position
        targetPosX = eraserPos.x + normal.x * lineLength
        targetPosY = eraserPos.y + normal.y * lineLength

        @_graphicsObj.moveTo(eraserPos.x, eraserPos.y)
        @_graphicsObj.lineTo(targetPosX, targetPosY)
        @_graphicsObj.stroke()

    _clearLine: ->
        @_graphicsObj.clear()
    #>>>>>>>>>>>>>>>>>>>>>>raphics>>>>>>>>>>>>>>>>>>>>>>

    _updateErasePosTips: ->
        return if @_isEraserRun
        pos = this.eraser.getPosition()
        this.eraserPosTips.string = "pos: x: #{Math.floor(pos.x)}, y: #{Math.floor(pos.y)}"

    _setDefaultCupNodeStatus: (status) ->
        this._defaultCupNode.active = status
        this._targetCup.active = not status

    _setGuidePencilPos: (pencilPos) ->
        this.pencil.position = pencilPos

    onGuide: ->
        @_setDefaultCupNodeStatus(true)
        @_resetGameStatus()
        @_isGuide = true
        @_resetBodyStatus()
        @_setGuidePencilPos(@_defaultCupDataObj.pencilPos)
        this.eraser.position = cc.v2(-229, -197)

        length = @_defaultCupDataObj.length
        eraserPos = @_defaultCupDataObj.eraserPos
        power = cc.v2(@_defaultCupDataObj.power.x, @_defaultCupDataObj.power.y)


        seq = []
        seq.push cc.moveTo(1, eraserPos)
        seq.push cc.callFunc(
            =>
                dir = power.normalize()
                @_shootEraser(length, dir)
        )
        cb = =>
            this.eraser.runAction(cc.sequence(seq))
        @_viewTarget(this._defaultCupNode, cb)

    onSaveShootInfo: ->
        @_saveSuccessShootInfo()

    onExit: ->
        cc.director.loadScene("welcome")

    _viewTarget: (target, callback) ->
        target ?= @_targetCup
        seq = []
        targetPos = target.getPosition()
        seq.push cc.moveTo(2, cc.v2(Math.max(0, targetPos.x), Math.max(0, targetPos.y)))
        seq.push cc.delayTime(1)
        seq.push cc.moveTo(2, cc.v2(0, 0))
        seq.push cc.callFunc(-> callback?())
        this.mainCamera.runAction(cc.sequence(seq))

    onViewTarget: (target, callback) ->
        @_viewTarget()

    onResetGame: ->
        @_resetBodyStatus()
        @_resetGameStatus()
        @_resetBodyPos()
        @_setDefaultCupNodeStatus(false)

    _resetGameStatus: ->
        @_cameraFollowPencil = false
        @_isEraserRun = false
        @_isGuide = false
        @_contactCupLeftOrRight = false
        @_contactCupBottom = false
        this.camera.position = cc.v2(0,  0)

    _resetBodyStatus: ->
        eraserBody = this.eraser.getComponent(cc.RigidBody)
        eraserBody.linearVelocity = cc.Vec2.ZERO
        eraserBody.angularVelocity = 0
        
        pencilBody = this.pencil.getComponent(cc.RigidBody)
        pencilBody.linearVelocity = cc.Vec2.ZERO
        pencilBody.angularVelocity = 0
        this.pencil.rotation = 0

    _resetBodyPos: ->
        this.eraser.position = @_eraserPos
        this.pencil.position = @_pencilPos
        @_updateErasePosTips()

    _getVectorRadians: ( x1,  y1,  x2,  y2) ->
        len_y = y2 - y1
        len_x = x2 - x1
        tan_yx = tan_yx = Math.abs(len_y) / Math.abs(len_x)
        angle = 0
        if(len_y > 0 && len_x < 0)
            angle = Math.atan(tan_yx) * 180 / Math.PI - 90
        else if (len_y > 0 && len_x > 0)
            angle = 90 - Math.atan(tan_yx) * 180 / Math.PI
        else if(len_y < 0 && len_x < 0)
            angle = -Math.atan(tan_yx) * 180 / Math.PI - 90
        else if(len_y < 0 && len_x > 0)
            angle = Math.atan(tan_yx) * 180 / Math.PI + 90
        return angle

     _getRandomInt: (min, max) ->
        Math.floor(Math.random() * (max - min + 1)) + min


    _initTiledMap: ->
        platformObj = this.tiledMap.getObjectGroup("platform")
        objects = platformObj.getObjects()
        objectId = @_getRandomInt(0, objects.length - 1)
        target = objects[objectId]
        pos = this.node.convertToNodeSpaceAR(cc.v2(target.x, target.y))
        cup = cc.instantiate(this.cupPrefab)
        cup.setPosition(pos)
        this.node.addChild(cup)
        @_targetCup = cup

    contackCupLeftOrRight: ->
        @_contactCupLeftOrRight = true
        @_checkWin()

    contackCupBottom: ->
        @_contactCupBottom = true
        @_checkWin()

    _checkWin: ->
        if @_contactCupLeftOrRight and @_contactCupBottom
            console.log("win")
            if @_isGuide
                return
            @_saveSuccessShootInfo()
            return if @_gameWin
            @_gameWin = true
            @winTips.active = true
            this.scheduleOnce(
                ->
                    console.log("good job")
                    cc.director.loadScene("gameOver")
                3
            )
        return
}
