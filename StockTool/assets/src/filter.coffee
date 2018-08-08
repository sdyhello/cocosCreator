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
        m_filter_1 : cc.Node;
        m_filter_2 : cc.Node;
    }

    onLoad: ->
        @_editboxObjTable = []
        @_editboxDataObj = {}
        for index in [1..5]
            @_setEventHandler(@m_filter_1, index)
            @_setEventHandler(@m_filter_2, index)

    _setEventHandler: (node, index)->
        editTitle = node.getChildByName("filterItem_#{index}").getChildByName("filterName")
        editboxNode = editTitle.getChildByName("inputLabel")
        editboxObj = editboxNode.getComponent("cc.EditBox")
        @_editboxObjTable.push editboxObj
        @_addEditBoxEventHandler(editboxObj)

    update: (dt) ->
        # do your update here

    _addEditBoxEventHandler: (editboxObj)->
        editboxEventHandler = new cc.Component.EventHandler()
        editboxEventHandler.target = @node
        editboxEventHandler.component = "filter"
        editboxEventHandler.handler = "onTextChanged"
        editboxEventHandler.customEventData = {index: @_editboxObjTable.length}
        editboxObj.editingDidEnded.push(editboxEventHandler)

    onTextChanged: (editbox, customEventData)->
        @_editboxDataObj[customEventData.index] = editbox.string
        console.log("Arkad onTextChanged:#{editbox.string}, customEventData:#{customEventData.index}")

    onSubmit: ->
        console.log(JSON.stringify @_editboxDataObj)

}
