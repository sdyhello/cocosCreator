cc.Class {
    extends: cc.Component

    properties: {
        platformRootNode: cc.Node
        platform_prefab: [cc.Prefab],
        player: cc.Node
        lastPlatform: cc.Node
        scoreLabel: cc.Label
        monsterPrefab: cc.Prefab
        bulletPrefab: cc.Prefab
        touchNode: cc.Node
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
        @_bulletList = []
        @_monsterList = []
        @_usePhysics()
        @_createListener()

    _usePhysics: ->
        cc.director.getPhysicsManager().enabled = true

    _createMonster: ->
        randNum = @_getRandomInt(1, 20)
        return if randNum < 19
        posY = @_platformList[@_platformList.length - 1].y + 100
        monster = cc.instantiate(this.monsterPrefab)
        this.platformRootNode.addChild(monster)
        monster.setPosition(0, posY)
        @_monsterList.push monster

    _createPlatform: (posY) ->
        platform = cc.instantiate(this.platform_prefab[@_getRandomNum()])
        this.platformRootNode.addChild(platform)
        @_setNewPlatformPosition(posY, platform)

    _setNewPlatformPosition: ( posY, platform) ->
        posY = posY + @_getRandomInt(200, 500)
        platform.setPosition(@_getRandomInt(-300, 300), posY)
        platform

    _removeOldPlatform: ->
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
            @_createMonster()
        return

    update: (dt) ->
        @_createNewPlatform()
        @_changeRigidBodyActive(dt)
        @_checkGameOver()
        @_addScore()
        @_cleanItems(dt)
        return

    _cleanItems: (dt) ->
        @_cleanTime ?= 0
        @_cleanTime += dt
        return if @_cleanTime < 1
        @_cleanTime = 0
        @_cleanBullets()
        @_removeOldPlatform()
        @_cleanMonster()

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
            cc.director.loadScene("gameOver")
        return

    _addScore: ->
        @_lastHigh ?= 0
        playerPos = this.player.convertToWorldSpaceAR(cc.Vec2.ZERO)
        if playerPos.y > @_lastHigh
            @_score = Math.floor(playerPos.y / 10)
            @scoreLabel.string = "得分: #{@_score}"
            @_lastHigh = playerPos.y
            cc.director.emit("set_score",
                { score: @_score }
            )
        return

    _createBullet: ->
        bullet = cc.instantiate(this.bulletPrefab)
        this.platformRootNode.addChild(bullet)
        bullet.setPosition(this.player.x, this.player.y + this.player.height * 1.5)
        body = bullet.getComponent(cc.RigidBody)
        body.linearVelocity = cc.v2()
        speedY = this.player.getComponent(cc.RigidBody).linearVelocity.y / 3
        body.applyLinearImpulse(cc.v2(10, Math.max(speedY, 200)), body.getWorldCenter(), true)
        @_bulletList.push bullet


    _createListener: ->
        this.touchNode.on(cc.Node.EventType.MOUSE_DOWN,
            =>
                @_createBullet()
        )
        this.touchNode.on(cc.Node.EventType.TOUCH_END,
            =>
                @_createBullet()
        )

    _cleanBullets: ->
        existBullet = []
        for bullet in @_bulletList
            unless bullet
                console.log("bullet is null")
                continue
            isNearPlayer = (bullet.y - this.player.y) < this.player.height
            if this.player.y - bullet.y > cc.winSize.height or isNearPlayer
                # console.log("remove bullet")
                bullet.removeFromParent()
            else
                existBullet.push bullet
        @_bulletList = existBullet
        return

    _cleanMonster: ->
        existMonster = []
        for monster in @_monsterList
            if this.player.y - monster.y > cc.winSize.height * 3
                monster.removeFromParent()
            else
                existMonster.push monster
        @_monsterList = existMonster
        return
}
