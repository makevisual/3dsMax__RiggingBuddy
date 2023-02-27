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


function test arg_obj =
(
	print arg_obj.modifiers

	-- Look through each of the modifiers
	for i in 1 to ( arg_obj.modifiers.count) do
	(	

		curMod = arg_obj.modifiers[i]

		-- If the modifier is a skin modifier
		if (classof curMod) == skin 
		then
		(
			-- Turn the modifier off, disable always deform
			--curMod.enabled = false 
			curMod.always_deform = false

			-- Reset the pivot
			arg_obj.pivot = [0,0,0]

			-- Turn things back on
			curMod.always_deform = true
			--curMod.enabled = true

			-- Indicate that the pivot was modified
			test = true
		)
	)
)

clearListener()
test selection[1]