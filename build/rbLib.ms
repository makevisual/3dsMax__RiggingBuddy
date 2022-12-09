function rbLibInit  = (
	
	struct rbLibStruct
	(
		version = "0.0.1",

		function assetNameIsSet =
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

		function assetNameClear =
		(


			buffer = (" asdf aasdf
			assssdddd
			asset_file = W:\Projects\BraveHurts\Assets\Characters\TGD_TallGuard\TGD_TallGuard.asset
			AssetName = C_TGD_Hood_Geo

			asset_file_curType =  No Types Found
			asset_file_curVersion =  No Types Found
			" as StringStream )

			newBuffer = stringStream ""

			removeList = #("AssetName", "asset_file_curType")
			clearListener()

			while not eof buffer do
			(
				str = readLine buffer
				curKey = ( filterstring str " =" )[1]
				newStr = str
				
				if curKey != undefined then 
				(
				for curRemove in removeList do 
					(
						if curKey != undefined then 
						(
							if curKey == curRemove then
							(
								print ("===curKey=== " + curKey)
								print ("===curRemove=== " + curRemove)
								print "----------- match "
								newStr = ""

							) else (newStr =str ) -- format "%\n" str to:newb
						)
					)
				)
				format "%\n" newStr to:newBuffer
			)

			print buffer

			print "---------------------------------------------"

			print newBuffer
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
			
			-- print "hypotenuseAlign Function"

			function distance3D arg_a arg_b =
			(
				xD = ( arg_a[1] - arg_b[1] )
				yD = ( arg_a[2] - arg_b[2] )
				zD = ( arg_a[3] - arg_b[3] )
				
				return ( sqrt ( xD*xD + yD*yD + zD*zD ) )
			)

			function bisect3D arg_a arg_b = 
			(
				return ( ( arg_a + arg_b ) / 2 )
			)

			function hypotenuseAlign arg_objs =
			(
				
				pA = arg_objs[1].pos
				pB = arg_objs[2].pos
				pC = arg_objs[3].pos

				AB = distance3D pA pB
				BC = distance3D pB pC
				CA = distance3D pC pA
				
				pD = ( bisect3D pC pA )
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

			curSel 	= ( for i in selection collect i )--( for i in selection collect i.name )
			newReport 	= report()


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
		)

		ender = undefined
	)

	return rbLibStruct()

)

rbLib = rbLibInit()

clearListener()
--print rbLib.version

--report = rbLib.namesCheckForDuplicates()
--rbLib.selectByAnimhandle report.duplicateNamesIds
--rbLib.hypotenusePoint()