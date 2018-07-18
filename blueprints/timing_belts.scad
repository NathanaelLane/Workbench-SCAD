/*
 * Workbench OpenSCAD utility library
 * Copyright (C) 2018 NathanaelLane
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
include <workbench/blueprints/blueprints.scad>

use <workbench/multitool.scad>
use <workbench/partsbin.scad>

_belts = Collection(
  TIMING_BELT,
  [
    ["gt2", "GT2", 1.38 - 0.75, 0.75, 2]
  ]);

/*
 * [object] return the TimingBelt object corresponding to the given type identifier
 * 
 * - type: [string]
 */
function TimingBelt(type="gt2") = v(_belts, type);  

/*
 * [2D] Render a single belt tooth in the GT2 profile.
 * 
 */
module gt2_tooth_profile() {
  
  belt = TimingBelt("gt2");
  tooth_radius = 0.555;
  blend_radius = 1;
  tooth_height = v(belt, "tooth_h");
  blend_offset = 0.4;
  fillet_radius = 0.15;
  pitch = v(belt, "pitch");
  belt_profile_height = tooth_height + v(belt, "thickness");

  tip_rad_offset = tooth_height - tooth_radius;
  fillet_center_point = sqrt(pow(blend_radius + fillet_radius, 2) - fillet_radius * fillet_radius) - blend_offset;
  belt_thickness = belt_profile_height - tooth_height;
  blend_height = blend_radius * (tip_rad_offset / sqrt(tip_rad_offset * tip_rad_offset + blend_offset * blend_offset));

  translate(y(tip_rad_offset))
    circle(r = tooth_radius);
  
  intersection() {
    
    intersection_for(x = [-1, 1]) {
      translate(x(x*blend_offset))
        circle(r = blend_radius);
    }
    
    translate([-pitch/2, -belt_thickness])
      square([pitch, belt_thickness + blend_height]);
  }
  
  difference() {
    
    translate([-fillet_center_point, -belt_thickness])
      square([fillet_center_point * 2, fillet_radius + belt_thickness]);
      
    for(x = [-1, 1])
      translate([x*fillet_center_point, fillet_radius])
        circle(r = fillet_radius);
  
  }
  
  translate([-pitch / 2 - 0.1, -belt_thickness])
    square([pitch + 0.2, belt_thickness]);
}

// test code

gt2_tooth_profile($fs = 0.1, $fa = 6);
