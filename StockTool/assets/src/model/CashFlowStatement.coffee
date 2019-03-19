TableBase 	= require "./TableBase"
TitleName 	= require "../title"

class CashFlowStatement extends TableBase
	getFirstColTitle: ->
		TitleName.getCashFlowTitle()

	getFilePath: ->
		"allA/xjllb_#{@_stockCode}"
		
	getWorkCashFlow: ->
		@getValue(@_data["经营活动产生的现金流量净额(万元)"])

	getPayStaffCash: ->
		@getValue(@_data["支付给职工以及为职工支付的现金(万元)"])[0]

	getCapitalExpenditure: ->
		@getValue(@_data["购建固定资产、无形资产和其他长期资产所支付的现金(万元)"])

module.exports = CashFlowStatement