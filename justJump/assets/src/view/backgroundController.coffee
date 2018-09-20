cc.Class {
    extends: cc.Component

    properties: {
        player: cc.Node
        bgLayerTable: [cc.Node]
    }

    onLoad: ->
        @speed = 5

    _fillUpLayer: ->
        playerPos = @player.convertToWorldSpaceAR(cc.Vec2.ZERO)
        maxY = @bgLayerTable[@bgLayerTable.length - 1].getBoundingBox().yMax
        if maxY - playerPos.y < cc.winSize.height
            @bgLayerTable[0].setPosition(cc.v2(0, maxY + cc.winSize.height / 2))
        return

    _fillDownLayer: ->
        playerPos = @player.convertToWorldSpaceAR(cc.Vec2.ZERO)
        minY = @bgLayerTable[0].getBoundingBox().yMin
        if playerPos.y - minY < cc.winSize.height
            pos = cc.v2(0, minY - cc.winSize.height / 2)
            @bgLayerTable[@bgLayerTable.length - 1].setPosition(pos)
        return

    _updateBackgroundLayer: (dt) ->
        @_orderLayerTable()
        @_fillUpLayer()
        @_fillDownLayer()
        
    _orderLayerTable: ->
        this.bgLayerTable.sort( (a, b) -> a.y - b.y)

    update: (dt) ->
        @_updateBackgroundLayer(dt)
}
