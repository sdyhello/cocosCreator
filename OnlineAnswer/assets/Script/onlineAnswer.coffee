allAnswerTable = {
	"answer_1": [
		"面临贸易战，去杠杆的环境，大盘持续下跌，你的持仓已经跌去15%，此时你会怎么办？", 
		"A、清仓，止损，等这一波过去后再入市",
		"B、仓位不变，有闲钱再择机买入",
		"C、减一半仓位",
		"D、借钱，贷款，在股市中加杠杆"
	]
	"answer_2": [
		"面临贸易战，去杠杆的环境，大盘持续下跌，你的持仓已经跌去15%，此时你会怎么办？", 
		"A、清仓，止损，等这一波过去后再入市",
		"B、仓位不变，有闲钱再择机买入",
		"C、减一半仓位",
		"D、借钱，贷款，在股市中加杠杆"
	]
	"answer_3": [
		"面临贸易战，去杠杆的环境，大盘持续下跌，你的持仓已经跌去15%，此时你会怎么办？", 
		"A、清仓，止损，等这一波过去后再入市",
		"B、仓位不变，有闲钱再择机买入",
		"C、减一半仓位",
		"D、借钱，贷款，在股市中加杠杆"
	]
	"answer_4": [
		"面临贸易战，去杠杆的环境，大盘持续下跌，你的持仓已经跌去15%，此时你会怎么办？", 
		"A、清仓，止损，等这一波过去后再入市",
		"B、仓位不变，有闲钱再择机买入",
		"C、减一半仓位",
		"D、借钱，贷款，在股市中加杠杆"
	]
}

cc.Class {
    extends: cc.Component

    properties: {
        radioButton: {
            default: [],
            type: cc.Toggle
        }
        m_content_node: cc.Node,
    }

    update: (dt) ->
        # do your update here

    onLoad: ->
        @_answer = {}
        @_initAnswer()

    _initAnswer: ->
    	for answerIndex in [1..4]
	        answer = @m_content_node.getChildByName("answer_#{answerIndex}")
	        answerLabel = answer.getChildByName("answer").getComponent(cc.Label)
	        answerTable = allAnswerTable["answer_#{answerIndex}"]
	        answerLabel.string = answerTable[0]
	        @_setSelectLabel(answer, answerTable)

    _setSelectLabel: (answer, answerTable)->
    	for index in [1..4]
        	toggleLabel = @_getSelectLabel(answer, "toggle#{index}")
        	toggleLabel.string = answerTable[index]
        return

    _getSelectLabel: (answer, toggleName)->
    	answer.getChildByName(toggleName).getChildByName("content").getComponent(cc.Label)

    onAnswer_1: (toggle)->
        @_answer["1"] = toggle
        index = @radioButton.indexOf(toggle)
        TDGA?.onEvent("answer_1", {"score": index + ""})
        console.log("toggle:#{index}")
}
