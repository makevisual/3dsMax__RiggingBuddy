filein "math3dLib.ms" 		-- used for common math operations 			-- comes in as math3dLib
filein "select3dLib.ms" 	-- used for common selection operations 	-- comes in as select3dLib

function rbLibInit  = (
	
	struct rbLibStruct
	(
		version = "0.0.1",

		function assetNameIsSet arg_list =
		(
			-- Checks all selected objects to see if they have object properties for a stored asset name
			print "assetNameCheck Function"
		),

		function assetNameCheckMatch =
		(
			-- Checks all selected objects to see if they have object properties for a stored asset name
			print "assetNameCheck Function"
		),

		function assetNameSet =
		(
			-- Sets the asset name object property on all selected objects
			print "checkForAssetName Function"
		),

		function assetNameRestore =
		(
			-- Restores the asset name on the selected objects
			print "checkForAssetName Function"
		),

		-- Removes asset related names from the user defined field of the object properties of a node.
		function assetNameClear arg_Node =
		(
			-- setup local properties
			removeList 		= #("AssetName")	-- This list of keys that will be removed form the buffer, can be multiples
			newBuffer 		= stringStream ""	-- An empty string to build the new data
			buffer 			= ( ( getUserPropBuffer arg_Node ) as StringStream )

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

		-- removes all user properties from selcted objects
		function userDefinedOPClearSelection =
		(
			curSel = selection as array 

			for cur in curSel do 
			(
				setUserPropBuffer cur ""
			)
		),

		function selectOrphanObjects = 
		(
			-- Returns all top level objects ( children without parents )
			print "selectOrphanObjects"
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


		function namesChildValidPrefixCheck = 
		(

			-- Verifies all children of the selected object have the same starting name / asset tag.
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

		ender = undefined
	)

	return rbLibStruct()

)

rbLib = rbLibInit()

clearListener()
rbLib.version

--report = rbLib.namesCheckForDuplicates()
--rbLib.selectByAnimhandle report.duplicateNamesIds
--rbLib.hypotenusePoint()
--rbLib.assetNameClear selection[1]
--rbLib.userDefinedOPClearSelection()

rbLib.namesChildValidPrefixCheck()