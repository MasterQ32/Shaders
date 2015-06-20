#include <acknex.h>
#include <default.c>

#define PRAGMA_PATH "models"
#define PRAGMA_PATH "shaders"
#define PRAGMA_PATH "textures"

BMAP *bmap_flesh = "flesh.png";

MATERIAL *mtl_slice = 
{
	effect = "slice.fx";
	skin1 = bmap_flesh;
}

action fx_slice()
{
	my.material = mtl_slice;
}

function main()
{
	d3d_antialias = 9;
	level_load(NULL);
	
	ENTITY *sliceTest = ent_create("box.mdl", vector(256, 0, 0), fx_slice);
	
	while(1)
	{
		VECTOR dir;
		vec_for_angle(dir, vector(total_ticks, 0.5 * total_ticks, 0));
		
		// Note the swapped yz!
		// Slice Normal
		sliceTest.skill41 = floatv(dir.x);
		sliceTest.skill42 = floatv(dir.z);
		sliceTest.skill43 = floatv(dir.y);
		
		// Slice Local Position
		sliceTest.skill45 = floatv(0);
		sliceTest.skill46 = floatv(48 * sinv(3 * total_ticks));
		sliceTest.skill47 = floatv(0);
	
		wait(1);	
	}
}