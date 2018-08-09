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
        m_help_content : cc.Label,
    }

    update: (dt) ->
        # do your update here

    onLoad: ->
        @m_help_content.string = "开发中..."
        TDGA?.onEvent("help")
        
    onReturn: ->
        cc.director.loadScene("welcome")
}
