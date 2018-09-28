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
        m_rank_1: cc.Label,
        m_rank_2: cc.Label,
        m_rank_3: cc.Label,
        m_rank_4: cc.Label,
        m_rank_5: cc.Label,

        m_icon_1: cc.Sprite,
        m_icon_2: cc.Sprite,
        m_icon_3: cc.Sprite,
        m_icon_4: cc.Sprite,
        m_icon_5: cc.Sprite,

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
        )

        for index in [1..5]
            @["m_rank_#{index}"].string = "-----"
        @_initFriendsInfo()

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

    

    _initFriendsInfo: ->
        @_dataIndex = 1
        wx.getFriendCloudStorage(
            {
                keyList: ["physicsBallScore"]
                success: (res) =>
                    console.log("friends data :#{JSON.stringify res}")
                    console.log("filter")
                    res.data = res.data.filter(
                        (a) ->
                            console.log(a.nickname, a.KVDataList.length)
                            if a.KVDataList.length > 0

                                return true
                            return false
                    )
                    res.data.sort((a, b) -> b.KVDataList[0].value - a.KVDataList[0].value )
                    for infoObj in res.data
                        friendName = infoObj.nickname
                        @_createImage(@["m_icon_#{@_dataIndex}"], infoObj.avatarUrl)
                        for info in infoObj.KVDataList
                            if @_dataIndex > 5
                                break
                            string = "No.#{@_dataIndex}: " + friendName + ": " + info.value + "分"
                            @["m_rank_#{@_dataIndex}"].visible = true
                            @["m_rank_#{@_dataIndex}"].string = string
                            @_dataIndex++
                    return
            }
        )
}
