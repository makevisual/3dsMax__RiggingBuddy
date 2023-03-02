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

		-- FN skinParentToSkin
			-- clearListener()
			-- timeStamp()
			-- selArr = ( selection as array )
			-- -- rbLib.skinParent selArr undefined -- test for retriving a parent from the heirarchy
			-- rbLib.skinParent selArr $Point001 -- test for passing a new parent

clearListener()
fnSkinDeformReset (selection as array)