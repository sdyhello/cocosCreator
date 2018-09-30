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
    }
    onLoad: ->
        goodJobObj = cc.sys.localStorage.getItem("goodJob") or []
        console.log(JSON.stringify JSON.parse goodJobObj)

    onReturn: ->
        cc.director.loadScene("welcome")

    update: (dt) ->
        # do your update here
}
