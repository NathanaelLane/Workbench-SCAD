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
 include <workbench/blueprints/templates.scad>
 
use <workbench/handfile.scad>
use <workbench/partsbin.scad>
use <workbench/multitool.scad>
use <workbench/blueprints/fasteners.scad>

_stepper_types = Collection(
	STEPPER_TYPE,
	[
		["nema17", "NEMA 17", 31, Thread("m3"), 4.5, 42.5, 5, 22, 2]
	]);
	
_stepper_library = Collection(
	STEPPER,
	[
		["nema17", "default", 48, 22, 200, undef, undef]
	], [], [1], _stepper_types);

/*
 * [string] return the empty Stepper base object corresponding to the given specifier/NEMA size,
 * for creating custom StepperMotor objects
 * 
 * - size: [string]
 */
function StepperTemplate(size="nema17") = Obj(STEPPER, [], [v(_stepper_types, size)]);

/*
 * [string] return the Stepper object corresponding to the given product name/identifier
 * 
 * - name: [string]
 */
function StepperMotor(name="default") = v(_stepper_library, name);

/*
 * [2D], [3D] positions child modules at stepper mounting screw locations relative to center
 * 
 * - stp: [object] stepper type
 * - stretch: [boolean] if true, radially elongate child modules. Default is false
 *     Useful for creating self-centering stepper mounting holes.
 */
module stepper_screw_placement(stp, stretch = false){

	for(x = [-1, 1])
		for(y = [-1, 1])
			translate([x, y] * v(stp, "screw_spacing") / 2)
				if(stretch){
				
					hull()
						for(delta = [-1, 1])
						 	translate([x, y] * delta * 0.25 * sqrt(2))
								children();
				}else{
			
					children();
				}
}

/*
 * [3D] Render a stepper motor based on the given StepperMotor object
 * 
 * - stp: [object] the stepper to render
 */
module stepper_motor(stp){

	echo(str(v(stp, "product_name"), " ", v(stp, "size"), " stepper motor, ", 360 / v(stp, "steps_per_rev"), "-degree step angle"));
	
	render(convexity = 10){
		difference(){
	
			// body
			scale([1, 1, -1])
				linear_extrude(height = v(stp, "body_l"))
					chamfer(v(stp, "w") / 12) square(v(stp, "w"), center = true);
	
			// mounting holes		
			stepper_screw_placement(stp)
				translate(z(-v(stp, "screw_depth")))
					cylinder(d = v(stp, "screw.thread_d"), h = v(stp, "screw_depth") + 1);			
		}

		// lip
		cylinder(h = v(stp, "boss_h"), d = v(stp, "boss_d"));

		// shaft
		chamfer_extrude(h = v(stp, "shaft_l"), e=0.5) circle(d = v(stp, "shaft_d"));
	}
}

// test code
$fs = 0.05;
$fa = 5;
stepper_motor(StepperMotor());
debug_struct(_stepper_library);


