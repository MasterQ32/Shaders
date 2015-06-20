#include <acknex.h>
#include <default.c>

#define PRAGMA_PATH "models"
#define PRAGMA_PATH "shaders"

MATERIAL *mtl_slice = 
{
	effect = "slice.fx";
}

action fx_slice()
{
	my.material = mtl_slice;
}

function main()
{
	level_load(NULL);
	
	ent_create("box.mdl", vector(256, 0, 0), fx_slice);
}