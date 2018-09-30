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
    onStartGame: ->
        cc.director.loadScene("game")

    onLoad: ->
        defaultJob = [
            {
                "targetPos": {
                    "x": 1771,
                    "y": -218
                },
                "eraserPos": {
                    "x": -150,
                    "y": -198
                },
                "length": 2470,
                "power": {
                    "x": 563.2,
                    "y": 2406.4
                },
                "pencilPos": {
                    "x": 0,
                    "y": 39
                }
            },
            {
                "targetPos": {
                    "x": 1962.8266666666668,
                    "y": 544
                },
                "eraserPos": {
                    "x": -172.3802959461242,
                    "y": -198.0320000000001
                },
                "length": 4019.0459984650315,
                "power": {
                    "x": 1433.6,
                    "y": 3754.6666666666665
                },
                "pencilPos": {
                    "x": -0.00006044363340151904,
                    "y": 35.8000675227334
                }
            },
            {
                "targetPos": {
                    "x": 2506.826666666667,
                    "y": 956
                },
                "eraserPos": {
                    "x": -229.0000604873573,
                    "y": -197.8888828662955
                },
                "length": 6473.465632702299,
                "power": {
                    "x": 3003.7333333333345,
                    "y": 5734.4
                },
                "pencilPos": {
                    "x": -0.00009798082385259477,
                    "y": 35.80011195521911
                }
            },
            {
                "targetPos": {
                    "x": 94.82666666666671,
                    "y": 544
                },
                "eraserPos": {
                    "x": 110.93333357064512,
                    "y": -198.03199999999998
                },
                "length": 2566.363646181976,
                "power": {
                    "x": -614.4000000000005,
                    "y": 2491.7333333333336
                },
                "pencilPos": {
                    "x": -0.0000604437249194234,
                    "y": 35.800067522734935
                }
            }
        ]
        #247
        #-167, {x: 563.2, 2406.4}
        #-150, -198

        unless cc.sys.localStorage.getItem("goodJob")
            console.log("add default good job")
            cc.sys.localStorage.setItem("goodJob", JSON.stringify defaultJob)
        

    update: (dt) ->
        # do your update here
}
