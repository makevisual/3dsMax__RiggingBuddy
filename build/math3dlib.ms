-- math3dLib - math3dLib is a collection of various math operations for use in tools and utilities in 3dsmax
-- aarondabelow@gmail.com

function math3dLibInit  = (
	
	struct math3dLibStruct
	(
		version = "0.0.1",

		-- Completed 2023/01/09
		-- Returns the distance between two points
		function distance3D arg_a arg_b =
		(
			xD = ( arg_a[1] - arg_b[1] )
			yD = ( arg_a[2] - arg_b[2] )
			zD = ( arg_a[3] - arg_b[3] )
			
			-- Return the calculated position
			return ( sqrt ( xD*xD + yD*yD + zD*zD ) )
		),

		-- Completed 2023/01/09
		-- returns the bisected point between two points
		function bisect3D arg_a arg_b = 
		(
			-- Return the calculated position
			return ( ( arg_a + arg_b ) / 2 )
		),

		-- Completed 2023/01/10
		-- returns the point planar to the 3 passed objects, that is aligned to the hypotenuse of the second object. ( usefull for placing pole vectors )
		function hypotenuseAlign arg_objs =
		(
			
			pA = arg_objs[1].pos
			pB = arg_objs[2].pos
			pC = arg_objs[3].pos

			AB = math3dLib.distance3D pA pB
			BC = math3dLib.distance3D pB pC
			CA = math3dLib.distance3D pC pA
			
			pD = ( math3dLib.bisect3D pC pA )
			DA = ( pB - pD )
			newPos = ( ( DA * 2 ) + pD )

			-- Return the calculated position
		 	return newPos
		),

		ender = undefined
	)	

	return math3dLibStruct()

)

-- Instantiate the library
math3dLib = math3dLibInit()


----------------------
-- Regression Tests --
----------------------

	-- FN distance3D
	-- FN bisect3D
	-- FN hypotenuseAlign

		--clearListener()
		--math3dLib.hypotenuseAlign ( selection as array )