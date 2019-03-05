cc.Class {
    extends: cc.Component

    properties: {
        m_light_1: cc.Sprite,
        m_light_2: cc.Sprite,
        m_light_3: cc.Sprite,
        m_light_4: cc.Sprite,
        m_light_5: cc.Sprite,
        m_light_6: cc.Sprite,
        m_light_7: cc.Sprite,
        m_light_8: cc.Sprite,
        m_light_9: cc.Sprite,
        m_score: cc.Label,
        m_tips: cc.Label,
        m_btn_1: cc.Button,
        m_btn_2: cc.Button,
        m_btn_3: cc.Button,
        m_btn_4: cc.Button,
        m_btn_5: cc.Button,
        m_btn_6: cc.Button,
        m_btn_7: cc.Button,
        m_btn_8: cc.Button,
        m_btn_9: cc.Button,
        touch_sound: cc.AudioClip,
        light_sound: cc.AudioClip,
        m_bear: cc.Sprite,
    }
    onLoad: ->
        @_ligheItemFunc = =>
            @_lightItem()
        @_reset()

    _reset: ->
        @_numberTable = []
        @_lightIndex = 0
        @_touchIndex = 0
        @_score = 0
        @_isMasterChallenge = cc.sys.localStorage.getItem("is_master_challenge") or false
        @_bearOriginPos = @m_bear.node.getPosition()
        @_hideAllLight()
        @_prepareLevel()

    onClickButton: ->
        console.log("hello world")

    _hideAllLight: ->
        for index in [1..9]
            @["m_light_#{index}"].setVisible false
        return

    _getNumberTable: ->
        if @_isMasterChallenge
            genNumberTable = []
            for index in [1..9]
                num = @_randomInt(1, 9)
                while num in genNumberTable
                    num = @_randomInt(1, 9)
                genNumberTable.push num
                @_numberTable.push num
        else
            num = @_randomInt(1, 9)
            @_numberTable.push num
            num = @_randomInt(1, 9)
            @_numberTable.push num

    _randomInt: (min, max)->
        Math.floor(Math.random() * (max - min + 1)) + min

    _bearJump: (sprite, pos)->
        if pos
            seq = []
            seq.push cc.delayTime(1)
            seq.push cc.jumpTo(0.2, @_bearOriginPos, 50, 1)
            @m_bear.node.runAction(cc.sequence(seq))
            return
        pos = sprite.node.parent.convertToWorldSpaceAR(sprite.node.getPosition())
        pos = cc.v2(pos.x - 360, pos.y - 640)
        seq = []
        seq.push cc.show()
        seq.push cc.jumpTo(0.2, pos, 50, 1)
        @m_bear.node.runAction(cc.sequence(seq))

    _lightItem: ->
        lightSprite = @["m_light_#{@_numberTable[@_lightIndex]}"]
        @_bearJump(lightSprite)
        @_runLightAction(lightSprite)
        @_runBtnAction(@["m_btn_#{@_numberTable[@_lightIndex]}"])
        @_lightIndex++
        if @_lightIndex >= @_numberTable.length
            @_bearJump(null, true)
            @_setBtnStatus(true)
            @_lightIndex = 0
            @unschedule(@_ligheItemFunc)

    _prepareLevel: ->
        @_updateTips("第#{@_numberTable.length / 2 + 1}关")
        @scheduleOnce(
            =>
                @gotoNextLevel()
            1
        )

    _updateTips: (tips)->
        @m_tips.string = tips
        
    _updateScore: ->
        if @_isMasterChallenge
            @_score = @_score + (@_touchIndex + 1) * (@_touchIndex + 1)
            if @_touchIndex is @_numberTable.length - 1
                @_onPassMasterChallenge()
        else
            @_score = @_score + @_touchIndex + 1
        @m_score.string = "当前得分: #{@_score}"

    _onPassMasterChallenge: ->
        @_score *= 2

    _beginTips: ->
        @_setBtnStatus(false)
        @schedule(@_ligheItemFunc, 1)

    _runLightAction: (sprite) ->
        seq = []
        seq.push cc.delayTime(0.2)
        seq.push cc.show()
        seq.push cc.callFunc(=> cc.audioEngine.playEffect(@light_sound, false))
        seq.push cc.delayTime(0.7)
        seq.push cc.hide()
        sprite.node.runAction(cc.sequence(seq))

    _runBtnAction: (sprite)->
        seq = []
        seq.push cc.delayTime(0.2)
        seq.push cc.hide()
        seq.push cc.delayTime(0.7)
        seq.push cc.show()
        sprite.node.runAction(cc.sequence(seq))

    gotoNextLevel: ->
        @_getNumberTable()
        @_beginTips()

    _setBtnStatus: (status)->
        for index in [1..9]
            @["m_btn_#{index}"].enabled =  status
        return
    
    _dealTouchEvent: (touchNumber)->

        if touchNumber is @_numberTable[@_touchIndex]
            @_updateScore()
            @_touchIndex++
        else
            @_updateTips("失败了，重新开始吧！")
            @_saveScore()
            @_setBtnStatus(false)
            cc.director.loadScene('memoryGameover')
        if @_touchIndex >= @_numberTable.length
            @_setBtnStatus(false)
            @_touchIndex = 0
            @_prepareLevel()

    _saveScore: ->
        cc.sys.localStorage.setItem("current_level_score", @_score)
        cc.sys.localStorage.setItem("numbers", JSON.stringify @_numberTable)
        @_saveHighScore()

    _saveHighScore: ->
        highScoreTable = cc.sys.localStorage.getItem("high_score_table") or []
        if highScoreTable.length < 10
            highScoreTable.push @_score
            highScoreTable.sort((a, b) -> b - a)
            cc.sys.localStorage.setItem("high_score_table", highScoreTable)
            return
        highScoreTable.sort((a, b) -> b - a)
        if @_score > highScoreTable[9]
            highScoreTable.push @_score
            highScoreTable.sort((a, b) -> b - a)
            highScoreTable = highScoreTable.slice(0, 10)
            cc.sys.localStorage.setItem("high_score_table", highScoreTable)
        return

    onTouch1: -> @_dealTouchEvent(1)
    onTouch2: -> @_dealTouchEvent(2)
    onTouch3: -> @_dealTouchEvent(3)
    onTouch4: -> @_dealTouchEvent(4)
    onTouch5: -> @_dealTouchEvent(5)
    onTouch6: -> @_dealTouchEvent(6)
    onTouch7: -> @_dealTouchEvent(7)
    onTouch8: -> @_dealTouchEvent(8)
    onTouch9: -> @_dealTouchEvent(9)
    onRestart: ->
        @_saveScore()
        cc.director.loadScene('memoryWelcome')
}
