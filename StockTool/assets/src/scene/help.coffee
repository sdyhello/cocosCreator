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
        @m_help_content.string = "一、查询单个股票的基本信息\n
1、打开查询页面\n
2、在股票代码后面的输入框内输入股票代码（暂不支持名称查询）\n
3、如果想改变统计时间，则在时间后面的输入框内输入对应的年数\n
二、查询行业对比数据\n
1、在查询个股的基础上，点击页面上方的300（沪深300）500（中证500）1000（中证1000），all（整个A股市场的股票）\n
2、点击行业对比按钮，便可以看到数据\n
三、筛选股票\n
1、点击筛选按钮，进入条件编辑界面\n
2、在对应的项填入相应数据，注意：这个地方没有做边界处理，请按提示填，不然会出错（懒得处理），若不想让某个条件生效，可以填  “-1”，然后点击确定。\n
3、在显示界面，默认加载沪深300，可自己选择加载中证500， 中证1000，所有股票。注：加载完成后，需要点南继续筛选按钮，才会刷新筛选结果。\n
果你有其他好的建议，欢迎留言，我将积极采纳意见.\n如果在使用过程中有任何疑问，欢迎咨询。\n谢谢你的支持！:-)
\n如果有需要，可以下载安卓版本，安卓版因为数据都在包内，所以加载起来非常快。以后如果有需要可以再编译一个windows版。
\n详情请关注微信公众号，回复“小工具”。"
        TDGA?.onEvent("help")

    onReturn: ->
        cc.director.loadScene("welcome")
}
