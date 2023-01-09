function select3dLibInit  = (
	
	struct select3dLibStruct
	(
		version = "0.0.1",

		-- recursivly selecti all of the children of an inital object, return parent as part of the array optional.
		function collectAllChildren obj includeParent:true =
		(
			-- start collecting direct children of <obj>
			allChildren = #(obj)

			-- add children and their children etc recursively
			i = 0
			while i < allChildren.count do
				(
				i += 1
				join allChildren allChildren[i].children
				)

			-- remove initial object if <includeParent> == false
			if not includeParent then deleteitem allChildren 1

			-- return array containing children
			return allChildren
		),

		-- selects all items in the list, by animhandle
		function selectByAnimhandle arg_list =
		(

			print "selectByAnimhandle"

			curHandles 	= arg_list
			selList 	= #()

			for curHandle in curHandles do 
			(
				newNode = ( getAnimByHandle curHandle )
				append selList newNode
			)

			select selList
		),

		ender = undefined
	)	

	return select3dLibStruct()
)

select3dLib = select3dLibInit()