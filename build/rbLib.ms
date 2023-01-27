filein "math3dLib.ms" 		-- used for common math operations 			-- comes in as math3dLib
filein "collect3dLib.ms" 	-- used for common collection operations 	-- comes in as collect3dLib
filein "userPropLib.ms" 	-- used for common user property operations -- comes in as userPropLib
filein "strLib.ms" 			-- used for common string operations 		-- comes in as strLib


-- ToDo: test skin pose set


function rbLibInit  = (
	
	struct rbLibStruct
	(
		version = "0.0.1",

----------------------------
--- PointCache Functions ---
----------------------------

		-- Adds a point cache modifier above the skin
		function pointCacheAddAboveSkin =
		(
			print"pointCacheAddAboveSkin Function"
		),

		-- Checks if there is a point cache modifier in the current objects stack
		function pointCacheTestSelection =
		(
			print"pointCacheTestSelection Function"
		),

----------------------
--- Skin Functions ---
----------------------

		-- Converts all skin modifiers to point caches
		function skinToPointCaches =
		(
			print "skinToPointCaches Function"
		),

		-- Functionally collapses a skin modifier and replaces it, to make sure bind pose deformations are clean and correct
		function skinDeformReset arg_list =
		(
			print "skinDeformReset Function"
		),
		
		-- Checks if there is a skin modifier on the current selection
		function skinCheck arg_list =
		(
			print"skinCheckOnSelection Function"
		),

		-- Checks if there are any topology changing modifiers below the current skin modifier
		function skinCheckSafeMods arg_list =
		(
			print"skinCheckSafeModsBelow Function"
		),

		-- Adds a skin modifier to the object with 100% weighting to the selected object
		function skinParent arg_list = 
		(
			print"skinParent Function"
		),

		-- Adds a skin modifier to the object with 100% weighting to the objects parent
		function skinParentConvert arg_list = 
		(
			print"skinParentConvert Function"
		),

		-- Ready for test 2023/01/10
		-- Sets the pivot of any meshes to the origin, underneath a skin, with its properties set to "always deform off"
		function skinPivotReset arg_list =
		(

			struct report
			(
				pass 		= true,
				editedIds 	= #()
			)

			newReport 	= report()

			for arg in arg_list do
			(
				try
				(

					if arg.pivot != [0,0,0] then 
					(
						mods = arg.modifiers
						test = false
						
						for j in 1 to mods.count do
						(	
							if (classof mods[j]) == skin 
							then
							(
								mods[j].enabled = false 
								modPanel.setCurrentObject mods[j]
								
								mods[j].always_deform = false
								arg.pivot = [0,0,0]
								mods[j].always_deform = true
								
								test = true
							)
						)
						
						if test == false then arg.pivot = [0,0,0]

						append newReport.editedIds ( getHandleByAnim arg )
					)

					else()
				)
				catch ( newReport.pass = false )
			)

			-- Returns a report with pass/fail, and a list of all nodes that were edited, if any
			return newReport
		),

		function skinwrapStealWeights arg_Node arg_List =
		(

		),

--------------------------------------
--- Rigging / Transforms Functions ---
--------------------------------------

		-- Ready for test 2023/01/10
		-- returns the position planar to the 3 passed objects, that is aligned to the hypotenuse of the second object. ( usefull for placing pole vectors )
		function hypotenusePoint arg_list =
		(
			-- This is usefull for creating polvector nodes that will not shift an IK System when chosen.
			-- The second object selected is the " knee " the new point will be created off of the hypotenuse of that point

			struct report
			(
				pass 		= true,
				curObjects 	= arg_list,
				hypotPoint 	= undefined
			)

			newReport 				= report()
			newReport.curObjects 	= arg_list


			if arg_list.count == 3 then
			(
				hpotPos 				= ( math3dLib.hypotenuseAlign arg_list )
				curPoint 				= point position:hpotPos size:2 wirecolor:green
				newReport.hypotPoint 	= curPoint
			)
			else
			(
				newReport.pass = false
			)

			-- Returns a report with pass/fail, the newly created point, and the originally passed objects
			return newReport
		),

		-- Ready for test 2023/01/10
		-- Checks for objects not at a uniform 100% scale
		function checkForScaledTransforms arg_list =
		(

			struct report
			(
				pass 		= true,
				failIds 	= #()
			)

			newReport 	= report()

			for arg in arg_list do
			(
				if arg.scale != [1,1,1] then 
				(
					newReport.pass = false
					append newReport.failIds ( gethandlebyanim arg )
				)
			)

			-- Returns a report with pass/fail, and a list of all nodes that failed, if any
			return newReport()
		),

		function meshScaleCorrect arg_List = (
			-- Function meshScaleCorrect bod_List
		),

		-- reparents all selected objects to the global
		function driversBreakToWorld =
		(
			print "driversBreakToWorld Function"
		),

--- Name Functions ---

		-- Completed 2023/01/18
		-- Checks current selection for objects with duplicate names, returs a true/false if passed, and a list of all objects
		-- animhandles with duplicate names.
		function namesCheckForDuplicates arg_list =
		(
			struct report
			(
				pass 				= true,
				duplicateNamesIds 	= #()
			)

			newReport 	= report()
			curSel 	= ( for i in arg_list collect i )--( for i in selection collect i.name )

			for i in 1 to curSel.count do 
			(
				curObj = curSel[i]
				curName = curSel[i].name
			
				-- Compare current name to all the names
				for j in 1 to curSel.count do 
				(
					curTest = curSel[j].name

					if curName == curTest then
					(
						-- Ensures the current object is not being tested against itself
						if i != j then 
						(
							-- Add its animhandle to the duplicate list 
							curHandle = (getHandleByAnim curObj )
							append newReport.duplicateNamesIds curHandle
						)
					)
					else()
				)
			)

			-- Remove duplicates from the animhandle list
			newReport.duplicateNamesIds = makeUniqueArray newReport.duplicateNamesIds
			if ( newReport.duplicateNamesIds.count >= 1 ) then(newReport.pass = false)else()

			-- Returns a report with pass/fail and a list of all nodes that failed, if any
			return newReport 
		),

		-- Ready for test 2023/01/10
		-- Verifies all children of the selected object have the same starting name / asset tag.
		function namesValidChildPrefixes arg_list = 
		(

			struct report
			(
				pass 			= true,
				nameTag 		= "",
				failNamesIds 	= #()
			)

			newReport 	= report()


			-- TODO: Rework with the collect3dLib.collectProtoplasts and collect3dLib.collectAllChildren functions to operate on
			-- Seperate heirarchies at the same time.

			if arg_node.count == 1 then 
			(
				-- Get and store the name tag for the asset
				masterName = arg_node.name
				masterNameParts = FilterString masterName "_"
				-- Builds a name tag, based off of the object, should look something like "C_TGD_"
				newReport.nameTag = (masterNameParts[1] + "_" + masterNameParts[2] + "_" )
			)
			else
			(
				-- fail the report
				messagebox ( "Select exactly 1 object")
				newReport.pass = false
			)

			if newReport.pass == true then 
			(
				objArr = collect3dLib.collectAllChildren arg_node includeParent:true

				for curObj in objArr do 
				(
					curSubString = ( substring curObj.name 1 newReport.nameTag.count )

					if curSubString != newReport.nameTag then 
					(
						curHandle = (getHandleByAnim curObj )
						append newReport.failNamesIds curHandle

						newReport.pass = false
					)
					else()
				)
			)

			newReport.failNamesIds = makeUniqueArray newReport.failNamesIds

			-- Returns a report with pass/fail, the desired name and a list of all nodes that failed, if any
			return newReport 
		),

		-- Completed 2023/01/18
		-- uses the data collected in the namesMakeUniqueCollect function, to apply the new name
		function namesMakeUnique arg_collection =
		(
			hanList = #()

			-- collect all relevant objects into one list
			join hanList arg_collection.updateAppend
			join hanList arg_collection.updateRebuild
			join hanList arg_collection.updateCreate

			-- Do the rename
			for han in hanList do 
			(
				curObj = getAnimByHandle (han.handle )
				curObj.name = han.newName
			)
		),

		-- Completed 2023/01/18
		-- Operates on a selection of objects. Looks for any instance of their animhandle node id in their name
		-- depending on multiple cases, this function will flag, and prepare a unique name to that object
		-- then it will return a collection of all the nodes, with a prepared name, and animhandle.
		-- this is intended to be run and passed to the namesMakeUnique function, which will actually
		-- process the items.
		function namesMakeUniqueCollect arg_list =
		(
			struct handleAndName
			(
				handle 	= undefined,
				newName = undefined
			)

			struct report
			(
				pass 				= true,
				updateNone   		= #(),
				updateAppend 		= #(),
				updateRebuild 		= #(),
				updateCreate 		= #()
			)

			newReport = report()

			-- Go through each of the items, and flag them for the appropriate type of processing
			for arg in arg_list do 
			(

				curHandle 	= ( ( getHandleByAnim arg ) as string )
				curName 	= arg.name 
				newName 	= ""
				updateType 	= #undefined -- #append, #rebuild, #create
				
				-- Collect the parts of the name, without the animhandle in it
				nameParts 	= ( strLib.splitByToken curName curHandle)
				
				-- print ( "-Name Parts-")
				-- print nameParts

				-- Test for an empty name
				-- If no instances of the handle in the string, flag for appending
				if nameParts.count 	== 1 then ( updateType = #rebuild )
				-- If only 1 instance of the handle in the string, no update to the name is needed
				if nameParts.count 	== 2 then ( updateType = #none )
				-- if there are more than 2 instances of the handle in the string, name should be rebuilt
				if nameParts.count 	> 2 then ( updateType = #rebuild )
				-- If the name is empty, then flag for creation
				if curName 			== "" then (updateType = #create)

				if updateType == #none then
				(
					-- define the object and name, and then append it to the appropriate group
					han 		= handleAndName()
					han.handle  = ( gethandlebyanim arg )
					han.newName = arg.name

					append newReport.updateNone han
				)

				if updateType == #create then
				(

					-- define the object and name, and then append it to the appropriate group
					han 		= handleAndName()
					han.handle  = ( gethandlebyanim arg )
					han.newName = ( ( (classof arg ) as string ) + "_" + curHandle )

					append newReport.updateCreate han
				)

				if updateType == #rebuild then
				(

					--nameParts 	= ( filterstring curName curHandle splitEmptyTokens:false )

					for part in nameParts do 
					(
						lastCharacter = ( substring part part.count ( part.count - 1 ) )
						
						if lastCharacter == "_" then 
						(
							part = ( substring part 1 ( part.count - 1 ) )
						)
						
						newName += (  part + "_" )
					)

					newName += ( curHandle )

					-- define the object and name, and then append it to the appropriate group
					han 		= handleAndName()
					han.handle  = ( gethandlebyanim arg )
					han.newName = newName

					append newReport.updateRebuild han
				)
			)

			-- returns  all of the handles of the objects that were renamed, sorted into categories of what type of rename they recieved.
			return newReport
		),

--- universal user props start ---

		-- Completed 2023/01/26
		-- Removes all instances of a all user properties ( in an array ) in an array from the current selection
		function userPropClear arg_list arg_userProps =
		(
			struct report
			(
				pass 		= true,
				failIds 	= #()
			)

			newReport 	= report()

			for arg in arg_list do
			(
				try
				(
					userPropLib.clearProps arg arg_userProps
				)
				catch
				(
					newReport.pass = false
					append newReport.failIds ( gethandlebyanim arg )
				)
			)

			-- Returns a report with pass/fail, and a list of all nodes that failed, if any
			return newReport
		),

		-- Completed 2023/01/26
		-- Removes all user properties from selcted objects
		function userPropClearAll arg_list =
		(
			struct report
			(
				pass 		= true,
				failIds 	= #()
			)

			newReport 	= report()

			for arg in arg_list do
			(
				try
				(
					userPropLib.clearAll arg
				)
				catch
				(
					newReport.pass = false
					append newReport.failIds ( gethandlebyanim arg )
				)
			)

			-- Returns a report with pass/fail, and a list of all nodes that failed, if any
			return newReport
		),

		-- Completed 2023/01/26
		-- Checks all selected objects to see if they have object properties for passed argument
		function userPropCheck arg_list arg_userProp =
		(
			struct report
			(
				pass 		= true,
				failIds 	= #()
			)

			newReport 	= report()

			for arg in arg_list do
			(
				if ( ( userPropLib.isPropSet arg arg_userProp ) == false ) then
				(
					newReport.pass = false	
					append newReport.failIds ( gethandlebyanim arg )	
				)
			)

			-- Returns a report with pass/fail, and a list of all nodes that failed, if any
			return newReport
		),

-- specific user props start ---

	-- Asset Name --

		-- Completed 2023/01/25
		-- Returns the parsed value for asset name
		function collectNodeName arg_node =
		(
				-- Get from the object
			assetName = arg_node.name

			return assetName 
		),

		-- Completed 2023/01/26
		-- Assigns the user property and value
		function setUserPropsNodeName arg_node = 
		( 
			curProp = rbLib.collectNodeName arg_node
			userPropLib.setProp arg_node "NodeName" curProp
		),

		-- Completed 2023/01/26
		-- Gets the stored value for the property passed
		function getUserPropsNodeName arg_node =
		(
			curProp = getUserProp arg_node "NodeName"

			return curProp
		),

		-- Completed 2023/01/26
		-- Restores the name to the object if one is stroed.
		function restoreUserPropsNodeName arg_node = 
		(
			report = rbLib.compareUserPropsNodeName arg_node

			-- Only change the name if a valid one is stored, and it does not match the current name
			if ( report.pass == false ) then 
			(
				arg_node.name = rbLib.getUserPropsNodeName arg_node
			)
		),

		-- Completed 2023/01/26
		-- Compares and returns the values for the current and stored property
		function compareUserPropsNodeName arg_node = 
		(
			struct report
			(
				pass 		= undefined,
				currentVal 	= undefined,
				storedVal 	= undefined
			)

			newReport = report()

			newReport.currentVal = rbLib.collectNodeName arg_node
			newReport.storedVal = rbLib.getUserPropsNodeName arg_node

			if newReport.currentVal == newReport.storedVal then
			(
				newReport.pass = true 
			)
			else 
			(
				newReport.pass = false
			)

			return newReport
		),

	-- Asset Date --

		-- Completed 2023/01/25
		-- Returns a timestamp of the current time, as an integer array, and as a parsed string
		function collectNodeDate =
		(

			struct report
			(
				localTime 	= undefined,
				parsedTime 	= undefined
			)

			newReport = report()

			curTime = getLocalTime()

			-- padd mins if needed
			curMin = ( curTime[6] as string )
			if curMin.count == 1 then ( curMin = "0" + curMin )

			parsedTime = ( "published: " + ( curTime[1] as string ) + "-" + ( curTime[2] as string ) + "-" + ( curTime[4] as string ) + "_" + ( curTime[5] as string ) + ":" + curMin )

			-- Stores a timestamp as an array of integers for easy comparison later
			newReport.localTime 	= curTime
			-- Stores a timestamp of the current time ie: "published: 2023-1-9_17:36"
			newReport.parsedTime 	= parsedTime

			return newReport
		),

		-- Completed 2023/01/25
		-- Returns a timestamp of the current time, as an integer array, and as a parsed string
		function setUserPropsNodeDate arg_node = 
		(
			result = rbLib.collectNodeDate()

			userPropLib.setProp arg_node "NodePublishDate" result.localTime 		
			userPropLib.setProp arg_node "NodePublishDateParsed" result.parsedTime
		),

	-- Rig Parent --
		
		-- Completed 2023/01/25
		-- Returns if the object has a parent, and that parent name and animhandle
		function collectRigParent arg_node =
		(

			struct report
			(
				orphan 				= undefined,
				parentName 			= undefined,
				parentAnimhandle 	= undefined
			)

			newReport 			= report()


			curParent = arg_node.parent

			if curParent != undefined
			then 
			(
				newReport.orphan 			= false
				newReport.parentName 		= arg_node.parent.name
				newReport.parentAnimhandle 	= ( getHandleByAnim arg_node.parent )
			)

			if curParent == undefined
			then 
			(
				newReport.orphan = true
			)

			return newReport
		),

		-- Completed 2023/01/25
		-- Gets the stored parent name and animhandle on the node
		function getUserPropsRigParent arg_node =
		(
			struct report
			(
				orphan 				= undefined,
				parentName 			= undefined,
				parentAnimhandle 	= undefined
			)

			newReport 			= report()
			
			newReport.parentName 		= getUserProp arg_node "NodeParentName"
			newReport.parentAnimhandle 	= getUserProp arg_node "NodeParentHandle"
			
			if newReport.parentName == "undefined"
			then 
			(
				newReport.orphan = true
			)
			
			if newReport.parentName != "undefined"
			then 
			(
				newReport.orphan = false
			)

			return newReport
		),

		-- Completed 2023/01/25
		-- Stores the current parent name and animhandle on the node
		function setUserPropsRigParent arg_node =
		(
		
			result = rbLib.collectRigParent arg_node 

			userPropLib.setProp arg_node "NodeParentName" 	result.parentName 		
			userPropLib.setProp arg_node "NodeParentHandle" result.parentAnimhandle
		),

		-- Completed 2023/01/25
		-- First try to find node by animhandle, then by name, and parent the arg to it
		-- Throws warnings when unable to finde matching animhandle node, and 0 or 2+ objects with matching name.
		function restoreUserPropsRigParent arg_node =
		(
			-- Is there data strored
			if ( userPropLib.isPropSet arg_node "NodeParentName" ) then 
			(
				-- retrieve all the data
				parentInfo = rbLib.getUserPropsRigParent arg_node

				-- Try Case for animhandle match
				try
				(
					curNode = ( getanimbyhandle parentInfo.parentAnimhandle )

					-- compare that node to the stored name
					if ( curNode.name != parentInfo.parentName ) then 
					(
						-- Throw a warning if animhandle retrieved name and stored name do not match
						print (" Warning: " + arg_node.name + " new parent name does not match stored parent name.")
					)
					-- parent away
					arg_node.parent = curNode
				)
				-- Case for if no animhandle match
				catch
				(
					parentCantidates = collect3dLib.collectNodeByName parentInfo.parentName

					-- print "parentCantidates"
					-- print parentCantidates

					if parentCantidates.count == 1 then 
					(
						-- parent away
						arg_node.parent = curNode
					)
					if parentCantidates.count == 0 then 
					(
						print (" Error: " + arg_node.name + " - Unable to find any nodes that match stored parent data")
					)
					if parentCantidates.count >= 2 then 
					(
						print (" Error: " + arg_node.name + " - No matching node AnimHandle, and multiple name matches for parent")
					)
				)
			)
		),

		-- Completed 2023/01/25
		-- Compares and returns the values for the current and stored property
		function compareUserPropsRigParent arg_node =
		(
			struct report
			(
				pass 		= undefined,
				currentVal 	= undefined,
				storedVal 	= undefined
			)

			newReport 	= report()

			newReport.currentVal	= rbLib.collectRigParent arg_node
			newReport.storedVal 	= rbLib.getUserPropsRigParent arg_node

			if newReport.currentVal.parentName == newReport.storedVal.parentName then
			(
				newReport.pass = true 
			)
			else 
			(
				newReport.pass = false
			)

			return newReport
		),

	-- Wirecolor --

		-- Completed 2023/01/25
		-- Returns the parsed value for the wirecolor
		function collectWirecolor arg_node =
		(
			curColor = ( arg_node.wirecolor as string )
			return curColor
		),

		-- Completed 2023/01/25
		-- Stores the current wirecolor on the node
		function setUserPropsWirecolor arg_node =
		(
			curProp = rbLib.collectWirecolor arg_node
			userPropLib.setProp arg_node "NodeWirecolor" curProp
		),

		-- Completed 2023/01/25
		-- Retrieves the current wirecolor on the node
		function getUserPropsWirecolor arg_node =
		(
			curColor = getUserProp arg_node "NodeWirecolor"
			return ( curColor )
		),

		-- Completed 2023/01/25
		-- Restores the current wirecolor on the node
		function restoreUserPropsWirecolor arg_node =
		(
			if ( userPropLib.isPropSet arg_node "NodeWirecolor" ) then 
			(
				curColor = rbLib.getUserPropsWirecolor arg_node 
				arg_node.wirecolor = ( execute curColor )
			)
			else
			(
				print ( " 'NodeWirecolor' property not set on: " + arg_node.name )
			)
		),

		-- Completed 2023/01/25
		-- Compares and returns the values for the current and stored property
		function compareUserPropsWirecolor arg_Node =
		(
			struct report
			(
				pass 		= undefined,
				currentVal 	= undefined,
				storedVal 	= undefined
			)

			newReport 	= report()

			newReport.currentVal	= rbLib.collectWirecolor arg_node
			newReport.storedVal 	= rbLib.getUserPropsWirecolor arg_node

			if newReport.currentVal == newReport.storedVal then
			(
				newReport.pass = true 
			)
			else 
			(
				newReport.pass = false
			)

			return newReport
		),

		ender = undefined
	)

	return rbLibStruct()

)

rbLib = rbLibInit()
rbLib.version



----------------------
-- Regression Tests --
----------------------

	--- Name Functions ---

		-- FN namesCheckForDuplicates
			-- clearListener()
			-- timeStamp()
			-- selArr = selection as array 
			-- print ( rbLib.namesCheckForDuplicates selArr )

		-- FN namesMakeUniqueCollect
		-- FN namesMakeUnique
			-- clearListener()
			-- timeStamp()
			-- result = ( rbLib.namesMakeUniqueCollect ( selection as array ) )
			-- rbLib.namesMakeUnique result
	
	-- universal user props start ---
		-- FN userPropClear
			-- clearListener()
			-- timeStamp()
			-- selArr = selection as array 
			-- for sel in selArr do ( print ( rbLib.userPropClear sel #("NodeName") ) ) 

		-- FN userPropCheck
			-- clearListener()
			-- timeStamp()
			-- selArr = selection as array 
			-- for sel in selArr do ( print ( rbLib.userPropCheck sel "NodeName" ) ) 
			-- for sel in selArr do ( print ( rbLib.userPropCheck sel "NodeName123" ) )  -- intentionalFail

		-- FN userPropClearAll
			-- clearListener()
			-- timeStamp()
			-- selArr = selection as array 
			-- for sel in selArr do ( print ( rbLib.userPropClearAll sel ) ) 

	-- specific user props start ---	
		-- Asset Name --	
			-- FN collectNodeName
			-- FN setUserPropsNodeName
				-- clearListener()
				-- timeStamp()
				-- selArr = selection as array 
				-- for sel in selArr do ( print ( rbLib.setUserPropsNodeName sel ) ) 
	
			-- FN getUserPropsNodeName
			-- FN compareUserPropsNodeName
				-- clearListener()
				-- timeStamp()
				-- selArr = selection as array 
				-- for sel in selArr do ( print ( rbLib.compareUserPropsNodeName sel ) ) 
	
			-- FN compareUserPropsNodeName
				-- clearListener()
				-- timeStamp()
				-- selArr = selection as array 
				-- for sel in selArr do ( print ( rbLib.restoreUserPropsNodeName sel ) ) 
	
		-- Asset Date --
			-- FN collectNodeDate
				-- clearListener()
				-- timeStamp()
				-- rbLib.collectNodeDate()
	
			-- FN setUserPropsNodeDate
				-- clearListener()
				-- timeStamp()
				-- for sel in selArr do ( print ( rbLib.setUserPropsNodeDate sel ) ) 
	
		-- Rig Parent --
	
			-- FN collectRigParent
			-- FN setUserPropsRigParent	
				-- clearListener()
				-- timeStamp()
				-- selArr = selection as array 
				-- print ( "-- setUserPropsRigParent -- ")
				-- for sel in selArr do ( print ( rbLib.setUserPropsRigParent sel ) ) 
	
			-- FN getUserPropsRigParent
				-- clearListener()
				-- timeStamp()
				-- selArr = selection as array 
				-- print ( "-- getUserPropsRigParent -- ")
				-- for sel in selArr do ( print ( rbLib.getUserPropsRigParent sel ) ) 
	
			-- FN getUserPropsRigParent
				-- clearListener()
				-- timeStamp()
				-- selArr = selection as array 
				-- print ( "-- restoreUserPropsRigParent -- ")
				-- for sel in selArr do ( rbLib.restoreUserPropsRigParent sel )
	
			-- FN compareUserPropsRigParent
				-- clearListener()
				-- timeStamp()
				-- selArr = selection as array 
				-- print ( "-- compareUserPropsRigParent -- ")
				-- for sel in selArr do ( print ( rbLib.compareUserPropsRigParent sel ) )
	
		-- Wirecolor --
	
			-- FN collectWirecolor
			-- FN setUserPropsWirecolor	
				-- clearListener()
				-- timeStamp()
				-- selArr = selection as array 
				-- print ( "-- collectWirecolor -- ")
				-- for sel in selArr do ( print ( rbLib.collectWirecolor  sel ) ) 
				-- print ( "-- collectWirecolor -- ")
				-- for sel in selArr do ( rbLib.setUserPropsWirecolor sel ) 
		
			-- FN restoreUserPropsWirecolor
				-- clearListener()
				-- timeStamp()
				-- selArr = selection as array 
				-- print ( "-- restoreUserPropsWirecolor -- ")
				-- for sel in selArr do ( rbLib.restoreUserPropsWirecolor sel )
		
			-- FN compareUserPropsWirecolor
				-- clearListener()
				-- timeStamp()
				-- for sel in selArr do ( print ( rbLib.compareUserPropsWirecolor sel ))
	