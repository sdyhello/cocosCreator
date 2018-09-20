cc.Class {
    extends: cc.Component

    properties: {
        platformRootNode: cc.Node
        platform_prafab: [cc.Prefab],
        player: cc.Node
        lastPlatform: cc.Node
        scoreLabel: cc.Label
    }

    _getRandomNum: ->
        randomNum = Math.random() * 3
        randomNum = Math.floor(randomNum)
        return randomNum

    _getRandomInt: (min, max) ->
        Math.floor(Math.random() * (max - min + 1)) + min

    onLoad: ->
        @_createCount = 0
        @_platformList = [@lastPlatform]
        @_usePhysics()

    _usePhysics: ->
        cc.director.getPhysicsManager().enabled = true

    _createPlatform: (posY) ->
        platform = cc.instantiate(this.platform_prafab[@_getRandomNum()])
        this.platformRootNode.addChild(platform)
        @_setNewPlatformPosition(posY, platform)

    _setNewPlatformPosition: ( posY, platform) ->
        posY = posY + @_getRandomInt(200, 500)
        platform.setPosition(@_getRandomInt(-300, 300), posY)
        platform

    _removeOlgPlatform: ->
        existPlatformList = []
        playerPos = this.player.convertToWorldSpaceAR(cc.Vec2.ZERO)
        for existPlatform in @_platformList
            if playerPos.y - existPlatform.getPosition().y > cc.winSize.width * 4
                # console.log("remove platform")
                existPlatform.removeFromParent()
            else
                existPlatformList.push existPlatform
        @_platformList = existPlatformList
        return

    _createNewPlatform: ->
        playerPos = this.player.convertToWorldSpaceAR(cc.Vec2.ZERO)
        platformPos = @lastPlatform.getPosition()
        if (platformPos.y - playerPos.y ) < cc.winSize.height * 0.8
            # console.log("create new platform:#{++@_createCount}")
            newPlatform = @_createPlatform(platformPos.y)
            @_platformList.push newPlatform
            @lastPlatform = newPlatform
        return

    update: (dt) ->
        @_removeOlgPlatform()
        @_createNewPlatform()
        @_changeRigidBodyActive(dt)
        @_checkGameOver()
        @_addScore()
        return

    _getPlayerDir: ->
        @_lastPlayerY ?= 0
        playerPos = this.player.convertToWorldSpaceAR(cc.Vec2.ZERO)
        dir = "up"
        if playerPos.y > @_lastPlayerY
            dir = "up"
        else
            dir = "down"
        @_lastPlayerY = playerPos.y
        return dir

    _isTimeOk: (dt) ->
        @_changeRigidBodyTime ?= 0
        @_changeRigidBodyTime += dt
        return false if @_changeRigidBodyTime < 0.05
        @_changeRigidBodyTime = 0
        return true

    _changeRigidBodyActive: (dt) ->
        return unless @_isTimeOk()
        playerDir = @_getPlayerDir()
        for platform, index in @_platformList
            rigidBody = platform.getComponent(cc.RigidBody)
            rigidBody.active = playerDir is "down"
        return

    _checkGameOver: ->
        playerPos = this.player.convertToWorldSpaceAR(cc.Vec2.ZERO)
        firstPlarform = @_platformList[0]
        if playerPos.y + 200 < firstPlarform.getPosition().y
            # console.log("game over")
            cc.director.emit("set_score",
                { score: @_score }
            )
            cc.director.loadScene("gameOver")
        return

    _addScore: ->
        @_lastHigh ?= 0
        playerPos = this.player.convertToWorldSpaceAR(cc.Vec2.ZERO)
        if playerPos.y > @_lastHigh
            @_score = Math.floor(playerPos.y / 10)
            @scoreLabel.string = "得分: #{@_score}"
            @_lastHigh = playerPos.y
        return

}
