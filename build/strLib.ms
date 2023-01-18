-- strLib - strLib is a collection of various math operations for use in tools and utilities in 3dsmax
-- aarondabelow@gmail.com

function strLibInit  = (
	
	struct strLibStruct
	(
		version = "0.0.1",

		-- Completed 2023/01/18
		-- split the arg_string into as many parts as exist, using the arg_token as the split point
		-- returns a list of the parts, without any tokens.
		-- similar to the filterstring function, but works on multi-character tokens
		-- will remove any zero character strings as well, for strings that start with the token
		function splitByToken arg_string arg_token =
		(

			stringParts 		= #()
			stringPartsClean 	= #()
			testResult1 		= ( findString  arg_string arg_token )

			-- Subroutine for splitting and returning its parts, and if the string was split.
			function splitParts arg_string arg_token = 
			(
				-- object to hold results
				struct report
				(
					isSplit 			= false,
					trimFront   		= undefined,
					trimEnd 			= undefined
				)

				newReport 	= report()
				testResult 	= ( findString  arg_string arg_token )

				-- If there is an instance of the token in the string, return the string up to the point that the token begins
				if (classof testResult ) == ( integer ) then 
				(

					newReport.isSplit 		= true 

					-- trim the front of the string without the token
					trimFront 			= ( substring arg_string 1 ( testResult - 1 ) )
					newReport.trimFront 	= trimFront

					-- trim the end of the string without the token
					trimEnd 			= ( substring arg_string ( testResult + arg_token.count) ( arg_string.count ) )
					newReport.trimEnd 		= trimEnd

					-- return the string parts, and that the string was split.
					return newReport
				)

				-- If there are no instances of the token in the string, return the string as the part
				if testResult == undefined
				then
				(
					newReport.trimFront 	= arg_string
					return newReport
				)	
			)

			-- test to see if there are any instances of the token in the string. If no splits are needed, return the string
			if testResult1 == undefined
			then 
			(
				-- Return the whole string
				append stringParts arg_string
				return stringParts
			)
			else
			(
				-- get the ball rolling, by performing the first split
				curSplit = ( splitParts arg_string arg_token )
				append stringParts curSplit.trimFront

				-- keep trying to split, until no more splits occour
				-- could be done in a while loop, but I prefer bounded loops. loop will terminate on failure to find token.
				-- probably should not have more than 100 instances of the token in the string regardless
				for i in 1 to 100 do 
				(
					if curSplit.isSplit == true then 
					(
						-- split and add appropriate parts to the list
						curSplit = ( splitParts curSplit.trimEnd arg_token  )
						append stringParts curSplit.trimFront
					)
					else(exit)
				)
			)

			-- Remove any zero character strings from the list
			for stringPart in stringParts do 
			(
				if stringPart != "" then ( append stringPartsClean stringPart)
			)


			-- return an array of all the parts of the string as an array, filtered from any instances of the token.
			return stringPartsClean
		),

		-- Completed 2023/01/18
		-- Increment or Decrement a string by a value of 1, for any string with a v### in its string
		-- Automatically padds zeroes to match provided string
		function stringVersionModify arg_string arg_direction =
		(
			-- Declarations
			isValidNumber	= false 
			newNum 			= undefined
			lowerstring 	= ( tolower arg_string )
			strParts 		= (filterstring arg_string "v")	
			lastPart 		= ( strParts[strParts.count])

			-- Try to turn the last part of the string into a number, if not, return an empty string
			curNum = ( try ( execute lastPart ) catch("") )

			-- if the isolated part of the string is a numver then add or subtract 1 from it, otherwise flag as invalid number
			if ( classof curNum ) == integer 
			then
			(
				-- flag the string part as a valid number
				isValidNumber = true

				-- Case for incrementing the number
				if arg_direction == #up then
				(
					newNum = ( curNum + 1 )
				)

				-- Case for decrementing the number
				if arg_direction == #down then
				(
					newNum = ( curNum - 1 )

					-- Prevent the number from going negative
					if newNum <= 0 then ( newNum = 0 )
				)
			)
			else
			(
				-- flag the string part as an invalid number
				isValidNumber = false
			)

			-- If the string is a valid number, then parse it
			if isValidNumber
			then 
			(
				-- get the string
				-- trimmedStr = (substring arg_string 1 (arg_string.count - lastPart.count ))

				-- generate the new number, with a 1 prefix
				padding 		= lastPart.count
				paddingNum 		= (10^padding)
				resultNum 		= ( paddingNum + newNum )

				-- trim the preceeding 1 off of the string
				resultNumStr 	= ( substring ( resultNum as string ) 2 ( ( resultNum as string ).count - 1 ) )

				-- add the part of the string, preceeding the 'v' and add a 'v' to the string
				resultStr 		= (( strParts[1] + "v") + resultNumStr )

				-- Return the prepared string
				return resultStr
			)
			else
			(
				-- If the string is un-versionable, return the original string
				return arg_string
			)
		),

		ender = undefined
	)	

	return strLibStruct()

)

-- Instantiate the library
strLib = strLibInit()


----------------------
-- Regression Tests --
----------------------

	-- FN splitByToken

		-- clearListener()
		-- print (timeStamp())
		-- strLib.splitByToken "catasdfcat100cat001" "cat"

	-- FN stringVersionModify 

		-- clearListener()
		-- print (timeStamp())
		-- curString = "asdf_v005"
		-- print ( "-- Up --")
		-- print ( strLib.stringVersionModify curString #up )
		-- print ( "-- Down --")
		-- print ( strLib.stringVersionModify curString #down )