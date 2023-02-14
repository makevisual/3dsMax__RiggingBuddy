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
	
	-- Function to create the main ui object
	function uiMainInit  =
	(
		-- Top Bar Menu Items
		rcMenu rc_MainMenu
		(
			subMenu		"Mode"
			(
				menuItem	miMeshes			"Meshes"
				menuItem	miSkinning			"Skinnig"
				menuItem	miRigging			"Rigging"
				menuItem	miNaming			"Naming"
				menuItem	miUserProperties	"User Properties"
			)	
			subMenu		"Utilities"
			(
				menuItem	miAssetInspector	"Asset Inspector"
			)	
			subMenu		"Help"
			(
				menuItem 	MI_Help_Help		"Help"
				menuItem 	MI_Help_About		"About"
			)
		)

		curVerNumStr = rigBuddy.lib.verNumStr()
		rollout uiMainRollout ( "MAKE Rig Buddy v" + curVerNumStr ) width:1000 height:10
		(
			
			--dotNetControl 	lvMain 				"system.windows.forms.listView" pos:[250,0] height:200 width:749					
			dotNetControl 	lvMain 				"system.windows.forms.listView" pos:[500,0] height:200 width:499					
			label 			labelProgress		"Status: initializing"			pos:[0,0]	align:#left	
			progressbar 	progBar1 			width:990 						pos:[0,0] 	height:8 value:80 color:[0,60,90]

			on uiMainRollout open do
			(
				rbi = rigBuddy.interfaces

				rbi.lvSetproperties lvMain
				rbi.lvSetColumns	lvMain #("","") #(20,475)

				labelProgress.text = "Status: Ready"
			)

 			-- Modify the UI items positions, when the window is resized
			on uiMainRollout resized arg do
			(
				if uiMainRollout.height < 193 then(uiMainRollout.height = 193)else()
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
		SetDialogPos uiMainRollout [500,300]

		return uiMainRollout
	),

	ender = undefined

)		



debug = true

if debug == true then
(
	clearListener()
	try( destroyDialog rigBuddy.uiMain )catch()
	rigBuddy.interfaces = rbInterfacesStruct()
	rigBuddy.uiMain = rigBuddy.interfaces.uiMainInit()
)
