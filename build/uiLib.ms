struct rbInterfaceFunctionsStruct
(
	version = "0.0.1",
	
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
		rollout uiMainRollout ( "MAKE Rig Buddy v" + curVerNumStr ) width:1200 height:10
		(
			
			dotNetControl 	rbListViewMain 				"system.windows.forms.listView" pos:[250,0] height:200 width:949					
			
			on uiMainRollout open do
			(

				--lab_checkRepo.text = ( " " + checkRepository )

				-- SceneCheckUI_Struct.TVsetproperties sceneCheckTV	-- Sets the display and properties of the tree view

				-- SceneCheck_Functions.getChecks checkRepository		-- Gets all the the checks from the directories and assembles them into memory
  				-- SceneCheckUI_Struct.TVpopulate sceneCheckTV			-- Populates the items in the tree view

				-- SceneCheckUI_Struct.LVsetproperties sceneCheckLV
				-- SceneCheckUI_Struct.LVsetColumns	sceneCheckLV #("","Priority","Object","Class","Failed Check","Property","Action")
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
	try( destroyDialog rigBuddy.uiMain )catch()
	rigBuddy.interfaces = rbInterfacesStruct()
	rigBuddy.uiMain = rigBuddy.interfaces.uiMainInit()
)
