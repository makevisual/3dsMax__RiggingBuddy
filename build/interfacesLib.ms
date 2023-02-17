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

	-- Sets the width of the list view columns, and their names
	function lvSetColumns arg_LV arg_columns arg_widths =
	(
		arg_LV.clear()

		for i in 1 to arg_columns.count do 
		(
			arg_lv.columns.add arg_columns[i] arg_widths[i]
		)
	),

	function uiMainMode arg_mode =
	(
		
		rbuimi 		= rigBuddy.uiMainItems 	-- Shorten the var
		allItems 	= #()					-- start with a clean list

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
			rigBuddy.uiMain.height = 200
		)
		if arg_mode == "Baking"	then
		(
			for item in rbuimi.uiBaking	do ( try( item.visible = true )catch() )
			rigBuddy.uiMain.height = 200
		)
		if arg_mode == "Skinning" then
		(
			for item in rbuimi.uiSkinning 		do ( try( item.visible = true )catch() )
			rigBuddy.uiMain.height = 200
		)
		if arg_mode == "Rigging" then
		(
			for item in rbuimi.uiRigging 		do ( try( item.visible = true )catch() )
			rigBuddy.uiMain.height = 300
		)
		if arg_mode == "Naming" then
		(
			for item in rbuimi.uiNaming do ( try( item.visible = true )catch() )
			rigBuddy.uiMain.height = 300
		)
		if arg_mode == "User Properties" then
		(
			for item in rbuimi.uiUserProperties 	do ( try( item.visible = true )catch() )
			rigBuddy.uiMain.height = 300
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
				menuItem	miMeshes			"Meshes"
				menuItem	miBaking			"Baking"
				menuItem	miSkinning			"Skinning"
				menuItem	miNaming			"Naming"
				menuItem	miUserProperties	"User Properties"
			)	
			subMenu		"Utilities"
			(
				menuItem	miAssetInspector	"Asset Inspector"
			)	
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
			progressbar 	progBar1 					width:990 						pos:[0,0] 	height:8 value:80 color:[0,60,90]

			label 			labBaking					"Baking Tools"						pos:[10,10]	align:#left	
				button 			btnBakeAndSave 			"Bake and Save" 				align:#left

			label 			labMeshes					"Mesh Tools"						pos:[10,10]	align:#left
			label 			labRigging					"Rigging Tools"						pos:[10,10]	align:#left	
			label 			labSkinning					"Skinning Tools"					pos:[10,10]	align:#left	

				-- button 			btn

			label 			labNaming					"Naming Tools"						pos:[10,10]	align:#left	

				button 			btnNameDupeCheck 		"Check selection for duplicate names "						pos:[10,30]	 	align:#left	width:300
				button 			btnNameDupeSelect 		"Select "													pos:[310,30] 	align:#left	width:100 enabled:false

				button 			btnNameAutoCheck 		"Preview Auto Generated Unique name on selection "			pos:[10,60] 	align:#left	width:300 
				button 			btnNameAutoApply 		"Apply "													pos:[310,60] 	align:#left	width:100 enabled:false

				button 			btnNamePrefixCheck 		"Check hierarchy prefix tags against Global "				pos:[10,90]		align:#left	width:300
				button 			btnNamePrefixSelect 	"Select "													pos:[310,90] 	align:#left	width:100 enabled:false
				button 			btnNamePrefixApply 		"Apply "													pos:[310,112] 	align:#left	width:100 enabled:false

				button  		btnNameUPCheck 			"Check selection for stored name" 							pos:[10,140] align:#left	width:400
				button  		btnNameUPGet 			"Fetch stored name" 										pos:[10,162] align:#left	width:200
				button  		btnNameUPSet 			"Store current name" 										pos:[210,162] align:#left	width:200

			label 			labUserProps		"User Property Tools"				pos:[10,10]	align:#left

				button  		btnUserPropsGetAll 			"Fetch all" 											pos:[10,30] align:#left		width:132
				button  		btnUserPropsSetAll 			"Store all" 											pos:[145,30] align:#left	width:132
				button  		btnUserPropsClearAll 		"Clear all" 											pos:[280,30] align:#left	width:132

				button  		btnUserPropsNameCheck 		"Check selections stored name" 							pos:[10,60] align:#left		width:400
				button  		btnUserPropsNameGet 		"Fetch stored name" 									pos:[10,82] align:#left		width:132
				button  		btnUserPropsNameSet 		"Store current name" 									pos:[210,82] align:#left	width:132

				button  		btnUserPropsParentCheck 	"Check selections stored parent" 						pos:[10,110] align:#left	width:400
				button  		btnUserPropsParentGet 		"Restore parent" 										pos:[10,132] align:#left	width:132
				button  		btnUserPropsParentSet 		"Store parent" 											pos:[210,132] align:#left	width:132

				button  		btnUserPropsWirecolorCheck 	"Check selections stored wirecolor" 					pos:[10,160] align:#left	width:400
				button  		btnUserPropsWirecolorGet 	"Restore wirecolor" 									pos:[10,182] align:#left	width:132
				button  		btnUserPropsWirecolorSet 	"Store wirecolor" 										pos:[210,182] align:#left	width:132

				button  		btnUserPropsDateGet 		"Check publish date" 									pos:[10,212] align:#left	width:132
				button  		btnUserPropsDateSet 		"Store current date" 									pos:[210,212] align:#left	width:132

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

			on uiMainRollout open do
			(
				-- Shorten some names
				rbi 	= rigBuddy.interfaces
				rbuimi 	= rigBuddy.uiMainItems

				-- Store each of the ui items into their appropriate class
				curLi = rigBuddy.uiMainItems.uiBaking
				append curLi labBaking
				append curLi btnBakeAndSave
				
				curLi = rigBuddy.uiMainItems.uiMeshes 
				append curLi labMeshes

				curLi = rigBuddy.uiMainItems.uiSkinning
				append curLi labSkinning

				curLi = rigBuddy.uiMainItems.uiRigging 		
				append curLi labRigging

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
				append curLi btnUserPropsNameCheck
				append curLi btnUserPropsNameGet 
				append curLi btnUserPropsNameSet 
				append curLi btnUserPropsParentCheck 
				append curLi btnUserPropsParentGet 
				append curLi btnUserPropsParentSet 
				append curLi btnUserPropsWirecolorCheck 
				append curLi btnUserPropsWirecolorGet 
				append curLi btnUserPropsWirecolorSet 
				append curLi btnUserPropsDateGet 
				append curLi btnUserPropsDateSet 

				-- Initialize the List View
				rbi.lvSetproperties lvMain
				rbi.lvSetColumns	lvMain #("","") #(20,475)

				labelStatus.text = "Status: Ready"

				-- TODO: Remove this stuff, because it is for debug mode
				-- Initialize the toolset to the default mode
				-- rigBuddy.interfaces.uiMainMode "Skinning"
				rigBuddy.interfaces.uiMainMode "User Properties"
			)

 			-- Modify the UI items positions, when the window is resized
			on uiMainRollout resized arg do
			(
				if uiMainRollout.height < 120 then(uiMainRollout.height = 120)else()
				if uiMainRollout.height > 1000 then(uiMainRollout.height = 1000)else()

 				progBar1.pos 					= [5,(uiMainRollout.height - 25 )]					
				uiMainRollout.lvMain.height 	= (uiMainRollout.height - 30)
  				labelStatus.pos 				= [10,(uiMainRollout.height - 15)]
			)

			-- Naming event handlers
			on btnNameDupeCheck 	pressed do ( fnNameDupeCheck() )
			on btnNameDupeSelect 	pressed do ( fnNameDupeSelect() )
			on btnNameAutoCheck 	pressed do ( fnNameAutoCheck() )
			on btnNameAutoApply 	pressed do ( fnNameAutoApply() )
			on btnNamePrefixCheck 	pressed do ( fnNamePrefixCheck() )
			on btnNamePrefixSelect 	pressed do ( fnNamePrefixDo "select" )
			on btnNamePrefixApply 	pressed do ( fnNamePrefixDo "apply" )
			on btnNameUPCheck		pressed do ( fnNameUPCheck() )
			on btnNameUPGet			pressed do ( fnNameUPGet() )
			on btnNameUPSet			pressed do ( fnNameUPSet() )

			-- UserProps event handlers
			on btnUserPropsGetAll 			pressed do ()
			on btnUserPropsSetAll 			pressed do ()
			on btnUserPropsNameCheck		pressed do ()
			on btnUserPropsNameGet 			pressed do ()
			on btnUserPropsNameSet 			pressed do ()
			on btnUserPropsParentCheck 		pressed do ()
			on btnUserPropsParentGet 		pressed do ()
			on btnUserPropsParentSet 		pressed do ()
			on btnUserPropsWirecolorCheck 	pressed do ()
			on btnUserPropsWirecolorGet 	pressed do ()
			on btnUserPropsWirecolorSet 	pressed do ()
			on btnUserPropsDateGet 			pressed do ()
			on btnUserPropsDateSet 			pressed do ()
		)

		-- Construct the Main UI Rollout and return it
		createDialog uiMainRollout lockHeight:false lockWidth:true menu:rc_MainMenu style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox)	
		
		-- Set some things for the UI
		--SetDialogPos uiMainRollout [500,300]
		uiMainRollout.height = 300
		--SetDialogPos uiMainRollout [1000,150]
		SetDialogPos uiMainRollout [1337,2080]

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


debug = true

if debug then
(
	clearListener()
	try( destroyDialog rigBuddy.uiMain )catch()
	try( destroyDialog rigBuddy.uiAbout )catch()

	rigBuddy.interfaces 	= rbInterfacesStruct()
	rigBuddy.uiMain 		= rigBuddy.interfaces.uiMainInit()
	--rigBuddy.uiAbout 		= rigBuddy.interfaces.uiAboutInit()
)

