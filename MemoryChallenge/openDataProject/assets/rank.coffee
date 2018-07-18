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
            (data)=>
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

    _createImage: (sprite,url)->
        image = wx.createImage()
        image.onload = ->
            texture = new cc.Texture2D()
            texture.initWithElement(image)
            texture.handleLoadedTexture()
            console.log("texture:#{texture}")
            sprite.spriteFrame = new cc.SpriteFrame(texture)
            sprite.node.width=50
            sprite.node.height=50
        image.src = url

    _initFriendsInfo: ->
        @_dataIndex = 1
        wx.getFriendCloudStorage(
            keyList: ["score"]
            success: (res)=>
                console.log("friends data :#{JSON.stringify res}")
                res.data.sort((a, b)-> b.KVDataList[0].value - a.KVDataList[0].value )
                for infoObj in res.data
                    friendName = infoObj.nickname
                    @_createImage(@["m_icon_#{@_dataIndex}"], infoObj.avatarUrl)
                    for info in infoObj.KVDataList
                        if @_dataIndex > 5
                            break
                        @["m_rank_#{@_dataIndex}"].visible = true
                        @["m_rank_#{@_dataIndex}"].string = "No.#{@_dataIndex++}: " + friendName + ": " + info.value + "分"
                return
        )
    _show: ->
        
        moveTo = cc.moveTo(0.5, 0, 73)
        @display.runAction(moveTo)

    _hide: ->
        moveTo = cc.moveTo(0.5, 0, 1000)
        @display.runAction(moveTo)
        

    update: (dt) ->
        # do your update here
}
