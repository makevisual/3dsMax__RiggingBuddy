filein "math3dLib.ms" 		-- used for common math operations 			-- comes in as math3dLib
filein "collect3dLib.ms" 	-- used for common collection operations 	-- comes in as collect3dLib
filein "userPropLib.ms" 	-- used for common user property operations -- comes in as userPropLib


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

----------------------
--- Name Functions ---
----------------------

		-- Ready for test 2023/01/10
		-- Checks current selection for objects with duplicate names
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
		function namesValidChildPrefixes arg_node = 
		(

			struct report
			(
				pass 			= true,
				nameTag 		= "",
				failNamesIds 	= #()
			)

			newReport 	= report()

			if arg_node.count == 1 then 
			(
				-- Get and store the name tag for the asset
				masterName = arg_node.name
				masterNameParts = FilterString masterName "_"
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


		-- TODO: Troubleshoot this 
		function namesMakeUnique arg_List =
		(
			-- Function namesMakeUnique arg_List

			struct report
			(
				pass 				= true,
				updateNone   		= #(),
				updateAppend 		= #(),
				updateRebuild 		= #(),
				updateCreate 		= #()
			)

			newReport = report()

			for arg in arg_list do 
			(

				curHandle 	= ( ( getHandleByAnim arg ) as string )
				curName 	= arg.name 
				newName 	= ""
				updateType 	= #none -- #append, #rebuild, #create

				-- Test for an empty name
				if curName == "" then (updateType = #create)

				-- Test for name with no handle in filename
				nameParts 	= ( filterstring curName curHandle )
				if nameParts.count == 1 then ( updateType = #append )

				-- Test for name with hand in filename
				if nameParts.count >= 1 then
				(
					-- If only 1 instance of the handle in the string, no update to the name is needed
					if nameParts.count == 2 then ( updateType = #none )
					-- if there are more than 2 instances of the handle in the string, name should be rebuilt
					if nameParts.count > 2 then ( updateType = #rebuild )
				)

				if updateType == #none then
				(
					append newReport.updateNone ( getAnimByHandle arg )
				)

				if updateType == #append then
				(
					newName = ( curName + "_" curHandle)
					append newReport.updateAppend ( getAnimByHandle arg )
				)

				if updateType == #create then
				(
					newName = ( ( (classof arg ) as string ) + "_" + curHandle )
					append newReport.updateCreate ( getAnimByHandle arg )
				)

				if updateType == #rebuild then
				(

					nameParts 	= ( filterstring curName curHandle )

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

					print newName

					append newReport.updateRebuild ( getAnimByHandle arg )
				)

				-- returns  all of the handles of the objects that were renamed, sorted into categories of what type of rename they recieved.
				return newReport

			)
		),

		function namesRemoveLastSegment args_list =
		(
			-- Function namesRemoveLastSegment body_list
		),

----------------------------------
--- universal user props start ---
----------------------------------

		-- Ready for test 2023/01/09
		-- ToDo : Redesign report to use additional data passed upstream
		-- Removes all instances of a all user properties in an array from the current selection
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
			return newReport()
		),

		-- Ready for test 2023/01/09
		-- ToDo : Redesign report to use additional data passed upstream
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
			return newReport()
		),

		-- Ready for test 2023/01/09
		-- ToDo : Redesign report to use additional data passed upstream
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
				try
				(
					 userPropLib.isPropSet arg arg_userProp
				)
				catch
				(
					newReport.pass = false
					append newReport.failIds ( gethandlebyanim arg )
				)
			)

			-- Returns a report with pass/fail, and a list of all nodes that failed, if any
			return newReport()
		),

--------------------------------
-- specific user props start ---
--------------------------------

	-- Asset Name --

		-- Ready for test 2023/01/10
		-- Returns the parsed value for asset name
		function collectAssetName arg_node =
		(
	
			-- Get from the object
			assetName = arg_node.name

			return assetName 
		),

		-- Ready for test 2023/01/10
		-- Assigns the user property and value
		function setUserPropsAssetNameSelected =
		(

			selArr 	= selection as array 

			for sel in selArr do
			(
				curProp = rbLib.collectAssetName sel
				userPropLib.setProp sel "AssetName" curProp
			)	
		
		),

		function restoreUserPropsAssetNameSelected =
		(
		
		),

		function compareUserPropsAssetNameSelected =
		(
		
		),

	-- Asset Version --

		-- Ready for integration into UI and Data Struct 2023/01/09
		-- Returns the parsed value for asset version
		function collectAssetVersion =
		(
		
			-- Get from the global data object and parse it
			assetVersion 	= 1 -- temporary value
			assetVersionStr = substring ( (assetVersion += 1000) as string ) 2 4 -- turn it into a 3 diget string

			return assetVersionStr
		),

		function setUserPropsAssetVersionSelected =
		(
			curProp = rbLib.collectAssetVersion()
		),

		function restoreUserPropsAssetVersionSelected =
		(
		
			-- Cannot restore publish version

		),

		function compareUserPropsAssetVersionSelected =
		(
			
			curProp = rbLib.collectAssetVersion()
		
		),

	-- Asset Date --

		-- Ready for test 2023/01/09
		-- Returns a timestamp of the current time
		function collectAssetDate =
		(
			curTime = getLocalTime()

			curMin = ( curTime[6] as string )
			if curMin.count == 1 then ( curMin = "0" + curMin )

			parsedTime = ( "published: " + ( curTime[1] as string ) + "-" + ( curTime[2] as string ) + "-" + ( curTime[4] as string ) + "_" + ( curTime[5] as string ) + ":" + curMin )

			-- Returns a timestamp of the current time ie: "published: 2023-1-9_17:36"
			return parsedTime
		),

		function setUserPropsAssetDateSelected =
		(

		),

		function restoreUserPropsAssetDateSelected =
		(
			-- Cannot restore publish date
		),

		function compareUserPropsAssetDateSelected =
		(
			curProp = rbLib.collectAssetDate()
		),


	-- Rig Parent --
		
		-- Ready for test 2023/01/09
		-- Returns the parsed value for the parent object
		function collectRigParent arg_node =
		(
			curParent = arg_node.parent
		
			curParentName 		= curParent.name
			curParentAnimhandle = getHandleByAnim curParent

			curResult = #( curParentName, curParentAnimhandle )

			-- Returns an array of the name of the parent object, and its animhandle ie: #("Teapot006", 503121P)
			return curResult
		),

		function setUserPropsRigParentSelected =
		(
		
			curProp = rbLib.collectRigParent()

		),

		function restoreUserPropsRigParentSelected =
		(
		
		),

		function compareUserPropsRigParentSelected =
		(

			curProp = rbLib.collectRigParent()		

		),
	
	-- Wirecolor --

		-- Ready for test 2023/01/09
		-- Returns the parsed value for the wirecolor
		function collectWirecolor arg_node =
		(
			curColor = ( arg_node.wirecolor as string )

			-- Returns a string of the color ie: "(color 175 175 175)"
			return curColor
		),

		function setUserPropsWirecolorSelected =
		(

			curProp = rbLib.collectWirecolor()

		),

		function restoreUserPropsWirecolorSelected =
		(
		
		),

		function compareUserPropsWirecolorSelected =
		(

			curProp = rbLib.collectWirecolor()

		),

		ender = undefined
	)

	return rbLibStruct()

)

rbLib = rbLibInit()

--clearListener()
rbLib.version



----------------------
-- Regression Tests --
----------------------

	-- FN namesMakeUnique
		clearListener()
		timeStamp()
		rbLib.namesMakeUnique ( selection as array )