typedef float4 point;		// x, y, z, 1.typedef float4 vector;		// vx, vy, vz, 0.typedef float4 color;		// r, g, b, atypedef float4 sphere;		// x, y, z, rtypedef float4 cube;		// x, y, z, sizevectorBounce( vector in, vector n ){	vector out = in - n*(vector)( 2.*dot(in.xyz, n.xyz) );	out.w = 0.;	return out;}vectorBounceSphere( point p, vector v, sphere s ){	vector n;	n.xyz = fast_normalize( p.xyz - s.xyz );	n.w = 0.;	return Bounce( v, n );}boolIsInsideSphere( point p, sphere s ){	float r = fast_length( p.xyz - s.xyz );	return  ( r < s.w );}vectorBounceCube(point p, vector v, cube cu){	float x1 = p.x - cu.x - (cu.w / 2);	float x2 = p.x - cu.x + (cu.w / 2);	float y1 = p.y - cu.y - (cu.w / 2);	float y2 = p.y - cu.y + (cu.w / 2);	float z1 = p.z - cu.z - (cu.w / 2);	float z2 = p.z - cu.z + (cu.w / 2);	float xhit = min(x1, x2);	float yhit = min(y1, y2);	float zhit = min(z1, z2);	if (xhit < yhit && xhit < zhit)	{		v.x = -v.x;	}	if (yhit < xhit && yhit < zhit)	{		v.y = -v.y;	}	if (zhit < xhit && zhit < yhit)	{		v.z = -v.z;	}		return v;}boolIsInsideCube (point p, cube cu){		float x1 = cu.x - (cu.w / 2);	float x2 = cu.x + (cu.w / 2);	float y1 = cu.y - (cu.w / 2);	float y2 = cu.y + (cu.w / 2);	float z1 = cu.z - (cu.w / 2);	float z2 = cu.z + (cu.w / 2);	if (x1 < p.x && p.x < x2)	{		if (y1 < p.y && p.y < y2)		{			if (z1 < p.z && p.z < z2)			{				return true;			}		}	}	return false;}colorColorByYVelocity (vector v, color c){	float vy = v.y;	float dim_rate = 0.99;	float normalized_vy = (v.y + 100) / ( 120 );	normalized_vy = (normalized_vy < 0) ? 0 : normalized_vy;	float center_vy = (normalized_vy - .5);	center_vy = (center_vy < 0) ? -center_vy : center_vy;	center_vy = -(2. * center_vy) + 1.;	if (normalized_vy > .5)	{		return (color) (1. - normalized_vy, c.y * dim_rate, 1., 1.);	}	return (color) (1. , c.y * dim_rate, 1. - (1. - normalized_vy), 1.);}colorColorOnBounce (color c){	return (color) (c.x, 1., c.z, c.w);}kernelvoidParticle( global point *dPobj, global vector *dVel, global color *dCobj ){	const float4 G       = (float4) ( 0., -9.8, 0., 0. );	const float  DT      = 0.05;	const sphere Sphere1 = (sphere)( -100., -800., 0.,  600. );	const sphere Sphere2 = (sphere)( 400., 0., -300., 300. );	const cube Cube1 = (cube)( 400., 500., 500., 500.);	int gid = get_global_id( 0 );	// extract the position and velocity for this particle:	point  p = dPobj[gid];	vector v = dVel[gid];	// remember that you also need to extract this particle's color	// and change it in some way that is obviously correct	color c = dCobj[gid];	// advance the particle:	point  pp = p + v*DT + G*(point)( .5*DT*DT );	vector vp = v + G*DT;	pp.w = 1.;	vp.w = 0.;	// test against the first sphere here:	if( IsInsideSphere( pp, Sphere1 ) )	{		vp = BounceSphere( p, v, Sphere1 );		pp = p + vp*DT + G*(point)( .5*DT*DT );			c = ColorOnBounce(c);	}	// test against the second sphere here:	else if( IsInsideSphere( pp, Sphere2 ) )	{		vp = BounceSphere( p, v, Sphere2 );		pp = p + vp*DT + G*(point)( .5*DT*DT );		c = ColorOnBounce(c);	}	// test against the cube	else if( IsInsideCube( pp, Cube1))	{		vp = BounceCube( p, v, Cube1 );		pp = p + vp*DT + G*(point)( .5*DT*DT );		c = ColorOnBounce(c);	}	else	{		c = ColorByYVelocity( vp, c );	}	// If the particle didn't bounce, we color it according to its y velocity.	dPobj[gid] = pp;	dVel[gid]  = vp;	dCobj[gid] = c;}