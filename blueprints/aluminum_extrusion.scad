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

TSLOT = Template("side_w, slot_w, lip_h, t_w, t_depth, corner_r, end_screw");
  
_library = Collection(TSLOT, [
  ["t30", [30, 8, 2, 16.5, 9, 2, undef]],
  ["t15", [15, 3.4, 1.1, 5.7, 4.7, 3, undef]]]
  );

function TSlotExtrusion(size, length) = Obj(Template("l"), [length], [v(_library, size)]);

module tslot_extrusion(tsl){
	
	echo(str(v(tsl, "side_w"), "x", v(tsl, "side_w"), " T-slot aluminum extrusion"));
	
	color(vec(173 / 255))
		render(convexity = 10)
			linear_extrude(height = v(tsl, "l"), convexity = 10)
				difference(){
		
					// basic profile 
					fillet(r = v(tsl, "corner_r")) square(v(tsl, "side_w"), center = true);
			
					// t-slot cutouts		
					for(a = [0:90:270])
						rotate([0, 0, a])
							union(){
					
								slot_offset = v(tsl, "side_w") / 2 - v(tsl, "t_depth");
								angle_offset = (v(tsl, "t_w") - v(tsl, "slot_w") * 1.1) / 2;
						
								translate([v(tsl, "slot_w") / -2, slot_offset, 0])	
									square([v(tsl, "slot_w"), v(tsl, "t_depth")]);
						
								translate([0, v(tsl, "side_w") / 2 - v(tsl, "t_depth"), 0])	
									intersection(){
							
										translate([0, v(tsl, "slot_w") * -0.55, 0])
											rotate([0, 0, 180])
												triangle(a = 90, h = v(tsl, "side_w"));
									
										translate([v(tsl, "t_w") / -2, 0, 0])	
											square([v(tsl, "t_w"), v(tsl, "t_depth") - v(tsl, "lip_h")]);
									}
							}
			
					//center hole
					circle(d = v(tsl, "end_screw.pilot_d"));
				}
}

grid_array(){
  tslot_extrusion(TSlotExtrusion("t15", 200));
  tslot_extrusion(TSlotExtrusion("t30", 0));
}
