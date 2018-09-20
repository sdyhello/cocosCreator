cc.Class {
    extends: cc.Component

    properties: {
        player: cc.Node
        bgLayerTable: [cc.Node]
    }

    onLoad: ->
        @speed = 5

    _findFarestBackgroundLayer: ->
        maxY = 0
        for bgLayer in @bgLayerTable
            boundingBox = bgLayer.getBoundingBox()
            farY = boundingBox.yMax
            if farY > maxY
                maxY = farY
        return maxY

    _fillBackgroundLayer: (maxY) ->
        minYLayer = @bgLayerTable[0]
        minY = minYLayer.getBoundingBox().yMax
        for bgLayer, index in @bgLayerTable
            continue if index is 0
            boundingBox = bgLayer.getBoundingBox()
            if boundingBox.yMax < minY
                minY = boundingBox.yMax
                minYLayer = bgLayer
        minYLayer.setPosition(cc.v2(0, maxY))

    _updateBackgroundLayer: (dt) ->
        playerPos = @player.convertToWorldSpaceAR(cc.Vec2.ZERO)
        maxY = @_findFarestBackgroundLayer()
        if maxY - playerPos.y < cc.winSize.height
            console.log(maxY, playerPos.y, cc.winSize.height)
            @_fillBackgroundLayer(maxY)
        return

    update: (dt) ->
        @_updateBackgroundLayer(dt)
        # do your update here
}
