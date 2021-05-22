typedef float4 point;		// x, y, z, 1.typedef float4 vector;		// vx, vy, vz, 0.typedef float4 color;		// r, g, b, atypedef float4 sphere;		// x, y, z, rtypedef float4 cube;		// x, y, z, sizevectorBounce( vector in, vector n ){	vector out = in - n*(vector)( 2.*dot(in.xyz, n.xyz) );	out.w = 0.;	return out;}vectorBounceSphere( point p, vector v, sphere s ){	vector n;	n.xyz = fast_normalize( p.xyz - s.xyz );	n.w = 0.;	return Bounce( v, n );}boolIsInsideSphere( point p, sphere s ){	float r = fast_length( p.xyz - s.xyz );	return  ( r < s.w );}vectorBounceCube(point p, vector v, cube cu){	// Calculate the width from the center which allows us	// to determine where a side of the axis-aligned cube is.	float width_from_center = (cu.w / 2.);		// Determine what x, y, or z each side is on.	float right = cu.x + width_from_center;	float left = cu.x - width_from_center;	float top = cu.y + width_from_center;	float bottom = cu.y - width_from_center;	float front = cu.z + width_from_center;	float back = cu.z - width_from_center;		// Calculate the difference between the particle location and	// each side. The one that is the closest to 0 indicates the	// side the particle is striking.	float right_hit = fabs(p.x - right);	float left_hit = fabs(p.x - left);	float top_hit = fabs(p.y - top);	float bottom_hit = fabs(p.y - bottom);	float front_hit = fabs(p.z - front);	float back_hit = fabs(p.z - back);		// Right now we have 6 sides, but each two will get the	// same instruction. We take the minimum since we know that	// if the particle is striking the right side of the cube, it	// definitely is not hitting the opposite (left) side of the 	// cube.	float x_hit = min(right_hit, left_hit);	float y_hit = min(top_hit, bottom_hit);	float z_hit = min(front_hit, back_hit);	// If the particle is striking an x-axis aligned side,	// we reverse the x velocity vector to simulate the bounce.	// And... we do the same for the other two axes.	if (x_hit < y_hit && x_hit < z_hit)	{			v.x = -v.x;	}	if (y_hit < x_hit && y_hit < z_hit)	{			v.y = -v.y;	}	if (z_hit < x_hit && z_hit < y_hit)	{			v.z = -v.z;	}	return v;}boolIsInsideCube (point p, cube cu){	// We calculate where each side of the cube is...	// A cube with 200 edge length at 0, 0, 0 will have	// sides at x = -100, x = 100 and the same for y and z.	float x1 = cu.x - (cu.w / 2);	float x2 = cu.x + (cu.w / 2);	float y1 = cu.y - (cu.w / 2);	float y2 = cu.y + (cu.w / 2);	float z1 = cu.z - (cu.w / 2);	float z2 = cu.z + (cu.w / 2);	// If the particle is within all sides, it is inside the cube,	// otherwise it is not.	if (x1 < p.x && p.x < x2)	{		if (y1 < p.y && p.y < y2)		{			if (z1 < p.z && p.z < z2)			{				return true;			}			return false;		}		return false;	}	return false;}colorColorByYVelocity (vector v, color c){		// We save the y velocity since that is how we are coloring our particles	// primarily	float vy = v.y;	// Dimrate is how fast the Green component fades to 0. (after a bounce)	float dim_rate = 0.99;	// These are the y velocities that a particle will be in transition from	// blue to red as its falling making the particle appear purple.	float v_floor = -20;	float v_ceil = 20;	// Declare this to store the normalized value of vy.	float normalized_vy;	// If vy is positive, we paint the particle Blue. The closer	// vy gets to v_ceil, we will subtract more and more red until it	// surpases vy, which it will become completely Blue. We also 	// diminish the amount of green component every cycle by	// dim_rate to give recently bounced objects a fading effect	if (vy > 0)	{				normalized_vy = ((vy - 0) / (v_ceil));		normalized_vy = (normalized_vy > 1.) ? 1. : normalized_vy;		return (color) (1. - normalized_vy, c.y * dim_rate, 1., 1.);	}	// If vy is negative, we apply the same logic as we did with positive vy	// particles except that we remove Blue until the object exceeds v_floor.	// Once the particle surpasses v_floor, it will become fully Red. We also	// remove green component on each pass.	normalized_vy = (vy - v_floor) / (v_floor);	normalized_vy = (normalized_vy > 1.) ? 1. : normalized_vy;	return (color) (1. , c.y * dim_rate, 1. - normalized_vy, 1.);}colorColorOnBounce (color c){	// Simply maxes out the green component on a bounce.	return (color) (c.x, 1., c.z, c.w);}kernelvoidParticle( global point *dPobj, global vector *dVel, global color *dCobj ){	const float4 G       = (float4) ( 0., -9.8, 0., 0. );	const float  DT      = 0.05;	const sphere Sphere1 = (sphere)( -100., -800., 0.,  600. );	const sphere Sphere2 = (sphere)( 400., 0., -300., 300. );	const cube Cube1 = (cube)( 400., 500., 500., 500.);	const cube Cube2 = (cube)( -1000., -750., -750., 600.);	int gid = get_global_id( 0 );	// extract the position and velocity for this particle:	point  p = dPobj[gid];	vector v = dVel[gid];	// remember that you also need to extract this particle's color	// and change it in some way that is obviously correct	color c = dCobj[gid];	// advance the particle:	point  pp = p + v*DT + G*(point)( .5*DT*DT );	vector vp = v + G*DT;	pp.w = 1.;	vp.w = 0.;	// test against the first sphere here:	if( IsInsideSphere( pp, Sphere1 ) )	{		vp = BounceSphere( p, v, Sphere1 );		pp = p + vp*DT + G*(point)( .5*DT*DT );			c = ColorOnBounce(c);	}	// test against the second sphere here:	else if( IsInsideSphere( pp, Sphere2 ) )	{		vp = BounceSphere( p, v, Sphere2 );		pp = p + vp*DT + G*(point)( .5*DT*DT );		c = ColorOnBounce(c);	}	// test against the first cube	else if( IsInsideCube( pp, Cube1))	{		vp = BounceCube( p, v, Cube1 );		pp = p + vp*DT + G*(point)( .5*DT*DT );		c = ColorOnBounce(c);	}	// test against the second cube	else if( IsInsideCube (pp, Cube2))	{		vp = BounceCube( p, v, Cube2 );		pp = p + vp*DT + G*(point)( .5*DT*DT );		c = ColorOnBounce(c);	}			// If the particle didn't bounce, we color it according to its y velocity.	else	{		c = ColorByYVelocity( vp, c );	}	dPobj[gid] = pp;	dVel[gid]  = vp;	dCobj[gid] = c;}