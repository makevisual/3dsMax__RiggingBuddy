function math3dLibInit  = (
	
	struct math3dLibStruct
	(
		version = "0.0.1",

		-- Returns the distance between two points
		function distance3D arg_a arg_b =
		(
			xD = ( arg_a[1] - arg_b[1] )
			yD = ( arg_a[2] - arg_b[2] )
			zD = ( arg_a[3] - arg_b[3] )
			
			return ( sqrt ( xD*xD + yD*yD + zD*zD ) )
		),

		-- returns the bisected point between two points
		function bisect3D arg_a arg_b = 
		(
			return ( ( arg_a + arg_b ) / 2 )
		),

		ender = undefined
	)	

	return math3dLibStruct()

)

math3dLib = math3dLibInit()