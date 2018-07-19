allAnswerTable = {
	"answer_1": [
		"面临贸易战，去杠杆的环境，大盘持续下跌，你的持仓已经跌去15%，此时你会怎么办？", 
		"A、清仓，止损，等这一波过去后再入市",
		"B、仓位不变，有闲钱再择机买入",
		"C、减一半仓位",
		"D、借钱，贷款，在股市中加杠杆"
	]
	"answer_2": [
		"上周你买了一只股票，今天一看，居然上涨了20%，这时你会如何操作？", 
		"A、这么短的时间就赚了20%已经很爽了， 全部卖掉",
		"B、这么短的时间涨这么多，就是买少了，于是追高继续买入",
		"C、仔细分析上涨原因，确定是价值回归还是市场波动",
		"D、不闻不问，任他去吧"
	]
	"answer_3": [
		"某天，你发现一只股票，经过多方面分析，这都是一只大牛股，很可能十年十倍，这时你会？", 
		"A、拿出全部身家，单买这一只股票",
		"B、",
		"C、减一半仓位",
		"D、借钱，贷款，在股市中加杠杆"
	]
	"answer_4": [
		"当你进行投资时，你会？", 
		"A、我怕损失，只拿出5%的钱来买股票，赚了多买一份KFC，输了不心疼",
		"B、拿出大半积蓄，",
		"C、减一半仓位",
		"D、借钱，贷款，在股市中加杠杆"
	]
	"answer_5": [
		"手里捏了一把优秀，低估的蓝筹股，但是三个月过去了，竟然只涨了0.5%，看看那些概念股，看看那些题材股，动不动就3个涨停，这时，你会怎么做？", 
		"A、坚定持有，做一个长期的价值投资者",
		"B、不能错过后面的机会了，转换风格，炒概念股去，去他的价值投资",
		"C、减一半仓位",
		"D、借钱，贷款，在股市中加杠杆"
	]
}

cc.Class {
    extends: cc.Component

    properties: {
        m_content_node: cc.Node,
    }

    update: (dt) ->
        # do your update here

    onLoad: ->
        @_answerResult = {}
        @_answerCount = 4
        @_initAnswer()

    _initAnswer: ->
    	for answerIndex in [1..@_answerCount]
	        answer = @m_content_node.getChildByName("answer_#{answerIndex}")
	        answerLabel = answer.getChildByName("answer").getComponent(cc.Label)
	        answerTable = allAnswerTable["answer_#{answerIndex}"]
	        answerLabel.string = "#{answerIndex}、" + answerTable[0]
	        @_setSelectLabel(answer, answerTable)
	        @_setToggleHandler(answer, answerIndex)
	        @_resetChecked(answer)
	    return

	_resetChecked: (answer)->
		for toggleIndex in [1..4]
			checkmark = answer.getChildByName("toggle#{toggleIndex}").getChildByName("checkmark")
			checkmark.visible = false
		return

	_setSelectLabel: (answer, answerTable)->
    	for index in [1..4]
        	toggleLabel = answer.getChildByName("toggle#{index}").getChildByName("content").getComponent(cc.Label)
        	toggleLabel.string = answerTable[index]
        return

	_setToggleHandler: (answer, answerIndex)->
		for toggleIndex in [1..4]
			checkEventHandler = new cc.Component.EventHandler();
			checkEventHandler.target = @node
			checkEventHandler.component = "onlineAnswer"
			checkEventHandler.handler = "callback"
			checkEventHandler.customEventData = {answerIndex, answerResult: toggleIndex}
			toggle = answer.getChildByName("toggle#{toggleIndex}").getComponent(cc.Toggle)
			toggle.checkEvents.push(checkEventHandler)
		return

	callback: (toggle, customEventData)->
		@_answerResult[customEventData.answerIndex] = customEventData.answerResult
		console.log("customEventData:#{JSON.stringify customEventData}")

	onSubmit: ->
		console.log(JSON.stringify @_answerResult)
}
