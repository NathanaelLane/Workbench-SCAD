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


/*
 * [2D] Creates a shape commonly used to avoid messy overhangs >45 degrees 
 * when 3D-printing round holes in a vertical orientation.
 * 
 * - r: [number] circle radius (default: 1)
 * - d: [number] circlee diameter (default: undefined)
 * - point: [boolean] if true, the top of the circle tapers to a point 
 *     (the reprap "teardrop" shape) instead of a horizontal overhang. Use this option for
 *     large holes where the overhang gap would be too wide for your printer to bridge.
 * 
 */
module vertical_hole(r = 1, d = 0, point = false){
	
	_r = (d == 0) ? r : d / 2;
	
	difference(){

		union(){
			//hole
			circle(r = _r);
			//teardrop
			translate(y(sqrt(2) * _r / 2)){

				rotate(z(45)){

					square(_r, center = true);
				}
			}
		}
		if(!point){
	
			translate(y(_r * 2)){
	
				square(2 * _r, center = true);
			}
		}
	}
}


// test code
$fa = 5;
$fs = 0.05;
use <workbench/multitool.scad>
grid_array() {
	vertical_hole();
	vertical_hole(d = 12);
	vertical_hole(r = 6, point = true);
}
