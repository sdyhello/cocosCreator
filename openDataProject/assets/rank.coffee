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
        display: cc.Node,
        m_rank_1: cc.Node,
        m_rank_2: cc.Node,
        m_rank_3: cc.Node,
        m_rank_4: cc.Node,
        m_rank_5: cc.Node,
        m_rank_6: cc.Node,
        m_rank_7: cc.Node,
    }

    start: ->
        wx.onMessage(
            (data) =>
                switch data.message
                    when "Show"
                        @_show()
                    when "Hide"
                        @_hide()
                    when "Refresh"
                        @_initFriendsInfo()
                    when "gameType"
                        @_gameType = data.gameType
                        @_initFriendsInfo()
        )

        for index in [1..7]
            @_updateInfo(@["m_rank_#{index}"], null, "--", "--", "--")

    _createImage: (sprite, url) ->
        image = wx.createImage()
        image.onload = ->
            texture = new cc.Texture2D()
            texture.initWithElement(image)
            texture.handleLoadedTexture()
            sprite.spriteFrame = new cc.SpriteFrame(texture)
            sprite.node.width = 50
            sprite.node.height = 50
        image.src = url

    _updateInfo: (rankNode, iconUrl, fastTime, useStep, passCount) ->
        iconObj = rankNode.getChildByName("icon")
        iconSprite = iconObj.getChildByName("icon").getComponent(cc.Sprite)
        @_createImage(iconSprite, iconUrl)
        fastTimeLabel = iconObj.getChildByName("rank_1").getComponent(cc.Label)
        fastTimeLabel.string = fastTime
        useStepLabel = iconObj.getChildByName("rank_2").getComponent(cc.Label)
        useStepLabel.string = useStep
        passCountLabel = iconObj.getChildByName("rank_3").getComponent(cc.Label)
        passCountLabel.string = passCount

    _initFriendsInfo: ->
        @_dataIndex = 1
        if @_gameType is "numberMaze"
            dataTable = ["fastTime", "useStep", "passCount"]
        else if @_gameType is "memory"
            dataTable = ["score"]
        else if @_gameType is "physicsBall"
            dataTable = ["physicsBallScore"]

        wx.getFriendCloudStorage(
            {
                keyList: dataTable
                success: (res) =>
                    console.log("friends data :#{JSON.stringify res.data}")
                    res.data = res.data.filter(
                        (a) ->
                            console.log(a.nickname, a.KVDataList.length)
                            if a.KVDataList.length > 0

                                return true
                            return false
                    )
                    res.data.sort((a, b) -> b.KVDataList[0].value - a.KVDataList[0].value )
                    if @_gameType is "numberMaze"
                        res.data.sort((a, b) -> a.KVDataList[0].value - b.KVDataList[0].value )
                    for infoObj in res.data
                        if @_dataIndex > 7
                            break
                        friendName = infoObj.nickname
                        
                        rankNode = @["m_rank_#{@_dataIndex}"]
                        iconUrl = infoObj.avatarUrl
                        
                        fastTime = infoObj.KVDataList[0].value
                        useStep = infoObj.KVDataList[1]?.value or "--"
                        passCount = infoObj.KVDataList[2]?.value or "--"
                        
                        @_updateInfo(rankNode, iconUrl, fastTime, useStep, passCount)
                        
                        @_dataIndex++
                    for index in [@_dataIndex..7]
                        @["m_rank_#{index}"].active =  false
                    return
            }
        )
}
