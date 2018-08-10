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
        @m_help_content.string = "这个工具主要用来分析财务数据，工具背后是3000多家上市公司的历年财务报表，数据真实可靠。
        \n工具有两个主要功能:\n第一个功能为查询指定股票代码的财务信息，计算的信息包括：\nPE，投资性资产占比，负债表中排名占前10的
        资产列表，有息负债率，应收账款周转天数，预收账款占总资产比例，存货周转率，历年净利润，毛利率，净利率，净利润增长率，净
        利润复合增长率，经营现金流量与净利润的比值，历年ROE， 平均ROE。在信息展示的基础上，某些指标计算了同行数据对比，如
        应收账款周转天数对比，预收账款占总资产比例对比等\n第二个功能是筛选器，A股有3000多家上市公司，如果没有筛选器，
        很难从众多股票中发现优质股票，这就是这个功能的开发原因。\n该筛选器可根据以下条件筛选股票：\n
        1、净利润复合增长率\n2、历年平均ROE\n3、
        应收账款周转天数\n4、预收账款占总资产比例\n5、经营现金流量与净利润比例\n6、有息负债率\n7、市盈率。
        \n使用时根据个人喜好，填入对应数据，就能筛选出一些股票，如果指定条件填-1，则不会考虑这个条件，所以当全部为-1时，应该能搜索出所有股票
        \n综合这些条件，已经能选出一
        些优质股了。\n如果你有其他好的建议，欢迎留言，我将积极采纳意见.\n如果在使用过程中有任何疑问，欢迎咨询。\n谢谢你的支持！:-)"
        TDGA?.onEvent("help")

    onReturn: ->
        cc.director.loadScene("welcome")
}
