filein "math3dLib.ms" 		-- used for common math operations 			-- comes in as math3dLib
filein "select3dLib.ms" 	-- used for common selection operations 	-- comes in as select3dLib
filein "userPropLib.ms" 	-- used for common user property operations -- comes in as userPropLib

function rbLibInit  = (
	
	struct rbLibStruct
	(
		version = "0.0.1",

		function collectOrphanObjects = 
		(
			-- Returns all top level objects ( children without parents )
			print "collectOrphanObjects"
		),

		function skinDeformReset =
		(
			-- Functionally collapses a skin modifier and replaces it, to make sure bind pose deformations are clean and correct
			print "skinDeformReset Function"
		),

		function skinPivotReset =
		(
			-- Sets the pivot of any meshes to the origin, underneath a skin, with its properties set to "always deform off"
			print "skinPivotReset Function"
		),

		function skinToPointCaches =
		(
			-- Converts all skin modifiers to point caches
			print "skinToPointCaches Function"
		),

		function skinCheckOnSelection =
		(
			-- Checks if there is a skin modifier on the current selection
			print"skinCheckOnSelection Function"
		),

		function skinCheckSafeModsBelow = (
			-- Checks if there are any topology changing modifiers below the current skin modifier
			print"skinCheckSafeModsBelow Function"
		),

		function skinParent = 
		(
			-- Adds a skin modifier to the object with 100% weighting to the selected object
			print"skinParent Function"
		),

		function skinParentConvert = 
		(
			-- Adds a skin modifier to the object with 100% weighting to the objects parent
			print"skinParentConvert Function"
		),

		function pointCacheAddAboveSkin =
		(
			-- Adds a point cache modifier above the skin
			print"pointCacheAddAboveSkin Function"
		),

		function pointCacheTestSelection =
		(
			-- Checks if there is a point cache modifier in the current objects stack
			print"pointCacheTestSelection Function"
		),

		function driversBreakToWorld =
		(
			-- reparents all selected objects to the global
			print "driversBreakToWorld Function"
		),

		-- Completed 2023/01/09
		-- Creates a point that is planar with a triangle aligned to 3 selected objects, and is offset from the second object selected
		function hypotenusePoint =
		(
			-- This is usefull for creating polvector nodes that will not shift an IK System when chosen.
			-- The second object selected is the " knee " the new point will be created off of the hypotenuse of that point

			function hypotenuseAlign arg_objs =
			(
				
				pA = arg_objs[1].pos
				pB = arg_objs[2].pos
				pC = arg_objs[3].pos

				AB = math3dLib.distance3D pA pB
				BC = math3dLib.distance3D pB pC
				CA = math3dLib.distance3D pC pA
				
				pD = ( math3dLib.bisect3D pC pA )
				DA = ( pB - pD )
				newPos = ( ( DA * 2 ) + pD )

			 	curPoint = point position:newPos size:2 wirecolor:green
			)

			selArr = selection as array 

			if selArr.count == 3 then
			(
				hypotenuseAlign selArr
			)
			else( messagebox" You must select exactly 3 objects " )
		),

		-- Completed 2023/01/09
		-- Checks current selection for objects with duplicate names
		function namesCheckForDuplicates =
		(
			-- print "namesCheckForDuplicates Function"

			struct report
			(
				pass 				= true,
				duplicateNamesIds 	= #()
			)

			newReport 	= report()
			curSel 	= ( for i in selection collect i )--( for i in selection collect i.name )


			for i in 1 to curSel.count do 
			(
				curObj = curSel[i]
				curName = curSel[i].name
			
				-- Compare current name to all the names
				for j in 1 to curSel.count do 
				(
					curTest = curSel[j].name
					-- print ( curName + " ? " + curTest )

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

			return newReport 
		),

		-- Completed 2023/01/09
		-- Verifies all children of the selected object have the same starting name / asset tag.
		function namesChildValidPrefixCheck = 
		(

			print "namesChildValidPrefixCheck Function"

			struct report
			(
				pass 			= true,
				nameTag 		= "",
				failNamesIds 	= #()
			)

			newReport 	= report()

			if selection.count == 1 then 
			(
				-- Get and store the name tag for the asset
				masterName = selection[1].name
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
				objArr = select3dLib.collectAllChildren selection[1] includeParent:true

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

			return newReport 
		),

		-- Completed 2023/01/09
		-- clears all the user properties off of selected objects
		function clearAllUserPropsSelected =
		(
			print "clearUserPropsSelected Function"

			selArr = selection as array 

			for sel in selArr do ( userPropLib.clearAll sel )
		),


--- universal user props start

		-- Ready for test 2023/01/09
		-- Removes all instances of a all user properties in an array from the current selection
		function clearUserPropsInSelection arg_userProps = -- arg_userProps is an Array
		(
			selArr = selection as array 

			for sel in selArr do ( userPropLib.clearProps sel arg_userProps )
		),

		-- Ready for test 2023/01/09
		-- Removes all user properties from selcted objects
		function userDefinedPropClearSelection =
		(
			selArr = selection as array 

			for sel in selArr do ( userPropLib.clearAll sel	)
		),

		-- Ready for test 2023/01/09
		-- Checks all selected objects to see if they have object properties for passed argument
		function checkForUserPropInSelection arg_userProp =
		(
			selArr = selection as array 

			for sel in selArr do ( userPropLib.isPropSet sel arg_userProp )
		),


-- specific user props start 


	-- Asset Name

		-- Ready for integration into UI and Data Struct 2023/01/09
		-- Returns the parsed value for asset name
		function collectAssetName =
		(
	
			-- Get from the global data object and parse it
			assetName = "temp"

			return assetName 

		),

		function setUserPropsAssetNameSelected =
		(
		
		),

		function restoreUserPropsAssetNameSelected =
		(
		
		),

		function compareUserPropsAssetNameSelected =
		(
		
		),

	-- Asset Version

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

	-- Asset Date

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
		
			curProp = rbLib.collectAssetDate()

		),

		function restoreUserPropsAssetDateSelected =
		(
			-- Cannot restore publish date
		),

		function compareUserPropsAssetDateSelected =
		(

			curProp = rbLib.collectAssetDate()

		),


	-- Rig Parent
		
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
	
	-- Wirecolor

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


-- test skin pose set
-- store objects parent, to restore later
-- test controllers for any scaling 
-- Automatically create unique names off of selection


		ender = undefined
	)

	return rbLibStruct()

)

rbLib = rbLibInit()

clearListener()
rbLib.version


-- rbLib.clearAllUserPropsSelected()

--report = rbLib.namesCheckForDuplicates()
--select3dLib.selectByAnimhandle report.duplicateNamesIds

--rbLib.hypotenusePoint()
--rbLib.assetNameClear selection[1]
--rbLib.userDefinedPropClearSelection()

--report = rbLib.namesChildValidPrefixCheck()
--select3dLib.selectByAnimhandle report.failNamesIds