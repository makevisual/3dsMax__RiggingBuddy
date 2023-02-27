clearListener()



-- Try to remove any previous Rig Buddy Windows
try( destroyDialog rigBuddy.uiMain )catch()

-- Rig Buddy master class
struct rigBuddyStruct
(
	version 	= undefined,		-- the version number
	interfaces 	= undefined,		-- interfacesLib.ms - ui items and their functions - instantiated here
	uiItems 	= undefined,		-- as ui items are created, they are stored in a list here, for access later
	uiMain 		= undefined,		-- main ui item stored on here
	uiMainItems	= undefined,		-- holds the ui items to be worked with
	uiAbout 	= undefined,		-- main ui item stored on here
	lib 		= undefined,		-- rbLib.ms, and sublibraries - all working functions - instantiated here
	report 		= undefined,		-- A nice reference point for a report, to be
	data 		= undefined 		-- global data location
)

-- Build the global object, and populate it
global rigBuddy 		= rigBuddyStruct()

rigBuddy.version 		= [0,0,1] 							-- Set the version number, this is converted to string where needed.
rigBuddy.uiItems 		= #() 								-- Clears any stored interface items

-- Initialize Functions
filein "rbLib.ms"
rigBuddy.lib 			= rbLibInit() 						-- assigns the functions structs from rbLib.ms

-- Initialize Interfaces
filein "interfacesLib.ms" 
rigBuddy.interfaces 	= rbInterfacesStruct()				-- assigns the interfaces structs from rbInterfacesLib.ms
rigBuddy.uiMain 		= rigBuddy.interfaces.uiMainInit()	-- Builds the main ui, and assigns it

-- Add the main ui into the ui list, for bookkeeping 
append rigBuddy.uiItems rigBuddy.uiMain

result = ( "Rig Buddy v" + rigBuddy.lib.verNumStr() + " started successfully!")