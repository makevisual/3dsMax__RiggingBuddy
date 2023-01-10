-- collect3dLib - collect3dLib is a collection of various functions for collection various types of data in 3dsMax.
-- aarondabelow@gmail.com

function collect3dLibInit  = (
	
	struct collect3dLibStruct
	(
		version = "0.0.1",

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

		-- Completed 2023/01/10
		-- collects all items in the list, filtered by class
		function collectByClass arg_list arg_Class =
		(

			-- change the command panel to create mode, for performance
			max create mode 
			
			-- prepare the base object, and delete set
			resultArr = #()
			
			-- loop through the other objects in the array
			for i in 1 to (arg_list.count) do
			(
				-- if the object is geometry class
				if ( iskindof arg_list[i] arg_Class )

				-- join it
				then (join resultArr #(arg_list[i]))
				else ()
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

		ender = undefined
	)	

	return collect3dLibStruct()
)

collect3dLib = collect3dLibInit()


----------------------
-- Regression Tests --
----------------------

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