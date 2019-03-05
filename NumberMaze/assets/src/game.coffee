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
        numberPrefab: {
            default: null,
            type: cc.Prefab
        }
        successLabel: cc.Label
        timeLabel: cc.Label
        panBg: cc.Node
        stepLabel: cc.Label
    }

    update: (dt) ->
        return if @_isSuccess
        @_costTime += dt
        @timeLabel.string = "当前用时: " + @_costTime.toFixed(2)
        # do your update here

    _getBeginPosition: (width, height, gap) ->
        winSize = cc.director.getWinSize()
        number = cc.instantiate(this.numberPrefab)
        itemSize = number.getContentSize()

        allGapX = (width - 1) * gap
        allItemWidth = width * itemSize.width
        allNeedWidth = allGapX + allItemWidth
        beginX = (winSize.width - allNeedWidth) / 2 + itemSize.width / 2

        allGapY = (height - 1) * gap
        allItemHeight = height * itemSize.height
        allNeedHeight = allGapY + allItemHeight
        beginY = (winSize.height - allNeedHeight) / 2 + itemSize.height / 2

        @panBg.setPosition(cc.v2(beginX - itemSize.width / 2 - 5, beginY - itemSize.height / 2 - 5))
        @panBg.setContentSize(cc.size(allNeedWidth + 10, allNeedHeight + 10))

        return cc.v2(beginX, winSize.height - beginY)

    _initMaze: ->
        width = 4
        height = 4
        gap = 10
        beginPosition = @_getBeginPosition(width, height, gap)

        
        winSize = cc.director.getWinSize()
        count = 1
        @_mazeMap = {}
        @_mazeMapRect = {}
        for col in [0...width]
            for row in [0...height]
                number = cc.instantiate(this.numberPrefab)
                itemSize = number.getContentSize()
                this.node.addChild(number)
                posX = beginPosition.x + (itemSize.width + gap) * row
                posY = beginPosition.y - (itemSize.width + gap) * col
                @_mazeMap[count] ?= {}
                @_mazeMap[count].numberNode = number
                number.setPosition(cc.v2(posX, posY))
                # @_addButtonCallback(number, count)
                numberLabel = cc.find("numberBg/number", number).getComponent(cc.Label)
                numberLabel.string = count
                @_mazeMapRect[count] ?= {}
                @_mazeMapRect[count] = cc.rect({
                    x: posX - itemSize.width / 2
                    y: posY - itemSize.height / 2
                    width: itemSize.width,
                    height: itemSize.height
                })
                count++
        @_mazeMap[16].numberNode.active = false
        
        return

    _randomMix: ->
        nextIndexTable = [-4, -1, 1, 4]
        moveSuccessCount = 0
        for index in [0..500]
            targetIndex = null
            for key, value of @_mazeMap
                if @_getNodeLabel(value.numberNode).string is "16"
                    targetIndex = key
                    break
            nextIndex = @_randomInt(0, 3)
            status = @_tryMove(parseInt(targetIndex) + nextIndexTable[nextIndex])
            moveSuccessCount++ if status
        @_isSuccess = false
        @_costStep = 0
        @_setStepInfo()

    _getCurrentIndex: (point) ->
        for index, value of @_mazeMapRect
            if @_isInRect(value, point)
                return index
        return

    _isInRect: (rect, point) ->
        return false if point.x < rect.x
        return false if point.x > rect.x + rect.width
        return false if point.y > rect.y + rect.height
        return false if point.y < rect.y
        return true

    _checkIndex: (currentIndex, targetIndex) ->
        if targetIndex < 1 or targetIndex > 16
            return false
        if currentIndex isnt 0 and currentIndex % 4 is 0 and targetIndex - currentIndex is 1
            return false
        if targetIndex isnt 0 and targetIndex % 4 is 0 and currentIndex - targetIndex is 1
            return false
        return true

    _move: (currentIndex, num) ->
        targetIndex = currentIndex + num
        if @_checkIndex(currentIndex, targetIndex)
            left = @_mazeMap[targetIndex]
            if @_getNodeLabel(left.numberNode).string isnt "16"
                if @_move(targetIndex, num)
                    @_switchItem(currentIndex, targetIndex)
                    return true
                else
                    return false
            else
                @_switchItem(currentIndex, targetIndex)
                return true
        return false

    _tryMove: (currentIndex) ->
        return unless currentIndex?
        currentIndex = parseInt(currentIndex)
        return false unless @_checkIndex(0, currentIndex)
        return true if @_move(currentIndex, -1)
        return true if @_move(currentIndex, 1)
        return true if @_move(currentIndex, -4)
        return true if @_move(currentIndex, 4)
        return false

    _getNodeLabel: (node) -> cc.find("numberBg/number", node).getComponent(cc.Label)

    _checkSuccess: ->
        if @_getResult() is "12345678910111213141516"
            @successLabel.node.active = true
            @_isSuccess = true
            @_saveFastTime(@_costTime.toFixed(2))
            @_addPassCount()
        return

    _getResult: ->
        result = ""
        for index, value of @_mazeMap
            numberLabel = @_getNodeLabel(value.numberNode)
            result += numberLabel.string
        return result

    _switchItem: (leftIndex, rightIndex) ->
        leftNode = @_mazeMap[leftIndex].numberNode
        rightNode = @_mazeMap[rightIndex].numberNode
        @_mazeMap[rightIndex].numberNode = leftNode
        @_mazeMap[leftIndex].numberNode = rightNode

        leftPos = leftNode.getPosition()
        rightPos = rightNode.getPosition()
        leftNode.setPosition(rightPos)
        rightNode.setPosition(leftPos)

        @_costStep++
        @_setStepInfo()

    _setStepInfo: ->
        @stepLabel.string = "步数: " + @_costStep

    _randomInt: (min, max) ->
        Math.floor(Math.random() * (max - min + 1)) + min

    _saveFastTime: (time) ->
        time = parseFloat(time)
        fastTime = cc.sys.localStorage.getItem("fast_time") or 10000
        if time < fastTime
            cc.sys.localStorage.setItem("fast_time", time)
            cc.sys.localStorage.setItem("use_step", @_costStep)
        return

    onReturn: ->
        cc.director.loadScene("welcome")

    _createEventListener: ->
        this.node.on(cc.Node.EventType.TOUCH_START, @_onTouchStart.bind(@))
        this.node.on(cc.Node.EventType.TOUCH_END, @_onTouchEnd.bind(@))

    _onTouchStart: (event) ->
        pos = this.node.convertToNodeSpaceAR(event.getLocation())
        @_touchStartPos = pos

    _onTouchEnd: (event) ->
        return if @_isSuccess
        pos = this.node.convertToNodeSpaceAR(event.getLocation())
        subPos = pos.sub(@_touchStartPos)
        dir = subPos.normalize().negSelf()
        index = @_getCurrentIndex(@_touchStartPos)
        @_tryMove(index)
        @_checkSuccess()

    onLoad: ->
        @_costTime = 0
        @_costStep = 0
        @successLabel.node.active = false
        @_isSuccess = true
        @_initMaze()
        @_createEventListener()

    _addPassCount: ->
        count = cc.sys.localStorage.getItem("pass_count") or 0
        count = parseInt(count)
        cc.sys.localStorage.setItem("pass_count", count + 1)

    onBegin: ->
        return if @_costTime isnt 0
        @_randomMix()
    
}
