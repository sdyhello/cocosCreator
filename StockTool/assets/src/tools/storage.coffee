storage = 
	setItem: (name, value)->
		cc.sys.localStorage.setItem(name, JSON.stringify value)

	getItem: (name)->
		try JSON.parse cc.sys.localStorage.getItem(name)

module.exports = storage
