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

		-- Turn on item if it matches designation
		if arg_mode == "Meshes" 			then ( for item in rbuimi.uiMeshes 			do ( try( item.visible = true )catch() ) )
		if arg_mode == "Baking" 			then ( for item in rbuimi.uiBaking 			do ( try( item.visible = true )catch() ) )
		if arg_mode == "Skinning" 			then ( for item in rbuimi.uiSkinning 		do ( try( item.visible = true )catch() ) )
		if arg_mode == "Rigging" 			then ( for item in rbuimi.uiRigging 		do ( try( item.visible = true )catch() ) )
		if arg_mode == "Naming" 			then ( for item in rbuimi.uiNaming 			do ( try( item.visible = true )catch() ) )
		if arg_mode == "User Properties" 	then ( for item in rbuimi.uiUserProperties 	do ( try( item.visible = true )catch() ) )

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
			
			--dotNetControl 	lvMain 				"system.windows.forms.listView" pos:[250,0] height:200 width:749					
			dotNetControl 	lvMain 				"system.windows.forms.listView" pos:[420,0] height:200 width:619					
			label 			labelProgress		"Status: initializing"			pos:[0,0]	align:#left	
			progressbar 	progBar1 			width:990 						pos:[0,0] 	height:8 value:80 color:[0,60,90]

			label 			labBaking			"Baking Tools"						pos:[10,10]	align:#left	
				button 			btnBakeAndSave 		"Bake and Save" 				align:#left

			label 			labMeshes			"Mesh Tools"						pos:[10,10]	align:#left
			label 			labSkinning			"Skinning Tools"					pos:[10,10]	align:#left	
			label 			labRigging			"Rigging Tools"						pos:[10,10]	align:#left	

			label 			labNaming			"Naming Tools"						pos:[10,10]	align:#left	
				button 			btnNameDupeCheck 	"Check selection for duplicate names "	pos:[10,30]	 align:#left	width:200
				button 			btnNameDupeApply 	"Apply listed rename to duplicates "	pos:[210,30] align:#left	width:200 enabled:false
				button 			btnNamePrefixCheck 	"Check selection Valid prefix tag  "	pos:[10,60]	 align:#left	width:200
				button 			btnNamePrefixApply 	"Apply listed rename to duplicates "	pos:[210,60] align:#left	width:200 enabled:false


			label 			labUserProps		"User Property Tools"				pos:[10,10]	align:#left	

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
				append curLi btnNameDupeApply 
				append curLi btnNamePrefixCheck
				append curLi btnNamePrefixApply

				curLi = rigBuddy.uiMainItems.uiUserProperties
				append curLi labUserProps

				-- Initialize the List View
				rbi.lvSetproperties lvMain
				rbi.lvSetColumns	lvMain #("","") #(20,475)

				-- Initialize the toolset to the default mode
				rigBuddy.interfaces.uiMainMode "Naming"
				--rigBuddy.interfaces.uiMainMode "User Properties"				

				labelProgress.text = "Status: Ready"
			)

 			-- Modify the UI items positions, when the window is resized
			on uiMainRollout resized arg do
			(
				if uiMainRollout.height < 120 then(uiMainRollout.height = 120)else()
				if uiMainRollout.height > 1000 then(uiMainRollout.height = 1000)else()

 				progBar1.pos 					= [5,(uiMainRollout.height - 25 )]					
				uiMainRollout.lvMain.height 	= (uiMainRollout.height - 30)
  				labelProgress.pos 				= [10,(uiMainRollout.height - 15)]
			)
		)

		-- Construct the Main UI Rollout and return it
		createDialog uiMainRollout lockHeight:false lockWidth:true menu:rc_MainMenu style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox)	
		
		-- Set some things for the UI
		uiMainRollout.height = 400
		--SetDialogPos uiMainRollout [500,300]
		SetDialogPos uiMainRollout [1000,150]

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

