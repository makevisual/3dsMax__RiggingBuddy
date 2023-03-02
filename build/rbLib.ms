filein "math3dLib.ms" 		-- used for common math operations 			-- comes in as math3dLib
filein "collect3dLib.ms" 	-- used for common collection operations 	-- comes in as collect3dLib
filein "userPropLib.ms" 	-- used for common user property operations -- comes in as userPropLib
filein "strLib.ms" 			-- used for common string operations 		-- comes in as strLib


function rbLibInit  = (
	
	struct rbLibStruct
	(
		version = "0.0.1",

-----------------------------
--- Boilerplate Functions ---
-----------------------------
		-- Returns the version number as a string
		function verNumStr =
		(
			curVerNumStr = ( ( ( rigBuddy.version[1] as integer ) as string ) + "." + ( ( rigBuddy.version[2] as integer ) as string ) + "." + ( ( rigBuddy.version[3] as integer ) as string ) )
			return curVerNumStr
		),

----------------------------
--- PointCache Functions ---
----------------------------

		-- Adds a point cache modifier above the skin
		function pointCacheAddAboveSkin arg_list arg_mode = -- " Mode: above / replace "
		(
			for node in arg_list do 
			(
				for i in 1 to node.modifiers.count do
				(
					curTest = (classof node.modifiers[i])

					if curTest == Skin then
					(
						-- Add a point cache
						newCache = pointCache()
						addmodifier node newCache before:(i-1) -- Apply to the right place in the stack

						if arg_mode == "replace" then 
						(
							deleteModifier node (i+1)
						)
					)
				)
			)
		),

		-- Checks if there is a point cache modifier in the current objects stack
		function pointCacheTestSelection arg_list =
		(
			struct report 
			(
				passList = #(),
				failList = #()
			)

			newReport = report()

			-- reduce selection to geometry only
			geoOnly = collect3dLib.collectByClass arg_list GeometryClass

			for node in geoOnly do 
			(
				-- set a flag for if any point cache modifiers are found
				fail = true 

				for i in 1 to node.modifiers.count do
				(
					curTest = ( classof node.modifiers[i] )

					if curTest == Point_Cache then
					(
						-- if a point cache modifier was found, add the object to the pass list
						append newReport.passList ( getHandleByAnim node )
						fail = false
					)
				)

				-- if no point cache modifier was found, then add it to the fail list
				if fail then (append newReport.failList ( getHandleByAnim node ))
			)

			return newReport
		),

		-- Converts all skin modifiers to point caches - useful for making the render version of an asset.
		function skinToPointCaches =
		(
			print "skinToPointCaches Function"
		),

------------------------
--- Baking Functions ---
------------------------

		-- Bake and save
		function bakeAndSave args =
		(

		),
		
		-- Bake and save, but for bones.
		function bakeAndSaveSkeleton args =
		(

		),

----------------------
--- Skin Functions ---
----------------------

		-- This is the most fragile and hokey thing I have ever made -Aaron Dabelow
		-- Functionally collapses a skin modifier and replaces it, to make sure bind pose deformations are clean and match the unmodified skin pose of the rig
		function skinDeformReset arg_list =
		(
			-- When turning off 3dsmax in windows, do it in a try block
			try(

				--------- Disable the 3dsMax from updating in windows
				WM_SETREDRAW 	= 11
				MAX_HWND 		= windows.getMaxHWND()
				windows.sendmessage MAX_HWND WM_SETREDRAW 0 0

				--------- Creates some locations and datas for use, and store the selection
				reports = #()
				tempDir = (getdir #temp)
				tempSel = ( selection as array )
				curFloat = 0.000

				-------- Creates a callback that will call the getDialogHandle function when triggered
				function dialog_ClickOK =
				(
					dialogHandle = dialogMonitorOps.getWindowHandle()
					uiAccessor.pressButtonByName dialogHandle "OK"
				)

				-- Register the callbacks
				dialogMonitorOps.interactive = false
				dialogMonitorOps.unregisterNotification id:#test
				dialogMonitorOps.registerNotification dialog_ClickOK id:#test
				dialogMonitorOps.enabled = true

				-- Collect only geometryclass objects
				meshes = collect3dLib.collectByClass arg_list GeometryClass inclusive:true
				-- Remove boneGeometry from the list
				meshes = collect3dLib.collectByClass meshes BoneGeometry inclusive:false

				--------- Loop through each of the passed objects
				for node in meshes do 
				(
					try( rigBuddy.uiMain.labelStatus.text = ( "Working on: " + ( node.name as string ) ) )catch()

					-- Report template
					struct subReport
					(
						pass = false,
						animhandle = undefined,
						skinIndex = undefined
					)
					
					newSubReport = subReport()
					curFloat += 1.000 -- increment the progressbar float val

					---- Find the skin modifier index
					-- Look through each of the modifiers
					for i in 1 to ( node.modifiers.count) do
					(	
						if newSubReport.pass == false then
						(
							curMod = node.modifiers[i]

							if ( (classof curMod) == Skin )
							then 
							(
								newSubReport.pass = true
								newSubReport.skinIndex = i
								newSubReport.animhandle = (getHandleByAnim node)
							)
						)
					)

					---- Add the subreport to the list of all reports
					append reports newSubReport

					-- If a skin was found, then go ahead with the reset
					if newSubReport.pass then 
					(
						---- Duplicate the skin, paste it above
						oldSkin = node.modifiers[newSubReport.skinIndex]
						newSkin = ( copy oldSkin )

						---- Save the weights of the old skin
						modPanel.setCurrentObject oldSkin
						subobjectLevel = 1
						oldSkin.filter_vertices = on
						max select all
						skinOps.bakeSelectedVerts node.modifiers[#Skin]
						skinOps.SaveEnvelope oldSkin ( tempDir + node.name +".env" )

						-- Add a duplicate of the modifier
						addModifier node newSkin before:(newSubReport.skinIndex - 1 )

						---- Toggle the deformations on the new skin
						newSkin.always_deform = false
						newSkin.always_deform = true

						---- Collapse stack from the point of the old skin
						maxOps.CollapseNodeTo node ( newSubReport.skinIndex + 1 ) true

						---- Toggle always deform to reset bind pose
						modPanel.setCurrentObject newSkin
						skinOps.LoadEnvelope newSkin (tempDir + node.name +".env")
					)

					-- Try to communicate with the UI, if it exists
					try(rigBuddy.uiMain.progBar1.value = ( ( curFloat / meshes.count ) * 100 ) )catch()
				)

				------ Reset the selection
				select tempSel

				------ Disables the dialogops after it is done, removes the temporary files
				dialogMonitorOps.enabled = false
				cmdStr = ("rmdir " + tempDir + " /s /q")
				DOSCommand cmdStr

				--Enable 3dsMax to update in windows
				windows.sendmessage MAX_HWND WM_SETREDRAW 1 0

				return reports
			)	
			catch
			(
				--Enable 3dsMax to update in windows
				windows.sendmessage MAX_HWND WM_SETREDRAW 1 0

				-- Turn the ok button clicker off as well
				dialogMonitorOps.enabled = false

				return reports
			)
		),

		-- Completed 2023/01/31		
		-- Checks if there is a skin modifier on the current selection
		function skinCheck arg_list =
		(
			struct report
			(
				pass 	= true,
				noSkin 	= #()
			)

			newReport 	= report()

			-- Collect all the nodes with a skin modifier on them, filtered by an optional list

			-- Collect only geometryclass objects
			meshes = collect3dLib.collectByClass arg_list GeometryClass inclusive:true
			-- Remove boneGeometry from the list
			meshes = collect3dLib.collectByClass meshes BoneGeometry inclusive:false

			for node in meshes do 
			(
				hasSkin = false

				for modifier in node.modifiers do 
				(

					if ( ( classof modifier ) == Skin ) then ( hasSkin = true )

					-- print ( classof modifier )
					-- print "Skin Found"
				)

				if ( hasSkin == false ) then
				(
					-- print "No Skin Found"
					append newReport.noskin ( gethandlebyanim node )
					newReport.pass = false
				)
			)

			return newReport
		),

		-- Completed 2023/01/31
		-- Checks if there are any topology changing modifiers below the skin modifier
		function skinCheckSafeMods arg_list =
		(
			struct report
			(
				pass 						= true,
				fail_turbosmooth			= #(),
				fail_meshsmooth  			= #(),
				fail_OpenSubdiv	 			= #(), 
				fail_subdivide 	 			= #(),
				fail_Shell 					= #(),
				fail_RetopologyComponent 	= #(),
				fail_ProOptimizer 			= #(),
				fail_optimize 				= #(),
				fail_Vertex_Weld 			= #()
			)

			newReport 	= report()

			-- Collect all the nodes with a skin modifier on them, filtered by an optional list
			nodesWithSkin = collect3dLib.collectNodesByModifier Skin arg_list

			-- Loop through all the collected nodes.
			for node in nodesWithSkin do 
			(
				-- reset the skin found flag for each node
				skinModFound = false 

				-- convert nodesWithSkin from animhandles to 3dsMax nodes
				nodeAsAnim = ( getanimbyhandle node )

				-- loop through all the modifiers on each nodeAsAnim
				for modifier in nodeAsAnim.modifiers do 
				(
					-- retrieve its class
					curModClass = classof modifier

					-- If the skin modifier has been found, test for each of the invalid modifiers
					if skinModFound then 
					(
						if curModClass == TurboSmooth 			then ( append newReport.fail_turbosmooth node 			; newReport.pass = false )
						if curModClass == meshsmooth 			then ( append newReport.fail_meshsmooth node 			; newReport.pass = false )
						if curModClass == OpenSubdiv 			then ( append newReport.fail_OpenSubdiv node 			; newReport.pass = false )
						if curModClass == subdivide 			then ( append newReport.fail_subdivide node 			; newReport.pass = false )
						if curModClass == Shell 				then ( append newReport.fail_Shell node 				; newReport.pass = false )
						if curModClass == RetopologyComponent 	then ( append newReport.fail_RetopologyComponent node 	; newReport.pass = false )
						if curModClass == ProOptimizer 			then ( append newReport.fail_ProOptimizer node 			; newReport.pass = false )
						if curModClass == optimize 				then ( append newReport.fail_optimize node 				; newReport.pass = false )
						if curModClass == Vertex_Weld 			then ( append newReport.fail_Vertex_Weld node 			; newReport.pass = false )
					)					

					-- Check if the skin modifier has been reached in the stack, if it has, set the flag to true
					-- Doing this last, to avoid unnecessary tests
					if ( curModClass == Skin ) then (skinModFound = true)
				)
			)

			return newReport
		),

		-- Completed 2023/01/31
		-- Adds a skin modifier to the object with 100% weighting to the objects parent
		-- arg_parent - Either a node or undefined, to use current objects parent.
		function skinParent arg_list arg_parent = 
		(
			struct report
			(
				pass 		= true,
				childIds 	= #(),
				orphanIds 	= #()
			)

			newReport 	= report()

			-- Collect only geometryclass objects
			meshes = collect3dLib.collectByClass arg_list GeometryClass inclusive:true
			-- Remove boneGeometry from the list
			meshes = collect3dLib.collectByClass meshes BoneGeometry inclusive:false

			try(
				-- Disable the 3dsMax from updating in windows
				WM_SETREDRAW 	= 11
				MAX_HWND 		= windows.getMaxHWND()
				windows.sendmessage MAX_HWND WM_SETREDRAW 0 0
	
				-- Store selections, and command panel mode
				sel 	= selection as array
				mode 	= getCommandPanelTaskMode()
	
				-- Go through each of the collected meshes
				for mesh in meshes do 
				(
					curParent = undefined
	
					-- Case for no passed argument for the parent 
					if (arg_parent == undefined ) then 
					(
						curParent = mesh.parent
					)
					-- Case for passed argument for the parent
					else 
					(
						curParent = arg_parent
					)
	
					-- If it has a parent
					if ( curParent != undefined ) then 
					(
						-- Add a skin modifier, and skin it
						newSkin = Skin()
	
						addModifier mesh newSkin
						modPanel.setCurrentObject mesh.baseObject
						modPanel.setCurrentObject mesh.modifiers[#Skin]
						skinOps.addBone mesh.modifiers[#Skin] curParent 1
						mesh.modifiers[#Skin].cross_radius = 1

						append newReport.childIds ( getHandleByAnim mesh )
					)
					else
					(
						-- Otherwise signal not all objects were skinned
						newReport.pass = false
						append newReport.orphanIds ( getHandleByAnim mesh )
					)
	
				-- Restore the selection, command panel to previous state
				if sel.count then select sel else clearselection()
				setCommandPanelTaskMode mode:mode
	
				-- Enable 3dsMax to update in windows
				windows.sendmessage MAX_HWND WM_SETREDRAW 1 0
				)
			)
			catch
			(
				-- Restore the selection, command panel to previous state
				if sel.count then select sel else clearselection()
				setCommandPanelTaskMode mode:mode
	
				-- Enable 3dsMax to update in windows
				windows.sendmessage MAX_HWND WM_SETREDRAW 1 0
			)

			-- Returns any mesh objects that were not skinned
			return newReport
		),

		-- Completed 2023/01/31
		-- Sets the pivot of any meshes to the origin, underneath a skin, with its properties set to "always deform off"
		function skinPivotReset arg_list =
		(

			-- Collect only geometryclass objects
			meshes = collect3dLib.collectByClass arg_list GeometryClass inclusive:true
			-- Remove boneGeometry from the list
			meshes = collect3dLib.collectByClass meshes BoneGeometry inclusive:false

			struct report
			(
				pass 		= true,
				editedIds 	= #()
			)

			newReport 	= report()

			-- For each item in the list
			for mesh in meshes do
			(
				try
				(
					-- If the objects pivot does not = the origin, then
					if mesh.pivot != [0,0,0] then 
					(
						mods = mesh.modifiers
						test = false
						
						-- Look through each of the modifiers
						for i in 1 to ( mesh.modifiers.count) do
						(	
					
							curMod = mesh.modifiers[i]
					
							-- If the modifier is a skin modifier
							if (classof curMod) == skin 
							then
							(
								-- Reset the pivot
								mesh.pivot = [0,0,0]
					
								-- Turn things off then back on again
								curMod.enabled = false 
								curMod.enabled = true
								curMod.always_deform = false
								curMod.always_deform = true
					
								-- Indicate that the pivot was modified
								test = true
							)
						)
						
						-- If all modifiers were looped through, and the pivot was not moved, move it.
						if test == false then mesh.pivot = [0,0,0]

						-- Add the information to the report
						append newReport.editedIds ( getHandleByAnim mesh )
					)

					else()
				)
				catch ( newReport.pass = false )
			)

			-- Returns a report with pass/fail, and a list of all nodes that were edited, if any
			return newReport
		),

		-- Completed 2023/01/31
		-- Adds a skin wrap, and then adds meshes, then converts to skin
		function skinwrapStealWeights arg_node arg_list =
		(
			try(
				-- Disable the 3dsMax from updating in windows
				WM_SETREDRAW 	= 11
				MAX_HWND 		= windows.getMaxHWND()
				windows.sendmessage MAX_HWND WM_SETREDRAW 0 0
	
				-- Setup and add the modifier
				newSkin_Wrap = Skin_Wrap()
				newSkin_Wrap.engine = 0
				newSkin_Wrap.weightAllVerts = true
				newSkin_Wrap.meshList = arg_list
				addModifier arg_node newSkin_Wrap
	
				-- Store selections, and command panel mode
				sel 	= selection as array
				mode 	= getCommandPanelTaskMode()
	
				-- Set command panel to Modify mode, and select the skinwrap, then convert it to skin
				setCommandPanelTaskMode mode:#modify
				modPanel.setCurrentObject arg_node.skin_wrap
				arg_node.skin_wrap.ConvertToSkin on
	
				-- Get rid of the old skinwrap
				deleteModifier arg_node newSkin_Wrap
	
				-- Restore the selection, command panel to previous state
				if sel.count then select sel else clearselection()
				setCommandPanelTaskMode mode:mode
	
				-- Enable 3dsMax to update in windows
				windows.sendmessage MAX_HWND WM_SETREDRAW 1 0
			)
			catch
			(
				-- Enable 3dsMax to update in windows
				windows.sendmessage MAX_HWND WM_SETREDRAW 1 0
			)
		),

--- Mesh Functions ---

		-- Completed 2023/01/10
		-- Totally resets all the properties of a mesh, by creating a new 1 polygon mesh, attaching the original mesh to it, and then deleting the single polygon.
		-- Good for getting rid of anything and everything on a mesh, and making it clean as possible.
		-- function will preserve wirecolor, name, and parent.
		function meshCollapseAndReset arg_list =
		(
			-- Collect only geometryclass objects
			meshes = collect3dLib.collectByClass arg_list GeometryClass inclusive:true
			-- Remove boneGeometry from the list
			meshes = collect3dLib.collectByClass meshes BoneGeometry inclusive:false
			newMeshes = #()
			curFloat = 0.000

			for mesh in meshes do 
			(

				curFloat += 1.000

				-- Store some properties to restore later
				holdWire 	= mesh.wirecolor
				holdName 	= mesh.name
				holdParent 	= mesh.parent
				holdLayer 	= mesh.layer

				-- Try to update the UI if it exists
				try(rigBuddy.uiMain.labelStatus.text = ( "Cleaning mesh: " + holdName )	)catch()

				-- Create a new plane to serve as donor object
				newPlane = plane()
				newPlane.widthsegs = 1
				newPlane.lengthsegs = 1

				-- Convert both meshes into editpolys 
				polyMesh1 = ( ConvertToPoly newPlane )
				polyMesh2 = ( ConvertToPoly mesh )

				-- Attach the src object to the donor object
				polyop.attach polyMesh1 polyMesh2
				
				-- Remove the single poloygon from the donor object
				newEdit_Poly = Edit_Poly()
				addmodifier polyMesh1 newEdit_Poly
				polyop.deletefaces polyMesh1 #{1}
				polyMesh1 = ( ConvertToPoly polyMesh1 )

				-- Restore previously stored properties
				polyMesh1.wirecolor = holdWire 	
				polyMesh1.name = holdName 	
				polyMesh1.parent = holdParent
				holdLayer.addnode polyMesh1


				-- Add the new mesh to the list of new meshes
				append newMeshes polyMesh1

				-- Try to communicate with the UI, if it exists
				try(rigBuddy.uiMain.progBar1.value = ( ( curFloat / meshes.count ) * 100 ) )catch()
			)

			return newMeshes
		),

--- Rigging / Transforms Functions ---

		-- Completed 2023/01/30
		-- returns the position planar to the 3 passed objects, that is aligned to the hypotenuse of the second object. ( usefull for placing pole vectors )
		function hypotenusePoint arg_list =
		(
			-- This is usefull for creating polvector nodes that will not shift an IK System when chosen.
			-- The second object selected is the " knee " the new point will be created off of the hypotenuse of that point

			struct report
			(
				pass 		= true,
				curObjects 	= undefined,
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

		-- Completed 2023/01/30
		-- Checks for objects not at a uniform 100% scale, returns report with arrays of all types of scaling
		function checkForScaledTransforms arg_list =
		(

			struct report
			(
				pass 				= true,
				nonScaled 			= #(),	
				uniformScaled 		= #(),
				nonUniformScaled  	= #(),
				uniformInverted 	= #()
			)

			newReport 	= report()

			allNodes = #()

			for arg in arg_list do 
			(
				newNodes = ( collect3dLib.collectAllChildren arg )
				join allNodes newNodes
			)

			-- Loop through all the objects
			for node in allNodes do
			(
				-- Floating point error that is acceptable to be within.
				epsilon = 0.001

				-- True condition for if all scale dimensions are equal to 1, within error
				if ( math3dLib.withinEpsilon node.scale[1] 1.0000 epsilon ) and ( math3dLib.withinEpsilon node.scale[2] 1.0000 epsilon ) and ( math3dLib.withinEpsilon node.scale[3] 1.0000 epsilon ) then 
				(
					append newReport.nonScaled ( gethandlebyanim node )
				)
				else
				(
					newReport.pass = false

					if ( math3dLib.withinEpsilon node.scale[1] -1.0000 epsilon ) and ( math3dLib.withinEpsilon node.scale[2] -1.0000 epsilon ) and ( math3dLib.withinEpsilon node.scale[3] -1.0000 epsilon ) then 
					(
						append newReport.uniformInverted ( gethandlebyanim node )
					)
					else 
					(

						-- True condition for if all scale dimensions are equal to eachother, within error
						if ( math3dLib.withinEpsilon node.scale[1] node.scale[2] epsilon ) and ( math3dLib.withinEpsilon node.scale[1] node.scale[3] epsilon ) then 
						(
							append newReport.uniformScaled ( gethandlebyanim node )
						)
						
						else 
						(
							append newReport.nonUniformScaled ( gethandlebyanim node )
						)
					)
				)
			)

			-- Returns a report with pass/fail, and a list of all nodes that failed, if any
			return newReport
		),

		-- Completed 2023/01/18
		-- reparents all selected objects to their global, or top level parent
		function parentNodesToProtoplast arg_list =
		(
			parentActions = #()
			actionsTaken = 0

			struct heirarchyOperationStr 
			(
				node = undefined,
				parentNode = undefined
			)

			-- Set up actions
			for node in arg_list do 
			(
				ho = heirarchyOperationStr()
				pp = collect3dLib.collectProtoplasts #(node) -- collectProtoplasts runs on lists

				ho.node = node
				ho.parentNode = pp

				append parentActions ho 
			)

			-- Perform actions
			for action in parentActions do 
			(
				-- Do the parent 
				--action.node.parent = action.parentNode[1]
				if action.node != action.parentNode[1] then 
				(
					action.node.parent = action.parentNode[1]
					actionsTaken += 1
				)
				--print ( action.node.parent.name + " -> " + action.parentNode[1].name )
				--print action
			)

			return actionsTaken
		),

		function createRay arg_list =
		(

			struct report
			(
				pass = false,
				newRay = undefined
			)

			newReport = report()

			if arg_list.count == 2 then 
			(
				newReport.pass = true 
			)

			if newReport.pass then 
			(

				-- Disable the 3dsMax from updating in windows
				WM_SETREDRAW 	= 11
				MAX_HWND 		= windows.getMaxHWND()
				windows.sendmessage MAX_HWND WM_SETREDRAW 0 0
	
				-- Store selections, and command panel mode
				--sel 	= selection as array
				mode 	= getCommandPanelTaskMode()

				curTime 	= sliderTime
				slidertime 	= animationrange.start 
				
				max modify mode
								
				p1 = arg_list[1]
				p2 = arg_list[2]

				p1t = p1.pos
				p2t = p2.pos

				newRayName = ("RAY_"+p1.name+"-to-"+p2.name)

				newRay = line pos:p1t name:newRayName wirecolor:red render_renderable:off render_displayRenderMesh:false
				addNewSpline newRay
				addKnot newRay 1 #corner #line p1t
				addKnot newRay 1 #corner #line p2t
				updateShape newRay

				newRay.parent = p1
				newReport.newRay = newRay

				modPanel.setCurrentObject newRay.baseObject
				modPanel.addModToSelection (Skin ()) ui:on
				skinOps.addBone newRay.modifiers[#Skin] p1 1
				skinOps.addBone newRay.modifiers[#Skin] p2 1
				newRay.modifiers[#Skin].cross_radius = 1
					
				sliderTime = curtime 

				select arg_list

				-- Restore the selection, command panel to previous state
				setCommandPanelTaskMode mode:mode
	
				-- Enable 3dsMax to update in windows
				windows.sendmessage MAX_HWND WM_SETREDRAW 1 0
			)

			return newReport
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

		-- Completed 2023/01/18
		-- Requres namesMakeValidPrefixesCollect to be executed first
		-- Applies the naming actions to the nodes prepared in the collect
		function namesMakeValidPrefixes arg_ppData = 
		(

			for failId in arg_ppData.failNamesIds do 
			(
				curNode = getAnimByHandle failId
				curNode.name = ( arg_ppData.nameTag + curNode.name )
			)
		),

		-- Completed 2023/01/27
		-- Verifies all children of the selected object have the same starting name / asset tag.
		-- Returns a useful list called protoplastsData. This list contains all objects, the desired name tag, and any items that do not match
		function namesMakeValidPrefixesCollect arg_list = 
		(

			struct report
			(
				pass 			= true,
				-- nameTag 		= "",
				protoplasts 	= #(),
				protoplastsData = #()
			)

			struct protoplastDataStruct
			(
				pass 			= undefined,
				protoplast 		= undefined,
				masterName 		= undefined,
				nameTag 		= undefined,
				allChildren 	= #(),
				failNamesIds 	= #()
			)

			newReport 	= report()


			-- Seperate heirarchies at the same time.
			protoplasts 			= collect3dLib.collectProtoplasts arg_list
			newReport.protoplasts 	= protoplasts

			-- Collect and prepare all the children and names, and test children for incorrect names, and add them to failNamesIds
			for protoplast in protoplasts do 
			(

				ppData 				= protoplastDataStruct()
				ppData.protoplast 	= protoplast

				-- Get and store all the children of the protoplast
				ppData.allChildren 	= collect3dLib.collectAllChildren protoplast includeParent:false

				-- Get and store the masterName for the asset
				ppData.masterName 	= protoplast.name
				masterNameParts 	= ( FilterString ppData.masterName "_" )

				-- If the mastername does not have any delimiters in it, a name tag cannot be generated, so pass result as a false
				if masterNameParts.count == 1 then 
				(
					ppData.pass = false 
				)
				else
				(
					ppData.pass = true 

					-- Builds a name tag, based off of the object, should look something like "C_TGD_"
					ppData.nameTag 		= ( masterNameParts[1] + "_" + masterNameParts[2] + "_" )
	
					-- Collect child names that do not start with the tag
					for child in ppData.allChildren do 
					(
						childPrefix = (substring child.name 1 ppData.nameTag.count )
						--print childPrefix

						if childPrefix != ppData.nameTag then 
						(
							append ppData.failNamesIds ( getHandleByAnim child )
						)
					)
	
					-- Store the ppData in the main report
					append newReport.protoplastsData ppData
				)
			)

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

			return curProp
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
				id 			= undefined,
				pass 		= undefined,
				currentVal 	= undefined,
				storedVal 	= undefined
			)

			newReport = report()

			newReport.currentVal = rbLib.collectNodeName arg_node
			newReport.storedVal = rbLib.getUserPropsNodeName arg_node
			--newReport.id = ( getAnimByHandle arg_node )
			newReport.id = ( getHandleByAnim arg_node )

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
		function compareUserPropsWirecolor arg_node =
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



	-- Skin Functions --

		-- FN skinDeformReset
			-- clearListener()
			-- timeStamp()
			-- selArr = ( selection as array )
			-- rbLib.skinDeformReset selArr			

		-- FN skinCheckSafeMods
			-- clearListener()
			-- timeStamp()
			-- selArr = ( selection as array )
			-- rbLib.skinCheckSafeMods selArr			

		-- FN skinParentToSkin
			-- clearListener()
			-- timeStamp()
			-- selArr = ( selection as array )
			-- -- rbLib.skinParent selArr undefined -- test for retriving a parent from the heirarchy
			-- rbLib.skinParent selArr $Point001 -- test for passing a new parent

		-- FN skinPivotReset
			-- clearListener()
			-- timeStamp()
			-- selArr = ( selection as array )
			-- rbLib.skinPivotReset selArr

		-- FN skinwrapStealWeights
			-- clearListener()
			-- timeStamp()
			-- rbLib.skinwrapStealWeights selection[2] #(selection[1])

	-- Mesh Functions --
		-- FN meshCollapseAndReset
			-- clearListener()
			-- timestamp()
			-- result = rbLib.meshCollapseAndReset ( selection as array )
			-- select result

	-- Rigging / Transforms Functions --

		-- FN hypotenusePoint 
			-- clearListener()
			-- print ( timeStamp() )
			-- rbLib.hypotenusePoint ( selection as array )

		-- FN checkForScaledTransforms
			-- clearListener()
			-- print ( timeStamp() )
			-- selArr = selection as array 
			-- result = rbLib.checkForScaledTransforms selArr
			--		
			-- result2 = collect3dLib.collectByAnimhandle result.nonUniformScaled
			--
			-- print result
			-- print result2
			--
			-- select result2
	
	-- Name Functions --

		-- FN parentNodesToProtoplast
			-- clearListener()
			-- print ( timeStamp() )
			-- selArr = selection as array 
			-- rbLib.parentNodesToProtoplast selArr

		-- FN namesMakeValidPrefixes
			-- clearListener()
			-- print ( timeStamp() )
			-- result = ( rbLib.namesMakeValidPrefixesCollect ( selection as array ) )
			-- -- !! Requires a collect before execution
			-- for ppData in result.protoplastsData do ( rbLib.namesMakeValidPrefixes ppData )

		-- FN namesMakeValidPrefixesCollect
			-- clearListener()
			-- print ( timeStamp() )
			-- result = ( rbLib.namesMakeValidPrefixesCollect ( selection as array ) )
			-- print result.protoplastsData[1].failNamesIds

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
	