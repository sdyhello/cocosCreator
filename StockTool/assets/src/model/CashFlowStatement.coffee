TableBase 	= require "./TableBase"
TitleName 	= require "../title"

class CashFlowStatement extends TableBase
	getFirstColTitle: ->
		TitleName.getCashFlowTitle()

	getFilePath: ->
		"allA/xjllb_#{@_stockCode}"
		
	getWorkCashFlow: ->
		@getValue(@_data["经营活动产生的现金流量净额(万元)"])

module.exports = CashFlowStatement