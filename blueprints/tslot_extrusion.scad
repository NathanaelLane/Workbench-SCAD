/*
 * Workbench OpenSCAD utility library
 * Copyright (C) 2017 NathanaelLane
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

use <workbench/multitool.scad>
use <workbench/partsbin.scad>
use <workbench/blueprints/triangle.scad>
use <workbench/handfile.scad>

  
_TSLOT = Collection(
	Template("side_w, slot_w, lip_h, t_w, t_depth, corner_r, end_screw"),
	[
		["t30", [30, 8, 2, 16.5, 9, 2, undef]],
		["t15", [15, 3.4, 1.1, 5.7, 4.7, 3, undef]]
	]
	);

/*
 * [object] create a new object representing a segment of aluminum extrusion
 * 
 * - size: [string] profile size/shape
 * - length: [number] length of the segment
 */ 
function TSlotExtrusion(size, length) = Obj(Template("l"), [length], [v(_TSLOT, size)]);

/*
 * [2D] render a profile/cross-section based on the given tslot object
 * 
 * - p: [object] the desired profile to render
 */
module tslot_profile(p){
	
	difference(){
		
		// basic profile 
		fillet(r = v(p, "corner_r")) square(v(p, "side_w"), center = true);

		// t-slot cutouts		
		for(a = [0:90:270])
			rotate([0, 0, a]){

				slot_offset = v(p, "side_w") / 2 - v(p, "t_depth");
				angle_offset = (v(p, "t_w") - v(p, "slot_w") * 1.1) / 2;
		
				translate([v(p, "slot_w") / -2, slot_offset, 0])	
					square([v(p, "slot_w"), v(p, "t_depth")]);
		
				translate([0, v(p, "side_w") / 2 - v(p, "t_depth"), 0])	
					intersection(){
			
						translate([0, v(p, "slot_w") * -0.55, 0])
							rotate([0, 0, 180])
								triangle(a = 90, h = v(p, "side_w"));
					
						translate([v(p, "t_w") / -2, 0, 0])	
							square([v(p, "t_w"), v(p, "t_depth") - v(p, "lip_h")]);
					}
			}

			//center hole
			circle(d = v(p, "end_screw.pilot_d"));
		}
}

/*
 * [3D] render a segment of extrusion based on the given tslot object
 * 
 * - tsl: [object] the desired extrusion to render
 */
module tslot_extrusion(tsl){
	
	echo(str(v(tsl, "side_w"), "x", v(tsl, "side_w"), " T-slot aluminum extrusion"));
	
	color(vec(173 / 255))
		render(convexity = 10)
			linear_extrude(height = v(tsl, "l"), convexity = 10)
				tslot_profile(tsl);
}

// test code
grid_array(){
  tslot_extrusion(TSlotExtrusion("t15", 200));
  tslot_extrusion(TSlotExtrusion("t30", 10));
}
