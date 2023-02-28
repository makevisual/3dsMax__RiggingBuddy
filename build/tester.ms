--					selArr = ( selection as array )
					-------------- rigBuddy.report = rigBuddy.lib.pointCacheTestSelection selArr

					-- Set the list view
--					rbi = rigBuddy.interfaces
--					rbi.lvSetColumns	lvMain #("","Modifier present","Animhandle","Name") #(22,100,80,400)	
--					rows = #()		

--					for node in rigBuddy.report.failList do
--					(
--						print node
--						li=dotNetObject "System.Windows.Forms.ListViewItem" ""
--						li.UseItemStyleForSubItems = false					
--						li.subitems.add ( "False" )
--						li.subitems.add ( node as string )
--						curNode = ( getAnimByHandle node )
--						li.subitems.add ( curNode.name  )
--						append rows li
--					)

					-- Add the rows
--					lvMain.items.addRange rows


--					rigBuddy.uiMain.labelStatus.text = ( "All geometry objects have a valid point cache modifer" )	


selArr = ( selection as array )
--rigBuddy.report = rigBuddy.lib.skinPivotReset selArr


--function test arg_obj =
--(
--	print arg_obj.modifiers
--
--	-- Look through each of the modifiers
--	for i in 1 to ( arg_obj.modifiers.count) do
--	(	
--
--		curMod = arg_obj.modifiers[i]
--
--		-- If the modifier is a skin modifier
--		if (classof curMod) == skin 
--		then
--		(
--			-- Turn the modifier off, disable always deform
--
--			-- Reset the pivot
--			arg_obj.pivot = [0,0,0]
--
--			-- Turn things back on
--			curMod.enabled = false 
--			curMod.enabled = true
--			curMod.always_deform = false
--			curMod.always_deform = true
--
--			-- Indicate that the pivot was modified
--			test = true
--		)
--	)
--)

filein "math3dLib.ms" 		-- used for common math operations 			-- comes in as math3dLib
filein "collect3dLib.ms" 	-- used for common collection operations 	-- comes in as collect3dLib
filein "userPropLib.ms" 	-- used for common user property operations -- comes in as userPropLib
filein "strLib.ms" 			-- used for common string operations 		-- comes in as strLib

				function fnSkinDeformReset arg_List =
				(
					-- When turning off 3dsmax in windows, do it in a try block
					try(

						--------- Disable the 3dsMax from updating in windows
						WM_SETREDRAW 	= 11
						MAX_HWND 		= windows.getMaxHWND()
						windows.sendmessage MAX_HWND WM_SETREDRAW 0 0
						--------- Creates some locations and datas for use, and store the selection
						reports = #()
						tempDir = "C:\\skin_weights_temp\\"
						makedir tempDir
						temSel = ( selection as array )
	
						-------- Creates a callback that will call the getDialogHandle function when triggered
						function dialog_ClickOK =
						(
							dialogHandle = dialogMonitorOps.getWindowHandle()
							uiAccessor.pressButtonByName dialogHandle "OK"
						)
	
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
							struct subReport
							(
								pass = false,
								skinIndex = undefined
							)
							
							newSubReport = subReport()
	
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
						)
	
						------ Reset the selection
						select temSel
	
						------ Disables the dialogops after it is done, removes the temporary files
						dialogMonitorOps.enabled = false
						cmdStr = ("rmdir " + tempDir + " /s /q")
						DOSCommand cmdStr

						--Enable 3dsMax to update in windows
						windows.sendmessage MAX_HWND WM_SETREDRAW 1 0
					)	
					catch
					(
						--Enable 3dsMax to update in windows
						windows.sendmessage MAX_HWND WM_SETREDRAW 1 0

						-- Turn the ok button clicker off as well
						dialogMonitorOps.enabled = false
					)
				)

clearListener()
fnSkinDeformReset (selection as array)