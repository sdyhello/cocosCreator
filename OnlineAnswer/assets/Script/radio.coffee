cc.Class {
    extends: cc.Component

    properties: {
        radioButton: {
            default: [],
            type: cc.Toggle
        }
    }

    update: (dt) ->
        # do your update here

    onLoad: ->
        @_answer = {}

    onAnswer_1: (toggle)->
        @_answer["1"] = toggle
        index = @radioButton.indexOf(toggle)
        TDGA?.onEvent("answer_1", {"score": index + ""})
        console.log("toggle:#{index}")
}
