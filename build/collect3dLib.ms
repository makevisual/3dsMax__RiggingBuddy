-- collect3dLib - collect3dLib is a collection of various functions for collection various types of data in 3dsMax.
-- aarondabelow@gmail.com

function collect3dLibInit  = (
	
	struct collect3dLibStruct
	(
		version = "0.0.1",

		-- Completed 2023/01/26
		-- Takes a list, and returns a list of all top level ( world space ) objects that are parents of the list
		-- For use finding all the global or top level nodes of a list.
		function collectProtoplasts arg_list = 
		(
			topLevelNodes = #()
			
			-- Subroutine for crawling up a heirarchy of a node, bounded by the number of iterations.
			function boundedParentCrawl arg_node arg_iterations =
			(
				curNode = arg_node

				-- Recursivly attempt to retrieve objects parent
				for i in 1 to arg_iterations do 
				(
					newNode = curNode.parent 

					-- Return the node, if it has no parent, otherwise reassign the current node and try again
					if newNode == undefined
					then 
					(
						-- Return the node that has no parents
						return curNode 
					)
					else 
					(
						-- Reassign node and try again
						curNode = newNode
					)

					-- Toss out a messagebox if the crawl reaches its maximum
					if i == arg_iterations then 
					( messagebox " Maximum number of heirarchy layers reached: " + ( arg_iterations as string ) )
				)
			)

			-- Loop through all objects in the list and collect their parents
			for obj in arg_list do 
			(
				topLevelNode = ( boundedParentCrawl obj 100 )

				append topLevelNodes topLevelNode
			)

			topLevelNodes = ( makeUniqueArray topLevelNodes )

			return topLevelNodes
		),

		-- Completed 2023/01/10
		-- collects all of the children of an inital object, return parent as part of the array optional.
		function collectAllChildren arg_node includeParent:true =
		(
			-- start collecting direct children of <arg_node>
			allChildren = #(arg_node)

			-- add children and their children etc recursively
			i = 0
			while i < allChildren.count do
			(
				i += 1
				join allChildren allChildren[i].children
			)

			-- remove initial object if <includeParent> == false
			if not includeParent then deleteitem allChildren 1

			-- return array containing children
			return allChildren
		),
		
		-- Completed 2023/01/10
		-- collects all items in the list, by animhandle
		function collectByAnimhandle arg_list =
		(

			curHandles 	= arg_list
			selList 	= #()

			for curHandle in curHandles do 
			(
				try
				(
					newNode = ( getAnimByHandle curHandle )
					append selList newNode
				)catch()
			)

			return selList
		),

		-- Completed 2023/01/30
		-- returns all nodes with a class of modifier on it, will filter results by any nodes in
		-- the arg_list argument. 
		function collectNodesByModifier arg_modifier arg_list =
		(
			-- setup arrays
			nodesWithMod = #()
			nodesListed  = #()
			resultNodes  = #()

			-- collect all the arg_modifier modifiers in the scene
			modArr = ( getclassinstances arg_modifier )

			-- get all the nodes with arg_modifier modifiers on them						
			for m in modArr do
			(
				curNode 	= ( refs.dependentnodes m )
				curHandle 	= ( getHandleByAnim curNode[1] )

				append nodesWithMod curHandle
			)

			-- remove duplicates ( from instanced skins )
			nodesWithMod = ( makeUniqueArray nodesWithMod )

			-- if there are any items passed in the arg_list, then filter them against the previously collected nodes
			if arg_list.count >= 1 then 
			(
				-- for each of the items in the passed list...
				for listNode in arg_list do 
				(
					-- and each of the items in the nodes with the modifier...
					for modNode in nodesWithMod do 
					(
						-- collect their animhandles
						listHandle 	= ( getHandleByAnim listNode )
						selHandle 	= modNode
						--selHandle 	= ( getHandleByAnim modNode )

						-- and compare them, adding the handle to the result list if they match.
						if ( listHandle == selHandle ) then 
						(
							append resultNodes listHandle
						)
					)
				)

				-- remove duplicates ( from instanced skins )
				resultNodes = ( makeUniqueArray resultNodes )

			)
			-- If there is no passed list of nodes to compare...
			else 
			(
				-- assign all nodes with the modifier, to the result array
				resultNodes = nodesWithMod
			)

			-- Return the result array
			return resultNodes
		),

		-- Completed 2023/01/30
		-- collects all items in the list, filtered by class, can be additive or subtractive
		function collectByClass arg_list arg_Class inclusive:true=
		(

			-- change the command panel to create mode, for performance
			max create mode 
			
			-- prepare the base object, and delete set
			resultArr = #()
			
			-- loop through the other objects in the array
			for i in 1 to (arg_list.count) do
			(
				-- Case for including only the passed class
				if inclusive then 
				(
					-- if the object is geometry class
					if ( iskindof arg_list[i] arg_Class )

					-- join it
					then (join resultArr #(arg_list[i]))
					else ()
				)

				-- Case for removing the passed class
				else
				(
					-- if the object is geometry class
					if ( iskindof arg_list[i] arg_Class )

					-- join it
					then ()
					else (join resultArr #(arg_list[i]))
				)
			)
			
			-- Returns a list of nodes that fit the criteria
			return resultArr
		),

		-- Completed 2023/01/10
		-- Returns all top level scene nodes ( objects without parents )
		function collectOrphanObjects = 
		(
			allObjs = objects 
			orphanList = #()

			for obj in allObjs do 
			(
				if obj.parent == undefined then
				(
					curHandle = getHandleByAnim obj 
					append orphanList curHandle
				)
			)

			-- Returns a list of animhandles of nodes in world space
			return orphanList
		),

		-- Completed 2023/01/10
		-- Returns all files in a folder, can be recursive
		function collectFilesInDir arg_dir arg_recurse:false =
		(
			fileList = getfiles (arg_dir + @"*.*") recurse:arg_recurse

			-- Returns found files
			return fileList
		),

		-- Completed 2023/01/10
		-- Filteres a list of files for all files of a given type, can do multiple types simultaneously 
		function collectFilesByType arg_list arg_types =
		(
		
			filteredList = #()

			for type in arg_types do 
			(
				for arg in arg_list do 
				(
					curType = getFilenameType arg

					if curType == type then 
					(
						append filteredList arg
					)
				)
			)

			-- Returns a list of the items matching the chosen filetype
			return filteredList
		),

		-- Completed 2023/01/10
		-- Filters and returns a list of files for all files that exist, and are able to be read.
		function collectFilesThatExist arg_list =
		(

			filteredList = #()

			for arg in arg_list do 
			(
				if doesFileExist arg then 
				(
					append filteredList arg
				)
			)

			-- Returns a list of files that exist, from the given list
			return filteredList
		),

		-- Completed 2023/01/25
		-- Collects all objects with the passed name
		function collectNodeByName arg_name =
		(
			validNodes = #()

			for o in objects do
			(
				if o.name == arg_name then ( append validNodes o )	
			)

			return validNodes
		),

		ender = undefined
	)	

	return collect3dLibStruct()
)

collect3dLib = collect3dLibInit()


----------------------
-- Regression Tests --
----------------------

	-- FN collectNodesByModifier
		-- clearListener()
		-- result = collect3dLib.collectNodesByModifier Skin ( selection as array )
		-- print result

	-- FN collectProtoplast
		-- clearListener()
		-- result = collect3dLib.collectProtoplasts selection

	-- FN collectAllChildren
		-- clearListener()
		-- result = collect3dLib.collectNodeByName "Teapot001"

	-- FN collectAllChildren
		-- clearListener()
		-- result = collect3dLib.collectAllChildren selection[1]

	-- FN collectByAnimhandle
		-- handleList = #(4598667P, 4598585P, null )
		-- result = collect3dLib.collectByAnimhandle handleList

	-- FN collectByClass
		-- clearListener()
		-- result = collect3dLib.collectByClass selection light 

	-- FN collectOrphanObjects
		-- result = collect3dLib.collectOrphanObjects()
		-- clearListener()
		-- print result

	-- FN collectFilesInDir
	-- FN collectFilesByType

		-- clearListener()
		-- curDir = @"C:\Scratch Disks\Adobe Premiere Pro Video Previews\Altera_30s__MakingOf__v003.PRV\"
		-- result = collect3dLib.collectFilesInDir curDir arg_recurse:false
		-- print "all"
		-- print result.count 
		-- result2 = collect3dLib.collectFilesByType result #(".mpeg",".txt") 
		-- print "filtered"
		-- print result2.count

	-- FN collectFilesThatExist
		
		-- clearListener()
		-- curFileList = #( @"C:\tmp\New Text Document.txt", @"C:\tmp\New Text Document2.txt" )
		-- result = collect3dLib.collectFilesThatExist curFileList