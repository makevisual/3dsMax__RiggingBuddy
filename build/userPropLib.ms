-- userPropLib - userPropLib is a collection of various functions for working with user property data on nodes in 3dsMax.
-- aarondabelow@gmail.com

function userPropLibInit  = (
	
	struct userPropLibStruct
	(
		version = "0.0.1",

		-- Completed 2023/01/11
		-- Inspect the node to see if a valid property is set.
		function isPropSet arg_node arg_prop =
		(
			-- Checks arg_node to see if they have arg_prop set

			validProperty 	= true
			curProp 		= getUserProp arg_node arg_prop

			if curProp == undefined then
				( validProperty = false )

			if curProp == "" then
				( validProperty = false )

			-- Return true if the property is valid
			return validProperty
		),

		-- Completed 2023/01/11
		-- Sets the user property on the passed node
		function setProp arg_node arg_prop arg_val =
		(
			-- Why did I just wrap this function? To be able to sanatize inputs later, possibly have hooks that go elsewhere too, like a CA on the node.

			setUserProp arg_node arg_prop arg_val
		),

		-- Completed 2023/01/11
		-- Removes properties passed in the selected list, returns a list of items succsusfully removed
		function clearProps arg_node arg_props =
		(

			struct report
			(
				removedProps 	= #()
			)

			newReport 	= report()

			for arg_prop in arg_props do 
			(
				-- Try to remove the property
				result = deleteUserProp arg_node arg_prop

				if result then
				(
					-- if it was removed, add it to the report
					append newReport.removedProps arg_prop
				)
				else()
			)

			-- Returns a list of all the successfully removed properties
			return newReport
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

-- Instantiate the library
userPropLib = userPropLibInit()


----------------------
-- Regression Tests --
----------------------

	-- FN isPropSet
		-- clearListener()
		-- result = userPropLib.isPropSet selection[1] "TestProp2"
		-- print result
		-- result = userPropLib.isPropSet selection[1] "TestProp"
		-- print result

	-- FN setProp
		-- clearListener()
		-- result = userPropLib.setProp selection[1] "TestProp" "TestValue"

	-- FN clearProps
		-- `clearListener()
		-- result = userPropLib.clearProps selection[1] #("TestProp","TestProp3","InvalidProp")
		-- print result

	-- FN clearAll
		-- clearListener()
		-- result = userPropLib.clearAll