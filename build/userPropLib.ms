function userPropLibInit  = (
	
	struct userPropLibStruct
	(
		version = "0.0.1",

		function isPropSet arg_prop arg_list =
		(
			-- Checks all selected objects to see if they have object properties for a stored asset name
			print "assetNameCheck Function"
		),

		function setProp arg_prop arg_val =
		(
			-- Sets the asset name object property on all selected objects
			print "checkForAssetName Function"
		),

		-- Removes asset related names from the user defined field of the object properties of a node.
		function clearProps arg_node arg_props =
		(
			-- setup local properties
			removeList 		= arg_props	-- This list of keys that will be removed form the buffer, can be multiples
			-- removeList 		= #("AssetName")	-- This list of keys that will be removed form the buffer, can be multiples
			newBuffer 		= stringStream ""	-- An empty string to build the new data
			buffer 			= ( ( getUserPropBuffer arg_node ) as StringStream )

			while not eof buffer do
			(
				str 	= readLine buffer 				-- read the line 
				curKey 	= ( filterstring str " =" )[1] 	-- get the first part of a key / value pair
				newStr 	= str 							-- buffer the line
				
				-- if the key is a valid key then 
				if curKey != undefined then 
				(
					-- get the current remove item
					for curRemove in removeList do 
					(
						-- compare it to the key, and if they match, make the line empty
						if curKey == curRemove then
						(
							newStr = ""
						)
					)
				)	

				-- If the newLine is not empty, add it to the buffer
				if newStr != "" then 
				(
					format "%\n" newStr to:newBuffer
				)else()
			)

			-- apply the buffer to the object properties
			setUserPropBuffer arg_Node newBuffer
		),

		-- Completed 2023/01/09
		-- removes all user properties from passed node
		function clearAll arg_node =
		(
			setUserPropBuffer arg_node ""
		),

		ender = undefined
	)	

	return userPropLibStruct()

)

userPropLib = userPropLibInit()