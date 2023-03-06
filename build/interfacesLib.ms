struct rbInterfacesStruct
(
	version = "0.0.1",

	-- Sets the display and properties of the list view
	function lvSetproperties arg_lv =
	(
		arg_lv.view 			= (dotNetClass "system.windows.forms.view").details
		arg_lv.FullRowSelect 	= true													-- Set so full width of listView is selected and not just first column.
		arg_lv.GridLines 		= true													-- Show lines between the items. 
		arg_lv.MultiSelect 		= false													-- Set to single selection mode
		arg_lv.checkboxes 		= true
		arg_lv.BackColor 		= (dotNetClass "System.Drawing.Color").FromArgb 200 200 200
 		arg_lv.ForeColor 		= (dotNetClass "System.Drawing.Color").FromArgb 30 30 30
		arg_lv.CheckBoxes 		= true
	),

	-- Sets the width of the list view columns, and their names.................
	function lvSetColumns arg_LV arg_columns arg_widths =
	(
		arg_LV.clear()

		for i in 1 to arg_columns.count do 
		(
			arg_lv.columns.add arg_columns[i] arg_widths[i]
		)
	),

	function uiMainModeReset =
	(
		try(
		-- Items that are disabled, until a check is run. They go in this list to be re-disabled when modes are changed
		allItemsDisabled 	= #(
			RigBuddy.uiMain.btnRigScaleSelect,
			RigBuddy.uiMain.btnBakePCSelect,
			RigBuddy.uiMain.btnSkinSelect,
			RigBuddy.uiMain.btnSkinSafeModsSelect,
			RigBuddy.uiMain.btnNameDupeSelect,
			RigBuddy.uiMain.btnNameAutoApply,
			RigBuddy.uiMain.btnNamePrefixSelect,
			RigBuddy.uiMain.btnNamePrefixApply
		)

		-- Disable all interface items that should default to disabled
		for item in allItemsDisabled do ( try( item.enabled = false )catch() )

		-- Clear list view
		rbi 	= rigBuddy.interfaces
		try( rbi.lvSetColumns	rigBuddy.uiMain.LVMain #("","") #(20,550) )catch()
		--try(rigBuddy.uiMain.LVMain.clear())catch()

		)catch()
	),

	function uiMainMode arg_mode =
	(
		
		rbuimi 				= rigBuddy.uiMainItems 	-- Shorten the var
		allItems 			= #()					-- start with a clean list
		
		rigBuddy.interfaces.uiMainModeReset()

		-- collect all the types of ui items and put them in the list
		join allItems rbuimi.uiMeshes 	
		join allItems rbuimi.uiBaking 		
		join allItems rbuimi.uiSkinning 		
		join allItems rbuimi.uiRigging 		
		join allItems rbuimi.uiNaming 		
		join allItems rbuimi.uiUserProperties


		-- Turn off all items
		for item in allItems do (try ( item.visible = false)catch())

		-- Turn on item if it matches designation, and set the UI height
		if arg_mode == "Meshes"	then
		(
			for item in rbuimi.uiMeshes do ( try( item.visible = true )catch() )
			try( rigBuddy.uiMain.height = 200 )catch() -- inside try catch, because UI cannot be set before its first running
		)
		if arg_mode == "Baking"	then
		(
			for item in rbuimi.uiBaking	do ( try( item.visible = true )catch() )
			try( rigBuddy.uiMain.height = 250 )catch() -- inside try catch, because UI cannot be set before its first running
		)
		if arg_mode == "Skinning" then
		(
			for item in rbuimi.uiSkinning 		do ( try( item.visible = true )catch() )
			try( rigBuddy.uiMain.height = 400 )catch() -- inside try catch, because UI cannot be set before its first running
		)
		if arg_mode == "Rigging" then
		(
			for item in rbuimi.uiRigging 		do ( try( item.visible = true )catch() )
			try( rigBuddy.uiMain.height = 300 )catch() -- inside try catch, because UI cannot be set before its first running
		)
		if arg_mode == "Naming" then
		(
			for item in rbuimi.uiNaming do ( try( item.visible = true )catch() )
			try( rigBuddy.uiMain.height = 300 )catch() -- inside try catch, because UI cannot be set before its first running
		)
		if arg_mode == "User Properties" then
		(
			for item in rbuimi.uiUserProperties 	do ( try( item.visible = true )catch() )
			try( rigBuddy.uiMain.height = 350 )catch() -- inside try catch, because UI cannot be set before its first running
		)
	),

	-- Function to create the main ui object
	function uiMainInit  =
	(

		-- Instantiate the location for the ui items to be stored for easy access later
		struct uiMainModeItems
		(
			uiMeshes 			= #(),
			uiBaking 			= #(),
			uiSkinning 			= #(),
			uiRigging 			= #(),
			uiNaming 			= #(),
			uiUserProperties 	= #()
		)

		rigBuddy.uiMainItems = uiMainModeItems()

		-- Top Bar Menu Items
		rcMenu rc_MainMenu
		(
			subMenu		"Mode"
			(
				menuItem	miRigging			"Rigging"
				--menuItem	miMeshes			"Meshes"
				menuItem	miBaking			"Baking"
				menuItem	miSkinning			"Skinning"
				menuItem	miNaming			"Naming"
				menuItem	miUserProperties	"User Properties"
			)	
			--subMenu		"Utilities"
			--(
			--	menuItem	miAssetInspector	"Asset Inspector"
			--)	
			subMenu		"Help"
			(
				--menuItem 	MI_Help_Help		"Help"
				menuItem 	MI_Help_About		"About"
			)

			-- Cases for each of the modes
			on miMeshes				picked do ( rigBuddy.interfaces.uiMainMode "Meshes"			 )
			on miBaking				picked do ( rigBuddy.interfaces.uiMainMode "Baking"			 )
			on miSkinning			picked do ( rigBuddy.interfaces.uiMainMode "Skinning"		 )
			on miRigging			picked do ( rigBuddy.interfaces.uiMainMode "Rigging"		 )
			on miNaming				picked do ( rigBuddy.interfaces.uiMainMode "Naming"			 )
			on miUserProperties		picked do ( rigBuddy.interfaces.uiMainMode "User Properties" )

			-- Help portion
			on MI_Help_About		picked do ( rigBuddy.interfaces.uiAboutInit() )
		)


		curVerNumStr = rigBuddy.lib.verNumStr()
		rollout uiMainRollout ( "MAKE Rig Buddy v" + curVerNumStr ) width:1000 height:10
		(
			dotNetControl 	lvMain 						"system.windows.forms.listView" pos:[420,0] height:200 width:575					
			label 			labelStatus					"Status: initializing"			pos:[0,0]	align:#left	
			progressbar 	progBar1 					width:990 						pos:[0,0] 	height:6 value:80 color:[0,90,60]
			progressbar 	progBar2 					width:990 						pos:[0,0] 	height:6 value:50 color:[0,60,90]

			label 			labRigging					"Rigging:"														pos:[10,10]	
				label 			labRigScale				"Transforms:"													pos:[24,30]
				button 			btnRigScaleCheck 		"Check selection and all children for scaled transforms"		pos:[24,45] width:300
				button 			btnRigScaleSelect 		"Select Scaled"														pos:[325,45] width:85 enabled:false

				label 			labRigHeirarchy			"Heirarchiy:"													pos:[24,70]
				button 			btnRigHeirReparent 		"Reparent selection to its global ( no intermediate nodes )"	pos:[24,85] width:390

				label 			labRigHelpers			"Helpers:"														pos:[24,110]
				button 			btnRigHelperHypot 		"Create hypotenuse point"										pos:[24,125] width:390
				button 			btnRigHelperRay 		"Create bound ray between 2 objects"		pos:[24,147] width:390 --enabled:false

			label 			labBaking					"Baking Tools"													pos:[10,10]	align:#left	
				label 			labBakePC				"Point Cache modifier:"											pos:[24,30]
				button 			btnBakePCCheck 			"Check selection for Point Cache modifiers"						pos:[24,45] width:300
				button 			btnBakePCSelect 		"Select"														pos:[325,45] width:85 enabled:false
				button 			btnBakePCAdd 			"Add PointCaches above Skins"									pos:[24,68] width:191 -- "Add point cache modifier above skin"
				button 			btnBakePCSwapSkin		"Replace Skins with PointCaches"								pos:[217,68] width:193 -- "Convert skin modifiers to Point Cache modifiers"
				label 			labBakeTFB				"Transform Baker: ( feature pending )"							pos:[24,125] enabled:false
				label 			labBakePCB				"Point Cache Batch: ( feature pending )"						pos:[24,145] enabled:false
				label 			labBakeBNS				"Bake N Save: ( feature pending )"								pos:[24,165] enabled:false

			label 			labMeshes					"Mesh Tools"					pos:[10,10]	align:#left

			label 			labSkinning					"Skinning Tools"				pos:[10,10]	align:#left	

				label 			labSkinModChecks		"Skin modifier:"												pos:[24,30]
				button 			btnSkinCheck 			"Check selection for skin modifiers"							pos:[24,45] width:300
				button 			btnSkinSelect 			"Select"														pos:[325,45] width:85 enabled:false
				button 			btnSkinSafeMods 		"Check for unsafe modifiers under skins modifiers"				pos:[24,67] width:300
				button 			btnSkinSafeModsSelect 	"Select"														pos:[325,67] width:85 enabled:false

				label 			labSkinModOp			"Skin modifier operations:"										pos:[24,95]
				button 			btnSkinDeformReset 		"Skin Deformmations Reset **"				pos:[24,110] width:385 enabled:false
				button 			btnSkinPivotReset 		"Set pivot of skinned mesh to origin, preserving offset **"		pos:[24,132] width:385 enabled:false

				label 			labSkinBinding			"Skin weights and binding:"										pos:[24,160]
				button 			btnSkinwrapStealDo 		"Skin using Skin Wrap - ( last selected will recive the skin ) **" pos:[24,175] width:385 enabled:false
				button 			btnSkinParent 			"Skin Parent - ( last selected will be the parent ) **"  			pos:[24,197] width:385 enabled:false

				label 			labMeshClean			"Mesh Prep: "													pos:[24,225] 			
				button 			btnMeshClean			"Collapse and reset mesh "										pos:[24,240] width:385

				label 			labSkinProxy			"Build Proxy Geo: ( feature pending )"							pos:[24,270] 			enabled:false
				button 			btnSkinProxyDo			"Generate symmetrical reduced mesh for weighting from selection"pos:[24,285] width:385 	enabled:false
				spinner 		spnPolycount 			"Polycount" 	type:#integer range:[10,5000,1000]				pos:[40,307] width:370 	enabled:false

			label 			labNaming					"Naming Tools"					pos:[10,10]	align:#left	

				button 			btnNameDupeCheck 		"Check selection for duplicate names "						pos:[10,30]	 	width:300
				button 			btnNameDupeSelect 		"Select "													pos:[310,30] 	width:100 enabled:false

				button 			btnNameAutoCheck 		"Preview Auto Generated Unique name on selection "			pos:[10,60] 	width:300 
				button 			btnNameAutoApply 		"Apply "													pos:[310,60] 	width:100 enabled:false

				button 			btnNamePrefixCheck 		"Check hierarchy prefix tags against Global "				pos:[10,90]		width:300
				button 			btnNamePrefixSelect 	"Select "													pos:[310,90] 	width:100 enabled:false
				button 			btnNamePrefixApply 		"Apply "													pos:[310,112] 	width:100 enabled:false

				button  		btnNameUPCheck 			"Check selection for stored name" 							pos:[10,140] 	width:400
				button  		btnNameUPGet 			"Fetch stored name" 										pos:[10,162] 	width:200
				button  		btnNameUPSet 			"Store current name" 										pos:[210,162] 	width:200

			label 			labUserProps				"User Property Tools"			pos:[10,10]	align:#left

				button  		btnUserPropsGetAll 			"Fetch all" 											pos:[10,30] 	width:134
				button  		btnUserPropsSetAll 			"Store all" 											pos:[144,30] 	width:134
				button  		btnUserPropsClearAll 		"Clear all" 											pos:[278,30] 	width:134
				
				label 			labUserPropsName			"Name:"													pos:[24,60]	
				button  		btnUserPropsNameCheck 		"Check name" 											pos:[20,75] 	width:390
				button  		btnUserPropsNameGet 		"Fetch name" 											pos:[20,97] 	width:130
				button  		btnUserPropsNameSet 		"Store name" 											pos:[150,97] 	width:130
				button  		btnUserPropsNameClear 		"Clear name" 											pos:[280,97] 	width:130

-- <<<<<<< Updated upstream
--				label 			labUserPropsParent			"Parent:"												pos:[24,130] 
--				button  		btnUserPropsParentCheck 	"Check parent" 											pos:[20,145] 	width:390
--				button  		btnUserPropsParentGet 		"Fetch parent" 											pos:[20,167] 	width:130
--				button  		btnUserPropsParentSet 		"Store parent" 											pos:[150,167]	width:130
--				button  		btnUserPropsParentClear		"Clear parent" 											pos:[280,167] 	width:130
--
--				label 			labUserPropsWirecolor		"Wirecolor:"											pos:[24,200] 
--				button  		btnUserPropsWirecolorCheck 	"Check wirecolor" 										pos:[20,215] 	width:390
--				button  		btnUserPropsWirecolorGet 	"Fetch wirecolor" 										pos:[20,237] 	width:130
--				button  		btnUserPropsWirecolorSet 	"Store wirecolor" 										pos:[150,237] 	width:130
--				button  		btnUserPropsWirecolorClear 	"Clear wirecolor" 										pos:[280,237] 	width:130
--
--				label 			labUserPropsDate			"Publish Date:"											pos:[24,270] 
--				button  		btnUserPropsDateGet 		"Check publish date" 									pos:[20,285] 	width:130
--				button  		btnUserPropsDateSet 		"Store current date" 									pos:[150,285] 	width:130
--				button  		btnUserPropsDateClear 		"Clear publish date" 									pos:[280,285] 	width:130
-- =======
				label 			labUserPropsParent					"Parent:"						pos:[24,130] 
				button  		btnUserPropsParentCheckSet 			"Check if Stored"	 			pos:[20,145] 	width:130
				button  		btnUserPropsParentCheckSetSel 		"Select"			 			pos:[150,145] 	width:65 enabled:false
				button  		btnUserPropsParentCheckMatch		"Check stored = current"		pos:[215,145] 	width:130
				button  		btnUserPropsParentCheckMatchSel 	"Select"						pos:[345,145] 	width:65 enabled:false
				button  		btnUserPropsParentGet 				"- Fetch parent" 				pos:[20,167] 	width:130
				button  		btnUserPropsParentSet 				"Store parent" 					pos:[150,167]	width:130
				button  		btnUserPropsParentClear				"- Clear parent" 				pos:[280,167] 	width:130

				label 			labUserPropsWirecolor				"Wirecolor:"					pos:[24,200] 
				button  		btnUserPropsWirecolorCheckSet 		"Check if Stored" 				pos:[20,215] 	width:130
				button  		btnUserPropsWirecolorCheckSetSel	"Select"			 			pos:[150,215] 	width:65 enabled:false
				button  		btnUserPropsWirecolorCheckMatch		"Check stored = current"		pos:[215,215] 	width:130
				button  		btnUserPropsWirecolorCheckMatchSel 	"Select"						pos:[345,215] 	width:65 enabled:false
				button  		btnUserPropsWirecolorGet 			"- Fetch wirecolor" 			pos:[20,237] 	width:130
				button  		btnUserPropsWirecolorSet 			"Store wirecolor" 				pos:[150,237] 	width:130
				button  		btnUserPropsWirecolorClear 			"- Clear wirecolor" 			pos:[280,237] 	width:130

				label 			labUserPropsDate					"Publish Date:"					pos:[24,270] 
				button  		btnUserPropsDateGet 				"- Check publish date" 			pos:[20,285] 	width:130
				button  		btnUserPropsDateSet 				"Store current date" 			pos:[150,285] 	width:130
				button  		btnUserPropsDateClear 				"- Clear publish date" 			pos:[280,285] 	width:130
-- >>>>>>> Stashed changes

			-- Rigging Functions
				function fnRigScaleCheck =
				(
					reports = #()
					selArr 	= ( selection as array  )
					collectedItems = #()
	
					-- Check for objects with scaled transforms	
					newReport = ( rigBuddy.lib.checkForScaledTransforms selArr )
	
					-- Store the data for use elswhere
					rigBuddy.report = newReport

					-- Set the list view
					rbi = rigBuddy.interfaces
					rbi.lvSetColumns	lvMain #("","Scaled","Scaling","Animhandle","Name") #(22,50,80,70,348)	
					rows = #()

					-- TODO: Add handling around duplicate selections

					-- Add items to the UI for uniform scaled objects
					if newReport.pass == false then 
					(

						for node in newReport.uniformScaled do 
						(
							-- Make a new List view Item
							li=dotNetObject "System.Windows.Forms.ListViewItem" ""
							li.UseItemStyleForSubItems = false					
							li.subitems.add ( "True" )
							li.subitems.add ( "Uniform" )
							li.subitems.add ( node as string )
							curNode = ( getAnimByHandle node )
							li.subitems.add ( curNode.name  )
							append rows li
						)

						-- Add items to the UI for non-uniform scaled objects
						for node in newReport.nonUniformScaled do 
						(
							-- Make a new List view Item
							li=dotNetObject "System.Windows.Forms.ListViewItem" ""
							li.UseItemStyleForSubItems = false					
							li.subitems.add ( "True" )
							li.subitems.add ( "Non-Uniform" )
							li.subitems.add ( node as string )
							curNode = ( getAnimByHandle node )
							li.subitems.add ( curNode.name  )
							append rows li
						)

						-- turn on the select button
						btnRigScaleSelect.enabled = true
					)
	
					-- Add the rows
					lvMain.items.addRange rows
	
					-- report to the log
					rigBuddy.uiMain.labelStatus.text = ( ( rows.count as string ) + " scaled objects found")					
				)
				
				function fnRigScaleSelect =
				(
					toSelect = #()

					-- collect the uniform scaled
					for node in rigBuddy.report.uniformScaled do 
					(
						curNode = getAnimByHandle node 
						append toSelect curNode
					)

					-- collect the non uniform scaled
					for node in rigBuddy.report.nonUniformScaled do 
					(
						curNode = getAnimByHandle node 
						append toSelect curNode
					)

					select toSelect
					rigBuddy.uiMain.labelStatus.text = ( ( toSelect.count as string ) + " objects selected")
				)
				
				function fnRigHeirReparent =
				(
					-- print "fnRigHeirReparent"
					
					report = rigBuddy.lib.parentNodesToProtoplast ( selection as array )
					print report
					rigBuddy.report = report
					--print report
					rigBuddy.uiMain.labelStatus.text = ( ( report as string ) + " objects parented")
				)
				
				function fnRigHelperHypot =
				(
					selArr = ( selection as array )
					result = rigBuddy.lib.hypotenusePoint selArr 

					if result.pass then 
					(
						select result.hypotPoint
						rigBuddy.uiMain.labelStatus.text = ( result.hypotPoint.name + ( " Created, and selected" ) )
					)
					else
					(
						rigBuddy.uiMain.labelStatus.text = ( "You must select exactly 3 objects")
					)
				)
				
				function fnRigHelperRay =
				(
					selArr = ( selection as array )
					result = rigBuddy.lib.createRay selArr 

					if result.pass then 
					(
						rigBuddy.uiMain.labelStatus.text = ( "Ray " + ( result.newRay.name ) + " created")
					)
					else
					(
						rigBuddy.uiMain.labelStatus.text = ( "You must select exactly 2 objects")	
					)
				)

			-- Baking Functions
				function fnBakePCCheck = 
				(
					selArr = ( selection as array )
					rigBuddy.report = rigBuddy.lib.pointCacheTestSelection selArr

					-- Set the list view
					rbi = rigBuddy.interfaces
					rbi.lvSetColumns	lvMain #("","Modifier present","Animhandle","Name") #(22,100,80,400)	
					rows = #()

					if rigBuddy.report.failList.count == 0 then 
					(
						rigBuddy.uiMain.labelStatus.text = ( "All geometry objects have a valid point cache modifer" )	
					)
					else 
					(

						for node in rigBuddy.report.failList do
						(
							print node
							li=dotNetObject "System.Windows.Forms.ListViewItem" ""
							li.UseItemStyleForSubItems = false					
							li.subitems.add ( "False" )
							li.subitems.add ( node as string )
							curNode = ( getAnimByHandle node )
							li.subitems.add ( curNode.name  )
							append rows li
						)

						-- Add the rows
						lvMain.items.addRange rows

						-- Update the log
						rigBuddy.uiMain.labelStatus.text = ( ( rigBuddy.report.failList.count as string ) + " geometry objects found without a point cache modifier" )	

						-- Enable the select button
						btnBakePCSelect.enabled = true
					)
				)

				function fnBakePCSelect = 
				(
					newSelection = #()
					
					for node in rigBuddy.report.failList do ( append newSelection ( getAnimByHandle node ) )

					select newSelection
				)

				function fnBakePCAdd = 
				(
					selArr = ( selection as array )
					rigBuddy.lib.pointCacheAddAboveSkin selArr "above"
				)

				function fnBakePCSwapSkin = 
				(
					selArr = ( selection as array )
					rigBuddy.lib.pointCacheAddAboveSkin selArr "replace"
				)

			-- Skinning Functions
				function fnSkinCheck =
				(
					selArr = ( selection as array )
					rigBuddy.report = rigBuddy.lib.skinCheck selArr

					-- Set the list view
					rbi = rigBuddy.interfaces
					rbi.lvSetColumns	lvMain #("","Modifier present","Animhandle","Name") #(22,100,80,400)	
					rows = #()		

					for node in rigBuddy.report.noSkin do
					(
						li=dotNetObject "System.Windows.Forms.ListViewItem" ""
						li.UseItemStyleForSubItems = false					
						li.subitems.add ( "False" )
						li.subitems.add ( node as string )
						curNode = ( getAnimByHandle node )
						li.subitems.add ( curNode.name  )
						append rows li
					)

					-- Add the rows
					lvMain.items.addRange rows

					btnSkinSelect.enabled = true

					rigBuddy.uiMain.labelStatus.text = ( rigBuddy.report.noSkin.count as string + " geometry objects found without a skin modifier" )	
				)

				function fnSkinSelect =
				(
					selectList = #()

					for node in rigBuddy.report.noSkin do
					(
						append selectList ( getAnimByHandle node )
					)

					select selectList
					rigBuddy.uiMain.labelStatus.text = ( rigBuddy.report.noSkin.count as string + " objects selected" )	
				)

				function fnSkinSafeMods =
				(
					selArr = ( selection as array )
					rigBuddy.report = rigBuddy.lib.skinCheckSafeMods selArr

					-- print rigBuddy.report

					-- Set the list view
					rbi = rigBuddy.interfaces
					rbi.lvSetColumns	lvMain #("","Modifier present","Animhandle","Name") #(22,100,80,400)	
					rows = #()		

					for node in rigBuddy.report.fail_turbosmooth do
					(
						li=dotNetObject "System.Windows.Forms.ListViewItem" ""
						li.UseItemStyleForSubItems = false					
						li.subitems.add ( "Turbosmooth" )
						li.subitems.add ( node as string )
						curNode = ( getAnimByHandle node )
						li.subitems.add ( curNode.name  )
						append rows li
					)

					for node in rigBuddy.report.fail_meshsmooth do
					(
						li=dotNetObject "System.Windows.Forms.ListViewItem" ""
						li.UseItemStyleForSubItems = false					
						li.subitems.add ( "Meshsmooth" )
						li.subitems.add ( node as string )
						curNode = ( getAnimByHandle node )
						li.subitems.add ( curNode.name  )
						append rows li
					)

					for node in rigBuddy.report.fail_OpenSubdiv do
					(
						li=dotNetObject "System.Windows.Forms.ListViewItem" ""
						li.UseItemStyleForSubItems = false					
						li.subitems.add ( "OpenSubdiv" )
						li.subitems.add ( node as string )
						curNode = ( getAnimByHandle node )
						li.subitems.add ( curNode.name  )
						append rows li
					)

					for node in rigBuddy.report.fail_subdivide do
					(
						li=dotNetObject "System.Windows.Forms.ListViewItem" ""
						li.UseItemStyleForSubItems = false					
						li.subitems.add ( "Subdivide" )
						li.subitems.add ( node as string )
						curNode = ( getAnimByHandle node )
						li.subitems.add ( curNode.name  )
						append rows li
					)

					for node in rigBuddy.report.fail_Shell do
					(
						li=dotNetObject "System.Windows.Forms.ListViewItem" ""
						li.UseItemStyleForSubItems = false					
						li.subitems.add ( "Shell" )
						li.subitems.add ( node as string )
						curNode = ( getAnimByHandle node )
						li.subitems.add ( curNode.name  )
						append rows li
					)

					for node in rigBuddy.report.fail_RetopologyComponent do
					(
						li=dotNetObject "System.Windows.Forms.ListViewItem" ""
						li.UseItemStyleForSubItems = false					
						li.subitems.add ( "RetopologyComponent" )
						li.subitems.add ( node as string )
						curNode = ( getAnimByHandle node )
						li.subitems.add ( curNode.name  )
						append rows li
					)

					for node in rigBuddy.report.fail_ProOptimizer do
					(
						li=dotNetObject "System.Windows.Forms.ListViewItem" ""
						li.UseItemStyleForSubItems = false					
						li.subitems.add ( "ProOptimizer" )
						li.subitems.add ( node as string )
						curNode = ( getAnimByHandle node )
						li.subitems.add ( curNode.name  )
						append rows li
					)

					for node in rigBuddy.report.fail_optimize do
					(
						li=dotNetObject "System.Windows.Forms.ListViewItem" ""
						li.UseItemStyleForSubItems = false					
						li.subitems.add ( "Optimize" )
						li.subitems.add ( node as string )
						curNode = ( getAnimByHandle node )
						li.subitems.add ( curNode.name  )
						append rows li
					)

					for node in rigBuddy.report.fail_Vertex_Weld do
					(
						li=dotNetObject "System.Windows.Forms.ListViewItem" ""
						li.UseItemStyleForSubItems = false					
						li.subitems.add ( "Vertex_Weld" )
						li.subitems.add ( node as string )
						curNode = ( getAnimByHandle node )
						li.subitems.add ( curNode.name  )
						append rows li
					)

					-- Add the rows
					lvMain.items.addRange rows
					btnSkinSafeModsSelect.enabled = true

					rigBuddy.uiMain.labelStatus.text = ( rows.count as string + " unsafe modifiers found below skin modifiers" )	
				)

				function fnSkinSafeModsSelect =
				(

					selectList = #()

					for node in rigBuddy.report.fail_turbosmooth do
					(
						append selectList ( getAnimByHandle node )
					)

					for node in rigBuddy.report.fail_meshsmooth do
					(
						append selectList ( getAnimByHandle node )
					)

					for node in rigBuddy.report.fail_OpenSubdiv do
					(
						append selectList ( getAnimByHandle node )
					)

					for node in rigBuddy.report.fail_subdivide do
					(
						append selectList ( getAnimByHandle node )
					)

					for node in rigBuddy.report.fail_Shell do
					(
						append selectList ( getAnimByHandle node )
					)

					for node in rigBuddy.report.fail_RetopologyComponent do
					(
						append selectList ( getAnimByHandle node )
					)

					for node in rigBuddy.report.fail_ProOptimizer do
					(
						append selectList ( getAnimByHandle node )
					)

					for node in rigBuddy.report.fail_optimize do
					(
						append selectList ( getAnimByHandle node )
					)

					for node in rigBuddy.report.fail_Vertex_Weld do
					(
						append selectList ( getAnimByHandle node )
					)

					-- make the list only unique items
					uniqueSelectList = makeUniqueArray selectList 
					select uniqueSelectList

					-- Report to the logger
					rigBuddy.uiMain.labelStatus.text = ( uniqueSelectList.count as string + " objects selected" )	
				)

				function fnSkinDeformReset =
				(
				)

				function fnSkinPivotReset =
				(
					--TODO: Left off here
					selArr = ( selection as array )
					rigBuddy.report = rigBuddy.lib.skinPivotReset selArr
				)

				function fnSkinwrapStealDo =
				(
				)

				function fnSkinParent =
				(
				)

				function fnMeshClean =
				(
					selArr = ( selection as array )
					rigBuddy.report = rigBuddy.lib.meshCollapseAndReset selArr

					select rigBuddy.report
					
					rigBuddy.uiMain.labelStatus.text = ( ( rigBuddy.report.count as string ) + " meshes cleaned" )
				)

				function fnSkinProxyDo =
				(
				)

			-- Naming Functions
				function fnNameUPCheck = 
				(
					reports = #()
					selarr 	= selection as array 
	
					-- For each item in selection, examine it
					for sel in selarr do 
					(
						newReport = rigBuddy.lib.compareUserPropsNodeName sel
						append reports newReport
					)
	
					rbi = rigBuddy.interfaces
					rbi.lvSetColumns	lvMain #("","Match","Current Name","Stored Name") #(22,60,250,250)	
					rows = #()
	
					for report in reports do 
					(
						-- Make a new List view Item
						li=dotNetObject "System.Windows.Forms.ListViewItem" ""
						li.UseItemStyleForSubItems = false					
						li.subitems.add ( report.pass as string )
						li.subitems.add ( report.currentVal )
						li.subitems.add ( report.storedVal )
	
						append rows li
					)
	
					-- Add the rows
					lvMain.items.addRange rows
	
					rigBuddy.uiMain.labelStatus.text = ( ( rows.count as string ) + " names compared")
				)
	
				function fnNameUPSet =
				(
					selArr = (selection as array)
					for sel in selArr do
					(
						rigBuddy.lib.setUserPropsNodeName sel
					)
	
					rigBuddy.uiMain.labelStatus.text = ( ( selArr.count as string ) + " names stored")
					)
		
					function fnNameUPGet =
					(
					selArr = (selection as array)
					for sel in selArr do
					(
						rigBuddy.lib.restoreUserPropsNodeName sel
					)
	
					rigBuddy.uiMain.labelStatus.text = ( ( selArr.count as string ) + " names fetched")
				)
	
				function fnNameAutoCheck = 
				(
					rigBuddy.report = ( rbLib.namesMakeUniqueCollect ( selection as array ) )
	
					rbi = rigBuddy.interfaces
					rbi.lvSetColumns	lvMain #("","Animhandle","Current Name","New Name") #(22,80,240,240)	
	
					-- combine all the reports
					updates = #()
					join updates rigBuddy.report.updateNone
					join updates rigBuddy.report.updateAppend
					join updates rigBuddy.report.updateRebuild
	
					-- Populate the rows
					rows = #()
	
					for udate in updates do 
					(
						-- Make a new List view Item
						li=dotNetObject "System.Windows.Forms.ListViewItem" ""
						li.UseItemStyleForSubItems = false
						
						obj = (getAnimByHandle udate.handle )
						li.subitems.add ( ( udate.handle as string ) )
						li.subitems.add ( obj.name )
						li.subitems.add ( udate.newName )
	
						append rows li
					)
	
					-- Add the rows
					lvMain.items.addRange rows
	
					-- Update the UI with what has happened
					if updates.count >= 1 then
					(
						btnNameAutoApply.enabled = true
						rigBuddy.uiMain.labelStatus.text = ( ( ( updates.count ) as string ) + " renames prepared" )
					)
					else
					(
						btnNameAutoApply.enabled = false
						rigBuddy.uiMain.labelStatus.text = ( "No items to rename")
					)
				)
	
				function fnNameAutoApply = 
				(
					rbLib.namesMakeUnique rigBuddy.report
	
					updates = #()
					join updates rigBuddy.report.updateNone
					join updates rigBuddy.report.updateAppend
					join updates rigBuddy.report.updateRebuild
	
					btnNameAutoApply.enabled = false
					rigBuddy.uiMain.labelStatus.text = ( ( ( updates.count ) as string ) + " objects renamed ")
				)
	
				function fnNameDupeSelect = 
				(
					select (collect3dLib.collectByAnimhandle rigBuddy.report.duplicateNamesIds)
					rigBuddy.uiMain.labelStatus.text = ( ( ( rigBuddy.report.duplicateNamesIds.count ) as string ) + " dupilcates selected ")
				)
	
				function fnNameDupeCheck = 
				(
					-- run the duplicate check function
					rigBuddy.report = ( rbLib.namesCheckForDuplicates ( selection as array ) )
	
					-- Set the list view columns
					rbi = rigBuddy.interfaces
					rbi.lvSetColumns	lvMain #("","Animhandle","Name") #(22,80,480)
	
					-- Populate the rows
					rows = #()
	
					for id in rigBuddy.report.duplicateNamesIds do 
					(
						-- Make a new List view Item
						li=dotNetObject "System.Windows.Forms.ListViewItem" ""
						li.UseItemStyleForSubItems = false
						
						li.subitems.add ( ( id as string ) )
						obj = (getAnimByHandle id )
						li.subitems.add ( obj.name )
	
						append rows li
					)
	
					-- Add the rows
					lvMain.items.addRange rows
	
					-- Update the UI with what has happened
					if rigBuddy.report.pass == false then
					(
						btnNameDupeSelect.enabled = true
						rigBuddy.uiMain.labelStatus.text = ( ( ( rigBuddy.report.duplicateNamesIds.count ) as string ) + " dupilcates found ")
					)
					if rigBuddy.report.pass == true then
					(
						btnNameDupeSelect.enabled = false
						rigBuddy.uiMain.labelStatus.text = ( "No dupilcates found ")
					)
				)
	
				function fnNamePrefixDo arg_mode = 
				(
					dataSet = rigBuddy.report.protoplastsData
	
					operands = #()
	
					for data in dataSet do 
					(
						for id in data.failNamesIds do 
						(
							curAnim = ( getAnimByHandle id )
							append operands curAnim
	
							-- If in apply mode, change the name
							if arg_mode == "apply" then ( curAnim.name = ( data.nameTag + curAnim.name ) )
						)
					)
	
					-- if in select mode, select the objects
					if arg_mode == "select" then
					(
						select operands
						rigBuddy.uiMain.labelStatus.text = ( ( operands.count as string ) + " objects selected ")
					)
	
					-- If in apply mode, clear out list view, disable buttons
					if arg_mode == "apply" then
					(
						-- Set the list view columns
	
						btnNamePrefixSelect.enabled = false
						btnNamePrefixApply.enabled = false
						lvMain.items.clear()
	
						rigBuddy.uiMain.labelStatus.text = ( ( operands.count as string ) + " objects renamed ")
	
					)
				)
	
				function fnNamePrefixCheck =
				(
					rigBuddy.report = ( rbLib.namesMakeValidPrefixesCollect ( selection as array ) )
					print rigBuddy.report
	
					-- Set the list view columns
					rbi = rigBuddy.interfaces
					rbi.lvSetColumns	lvMain #("","Tag","Current Name","New Name") #(22,60,250,250)
	
					-- Populate the rows
					failIds = #()
					rows 	= #()
	
					dataSet = rigBuddy.report.protoplastsData
	
					for data in dataSet do 
					(
						for id in data.failNamesIds do 
						(
						
							li=dotNetObject "System.Windows.Forms.ListViewItem" ""
							li.UseItemStyleForSubItems = false
		
							li.subitems.add data.nameTag 
							curAnim = ( getAnimByHandle id )
							li.subitems.add ( curAnim.name )
							li.subitems.add ( data.nameTag + curAnim.name )
	
							append rows li
						)
					)
	
					-- Add the rows
					lvMain.items.addRange rows
	
					-- enable/disale dependent buttons
					if dataSet.count >= 1 then 
					(
						btnNamePrefixSelect.enabled = true
						btnNamePrefixApply.enabled = true
	
					)
					else 
					(
						btnNamePrefixSelect.enabled = false
						btnNamePrefixApply.enabled = false
					)
	
					rigBuddy.uiMain.labelStatus.text = ( ( rows.count as string ) + " object(s) found without matching tag ")
				)

			-- UserProps Functions
--- <<<<<<< Updated upstream
				function fnUserPropsGetAll =
				(
				)
-- =======
				
				function fnUserPropsClearAll =
				(
					selArr = ( selection as array )
					rigBuddy.report = rigBuddy.lib.userPropClearAll selArr

					rigBuddy.uiMain.labelStatus.text = ( selArr.count as string + " objects user properties were cleared" )	
				)
				
				function fnUserPropsNameCheckSet =
				(
					rigBuddy.report = rigBuddy.lib.userPropCheck selArr "NodeName"
					--rigBuddy.report = rigBuddy.lib.getUserPropsNodeName selArr "NodeName"

					rbi = rigBuddy.interfaces
					rbi.lvSetColumns	lvMain #("","Stored","Animhandle","Name") #(22,50,80,350)	
					rows = #()		

					for node in rigBuddy.report.failIds do 
					(
						li=dotNetObject "System.Windows.Forms.ListViewItem" ""
						li.UseItemStyleForSubItems = false
						li.subitems.add ( "False" )
						curNode = getAnimByHandle node
						li.subitems.add ( node as string  )
						li.subitems.add ( curNode.name  )
						append rows li
					)

					-- Update the LV
					lvMain.items.addRange rows

					-- turn on the select button, if there are any failed objects
					if rigBuddy.report.failIds.count >= 1 then ( btnUserPropsNameCheckSetSel.enabled = true )

					-- Update the status
					rigBuddy.uiMain.labelStatus.text = ( rigBuddy.report.failIds.count as string + " Nodes without 'NodeName' stored" )	
				)

				function fnUserPropsNameCheckSetSel = 
				(
					curNodes = rigBuddy.report.failIds 
					selList = #()

					for node in curNodes do 
					(
						curNode = ( getAnimByHandle node )
						append selList curNode
					)

					select selList
					rigBuddy.uiMain.labelStatus.text = ( selList.count as string + " nodes selected" )	
				)

				function fnUserPropsNameCheckMatch =
				(
					results = #()
					selArr = ( selection as array )

					for sel in selArr do 
					(
						result = rigBuddy.lib.compareUserPropsNodeName sel
						append results result 
					)

					rigBuddy.report = results

					failReports = #()
					for report in rigBuddy.report do 
					(
						if report.pass == false then 
						(
							append failReports report
						)
					)

					-- TODO: This looks like it was in progress lol

					print rigBuddy.report

					print "-- fails"
					print failReports
				)

				function fnUserPropsNameCheckMatchSel = 
				(

				)
				
				-- TOD: was working on this
				function fnUserPropsNameGet arg_Verbose =
				(
					selArr = ( selection as array )

					for node in selArr do 
					(
						rigBuddy.lib.getUserPropsNodeName node
					)
				)
				
				function fnUserPropsNameSet arg_Verbose =
				(
					-- Setup some variables
					selArr = ( selection as array )
					curFloat = 0.000
					
					if arg_Verbose then 
					(
						-- Set the list view
						rbi = rigBuddy.interfaces
						rbi.lvSetColumns	lvMain #("","Stored","Stored 'NodeName'") #(22,260,260)	
						rows = #()		
					)

					-- For each node, seth the property
					for node in selArr do 
					(
						curFloat += 1.000 															-- increment the progressbar float val
						result = rigBuddy.lib.setUserPropsNodeName node								-- Set the user property
						rigBuddy.uiMain.progBar1.value = ( ( curFloat / selArr.count ) * 100 ) 		-- Update the progressbar

						if arg_Verbose then 
						(
							li=dotNetObject "System.Windows.Forms.ListViewItem" ""
							li.UseItemStyleForSubItems = false					
							li.subitems.add ( node.name  )
							li.subitems.add ( result as string )
							append rows li
						)
					)

					if arg_Verbose then 
					(
						-- Update the LV
						lvMain.items.addRange rows
					)

					-- Update the status
					rigBuddy.uiMain.labelStatus.text = ( selArr.count as string + " Node names stored" )	
				)
				
				function fnUserPropsNameClear =
				(
				)

				function fnUserPropsParentCheckSet =
-- >>>>>>> Stashed changes
				(
				)
				
				function fnUserPropsSetAll =
				(
				)
				
				function fnUserPropsNameCheck =
				(

					-- Setup some variables
					selArr = ( selection as array )
					curFloat = 0.000
					
					if arg_Verbose then 
					(
						-- Set the list view
						rbi = rigBuddy.interfaces
						rbi.lvSetColumns	lvMain #("","Stored","'Parent name'","'Parent Animhandle'") #(22,150,150,150)	
						rows = #()		
					)

					-- For each node, seth the property
					for node in selArr do 
					(
						curFloat += 1.000 															-- increment the progressbar float val
						result = rigBuddy.lib.setUserPropsRigParent node	
						rigBuddy.uiMain.progBar1.value = ( ( curFloat / selArr.count ) * 100 ) 		-- Update the progressbar

						if arg_Verbose then 
						(
							li=dotNetObject "System.Windows.Forms.ListViewItem" ""
							li.UseItemStyleForSubItems = false
							li.subitems.add ( "true"  )
							li.subitems.add ( result.NodeParentName  )
							li.subitems.add ( result.NodeParentHandle as string )
							append rows li
						)
					)

					if arg_Verbose then 
					(
						-- Update the LV
						lvMain.items.addRange rows
					)

					-- Update the status
					rigBuddy.uiMain.labelStatus.text = ( selArr.count as string + " Node Parent stored" )	
				)
				
--				function fnUserPropsNameGet =
--				(
--				)
				
--				function fnUserPropsNameSet =
--				(
--				)
				
-- <<<<<<< Updated upstream
--				function fnUserPropsParentCheck =
--				(
--				)
--
-- =======
				function fnUserPropsWirecolorSet arg_Verbose =
				(

					-- Setup some variables
					selArr = ( selection as array )
					curFloat = 0.000
					
					if arg_Verbose then 
					(
						-- Set the list view
						rbi = rigBuddy.interfaces
						rbi.lvSetColumns	lvMain #("","Stored","'Stored Wirecolor'") #(22,250,250)	
						rows = #()		
					)

					-- For each node, seth the property
					for node in selArr do 
					(
						curFloat += 1.000 															-- increment the progressbar float val
						result = rigBuddy.lib.setUserPropsWirecolor node	
						rigBuddy.uiMain.progBar1.value = ( ( curFloat / selArr.count ) * 100 ) 		-- Update the progressbar

						if arg_Verbose then 
						(
							li=dotNetObject "System.Windows.Forms.ListViewItem" ""
							li.UseItemStyleForSubItems = false
							li.subitems.add ( "true"  )
							li.subitems.add ( result as string )
							append rows li
						)
					)

					if arg_Verbose then 
					(
						-- Update the LV
						lvMain.items.addRange rows
					)

					-- Update the status
					rigBuddy.uiMain.labelStatus.text = ( selArr.count as string + " Node Wirecolors stored" )	
				)

				function fnUserPropsWirecolorClear =
-- >>>>>>> Stashed changes
				(
				)
				
				function fnUserPropsParentGet arg_Verbose =
				(
				)
				
				function fnUserPropsParentSet arg_Verbose =
				(

					-- Setup some variables
					selArr = ( selection as array )
					curFloat = 0.000
					
					if arg_Verbose then 
					(
						-- Set the list view
						rbi = rigBuddy.interfaces
						rbi.lvSetColumns	lvMain #("","Stored","'Parsed Date'","'DateTime'") #(22,150,150,150)	
						rows = #()		
					)

					-- For each node, seth the property
					for node in selArr do 
					(
						curFloat += 1.000 															-- increment the progressbar float val
						result = rigBuddy.lib.setUserPropsNodeDate node	
						rigBuddy.uiMain.progBar1.value = ( ( curFloat / selArr.count ) * 100 ) 		-- Update the progressbar

						if arg_Verbose then 
						(
							li=dotNetObject "System.Windows.Forms.ListViewItem" ""
							li.UseItemStyleForSubItems = false
							li.subitems.add ( "true"  )
							li.subitems.add ( result.NodePublishDateParsed as string )
							li.subitems.add ( result.NodePublishDate as string )
							append rows li
						)
					)

					if arg_Verbose then 
					(
						-- Update the LV
						lvMain.items.addRange rows
					)

					-- Update the status
					rigBuddy.uiMain.labelStatus.text = ( selArr.count as string + " Node Wirecolors stored" )	

				)
				
				function fnUserPropsWirecolorCheck =
				(
				)
				
				function fnUserPropsWirecolorGet arg_Verbose =
				(
				)
				
--				function fnUserPropsWirecolorSet =
--				(
--				)
				
				function fnUserPropsDateGet arg_Verbose =
				(
				)
				
				function fnUserPropsDateSet arg_Verbose =
				(
				)

			-- Rigging event handlers
				on btnRigScaleCheck 			pressed do ( rigBuddy.interfaces.uiMainModeReset(); fnRigScaleCheck() )
				on btnRigScaleSelect 			pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnRigScaleSelect() ) )
				on btnRigHeirReparent 			pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnRigHeirReparent() ) )
				on btnRigHelperHypot 			pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnRigHelperHypot() ) )
				on btnRigHelperRay 				pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnRigHelperRay() ) )

			-- Baking event handlers
				on btnBakePCCheck 				pressed do ( rigBuddy.interfaces.uiMainModeReset(); fnBakePCCheck() )
				on btnBakePCSelect 				pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnBakePCSelect() ) )
				on btnBakePCAdd 				pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnBakePCAdd() ) )
				on btnBakePCSwapSkin			pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnBakePCSwapSkin() ) )

			-- Skinning event handers
				on btnSkinCheck 				pressed do ( rigBuddy.interfaces.uiMainModeReset(); fnSkinCheck () )
				on btnSkinSelect 				pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnSkinSelect () ) )
				on btnSkinSafeMods 				pressed do ( rigBuddy.interfaces.uiMainModeReset(); fnSkinSafeMods () )
				on btnSkinSafeModsSelect		pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnSkinSafeModsSelect() ) )
				on btnSkinDeformReset 			pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnSkinDeformReset() ) )
				on btnSkinPivotReset 			pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnSkinPivotReset() ) )
				on btnSkinwrapStealDo 			pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnSkinwrapStealDo() ) )
				on btnSkinParent 				pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnSkinParent() ) )
				on btnMeshClean					pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnMeshClean() ) )
				on btnSkinProxyDo				pressed do ( rigBuddy.interfaces.uiMainModeReset(); fnSkinProxyDo() )

			-- Naming event handlers
				on btnNameDupeCheck 			pressed do ( rigBuddy.interfaces.uiMainModeReset(); fnNameDupeCheck() )
				on btnNameDupeSelect 			pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnNameDupeSelect() ) )
				on btnNameAutoCheck 			pressed do ( rigBuddy.interfaces.uiMainModeReset(); fnNameAutoCheck() )
				on btnNameAutoApply 			pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnNameAutoApply() ) )
				on btnNamePrefixCheck 			pressed do ( rigBuddy.interfaces.uiMainModeReset(); fnNamePrefixCheck() )
				on btnNamePrefixSelect 			pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnNamePrefixDo "select" ) )
				on btnNamePrefixApply 			pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnNamePrefixDo "apply" ) )
				on btnNameUPCheck				pressed do ( rigBuddy.interfaces.uiMainModeReset(); fnNameUPCheck() )
				on btnNameUPGet					pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnNameUPGet() ) )
				on btnNameUPSet					pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnNameUPSet() ) )

			-- UserProps event handlers
				on btnUserPropsGetAll 			pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnUserPropsGetAll() ) )
				on btnUserPropsSetAll 			pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnUserPropsSetAll() ) )
				on btnUserPropsNameCheck		pressed do ( rigBuddy.interfaces.uiMainModeReset(); fnUserPropsNameCheck() )
				on btnUserPropsNameGet 			pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnUserPropsNameGet true ) )
				on btnUserPropsNameSet 			pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnUserPropsNameSet true ) )
				on btnUserPropsParentCheck 		pressed do ( rigBuddy.interfaces.uiMainModeReset(); fnUserPropsParentCheck() )
				on btnUserPropsParentGet 		pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnUserPropsParentGet true ) )
				on btnUserPropsParentSet 		pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnUserPropsParentSet true ) )
				on btnUserPropsWirecolorCheck 	pressed do ( rigBuddy.interfaces.uiMainModeReset(); fnUserPropsWirecolorCheck() )
				on btnUserPropsWirecolorGet 	pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnUserPropsWirecolorGet true ) )
				on btnUserPropsWirecolorSet 	pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnUserPropsWirecolorSet true ) )
				on btnUserPropsDateGet 			pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnUserPropsDateGet true ) )
				on btnUserPropsDateSet 			pressed do ( rigBuddy.interfaces.uiMainModeReset(); with undo on ( fnUserPropsDateSet true ) )

			-- UI Event Handlers
				-- Initalize the interface when it opens, mostly storing UI items for visibility operations later
				on uiMainRollout open do
				(
					-- Shorten some names
					rbi 	= rigBuddy.interfaces
					rbuimi 	= rigBuddy.uiMainItems
	
					-- Store each of the ui items into their appropriate class
					curLi = rigBuddy.uiMainItems.uiBaking
					append curLi labBaking
					append curLi labBakePC
					append curLi btnBakePCCheck
					append curLi btnBakePCSelect
					append curLi btnBakePCAdd
					append curLi btnBakePCSwapSkin
					append curLi labBakeTFB
					append curLi labBakePCB
					append curLi labBakeBNS
					
					curLi = rigBuddy.uiMainItems.uiMeshes 
					append curLi labMeshes
	
					curLi = rigBuddy.uiMainItems.uiSkinning
					append curLi labSkinning
					append curLi labSkinModChecks		
					append curLi btnSkinCheck 			
					append curLi btnSkinSelect 			
					append curLi btnSkinSafeMods 		
					append curLi btnSkinSafeModsSelect 	
					append curLi labSkinModOp			
					append curLi btnSkinDeformReset 		
					append curLi btnSkinPivotReset 		
					append curLi labSkinBinding			
					append curLi btnSkinwrapStealDo 		
					append curLi btnSkinParent 			
					append curLi labSkinProxy
					append curLi labMeshClean
					append curLi btnMeshClean		
					append curLi btnSkinProxyDo			
			 		append curLi spnPolycount 			
	
					curLi = rigBuddy.uiMainItems.uiRigging 		
					append curLi labRigging
					append curLi labRigScale		
					append curLi btnRigScaleCheck 
					append curLi btnRigScaleSelect 
					append curLi labRigHeirarchy	
					append curLi btnRigHeirReparent 
					append curLi labRigHelpers	
					append curLi btnRigHelperHypot 
					append curLi btnRigHelperRay 
	
					curLi = rigBuddy.uiMainItems.uiNaming
					append curLi labNaming 		
					append curLi btnNameDupeCheck
					append curLi btnNameDupeSelect
					append curLi btnNameAutoCheck
					append curLi btnNameAutoApply
					append curLi btnNamePrefixCheck 
					append curLi btnNamePrefixSelect
					append curLi btnNamePrefixApply 
					append curLi btnNameUPCheck
					append curLi btnNameUPGet
					append curLi btnNameUPSet
	
					curLi = rigBuddy.uiMainItems.uiUserProperties
					append curLi labUserProps
					append curLi btnUserPropsGetAll
					append curLi btnUserPropsSetAll
					append curLi btnUserPropsClearAll
					append curLi labUserPropsName
					append curLi btnUserPropsNameCheck
					append curLi btnUserPropsNameGet
					append curLi btnUserPropsNameSet
					append curLi btnUserPropsNameClear
					append curLi labUserPropsParent				
					append curLi btnUserPropsParentCheckSet 		
					append curLi btnUserPropsParentCheckSetSel 	
					append curLi btnUserPropsParentCheckMatch	
					append curLi btnUserPropsParentCheckMatchSel 
					append curLi btnUserPropsParentGet 			
					append curLi btnUserPropsParentSet 			
					append curLi btnUserPropsParentClear			
					append curLi labUserPropsWirecolor			
					append curLi btnUserPropsWirecolorCheckSet 	
					append curLi btnUserPropsWirecolorCheckSetSel
					append curLi btnUserPropsWirecolorCheckMatch	
					append curLi btnUserPropsWirecolorCheckMatchSel 
					append curLi btnUserPropsWirecolorGet 		
					append curLi btnUserPropsWirecolorSet 		
					append curLi btnUserPropsWirecolorClear 		
					append curLi labUserPropsDate				
					append curLi btnUserPropsDateGet 			
					append curLi btnUserPropsDateSet 			
					append curLi btnUserPropsDateClear 				
--					append curLi labUserProps
--					append curLi btnUserPropsGetAll
--					append curLi btnUserPropsSetAll
--					append curLi btnUserPropsClearAll
--					append curLi labUserPropsName
--					append curLi btnUserPropsNameCheck
--					append curLi btnUserPropsNameGet
--					append curLi btnUserPropsNameSet
--					append curLi btnUserPropsNameClear
--					append curLi labUserPropsParent
--					append curLi btnUserPropsParentCheck
--					append curLi btnUserPropsParentGet
--					append curLi btnUserPropsParentSet
--					append curLi btnUserPropsParentClear
--					append curLi labUserPropsWirecolor
--					append curLi btnUserPropsWirecolorCheck
--					append curLi btnUserPropsWirecolorGet
--					append curLi btnUserPropsWirecolorSet
--					append curLi btnUserPropsWirecolorClear
--					append curLi labUserPropsDate
--					append curLi btnUserPropsDateGet
--					append curLi btnUserPropsDateSet
--					append curLi btnUserPropsDateClear
	
					-- Initialize the List View
					rbi.lvSetproperties lvMain
					rbi.lvSetColumns	lvMain #("","") #(20,550)
	
					labelStatus.text = "Status: Ready"
					rigBuddy.interfaces.uiMainModeReset()
	
					-- TODO: Remove this stuff, because it is for debug mode
					-- Initialize the toolset to the default mode
					-- rigBuddy.interfaces.uiMainMode "Skinning"
					 rigBuddy.interfaces.uiMainMode "User Properties"
					-- rigBuddy.interfaces.uiMainMode "Baking"
					-- rigBuddy.interfaces.uiMainMode "Rigging"
				)
	
	 			-- Modify the UI items positions, when the window is resized
				on uiMainRollout resized arg do
				(
					if uiMainRollout.height < 120 then(uiMainRollout.height = 120)else()
					if uiMainRollout.height > 1000 then(uiMainRollout.height = 1000)else()
	
	 				progBar1.pos 					= [5,(uiMainRollout.height - 30 )]					
	 				progBar2.pos 					= [5,(uiMainRollout.height - 25 )]		
					uiMainRollout.lvMain.height 	= (uiMainRollout.height - 35)
	  				labelStatus.pos 				= [10,(uiMainRollout.height - 15)]
				)
		)

		-- Construct the Main UI Rollout and return it
		createDialog uiMainRollout lockHeight:false lockWidth:true menu:rc_MainMenu style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox)	
		
		-- Set some things for the UI
		--SetDialogPos uiMainRollout [500,300]
		--uiMainRollout.height = 250
		uiMainRollout.height = 400
		SetDialogPos uiMainRollout [1000,150]
		-- SetDialogPos uiMainRollout [1337,2080]

		return uiMainRollout
	),

	-- Function to create the main ui object
	function uiAboutInit  =
	(

		curVerNumStr = rigBuddy.lib.verNumStr()
		
		rollout uiAboutRollout ( "About" ) width:350 height:100
		(
			dotNetControl rtbAbout "system.windows.forms.RichTextBox" height:95 width:345 pos:[ 3 , 3 ]

			function rtbAboutUpdate =
			(
				-- bring in external text, assigned to a variable called aboutText
				filein "aboutText.ms"

				curVerNumStr2 = rigBuddy.lib.verNumStr()

				concatStr = ("Version Number: " + curVerNumStr2 + "\n\n" + aboutText )

				rtbAbout.BackColor 		= (dotNetClass "System.Drawing.Color").FromArgb 68 68 68
				rtbAbout.Multiline 		= true
				rtbAbout.ReadOnly 		= true
				rtbAbout.ForeColor 		= (dotNetClass "System.Drawing.Color").FromArgb 200 200 200
				rtbAbout.WordWrap 		= on
				rtbAbout.ScrollBars 	= rtbAbout.ScrollBars.Both
				rtbAbout.appendText ( concatStr )
				rtbAbout.update()

			)
			on uiAboutRollout open do ( rtbAboutUpdate() )

		)

		createDialog uiAboutRollout lockHeight:true lockWidth:true style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox)	

		return uiAboutRollout
	),

	ender = undefined

)		


debug = false

if debug then
(
	clearListener()
	try( destroyDialog rigBuddy.uiMain )catch()
	try( destroyDialog rigBuddy.uiAbout )catch()

	rigBuddy.interfaces 	= rbInterfacesStruct()
	rigBuddy.uiMain 		= rigBuddy.interfaces.uiMainInit()
	--rigBuddy.uiAbout 		= rigBuddy.interfaces.uiAboutInit()
)

