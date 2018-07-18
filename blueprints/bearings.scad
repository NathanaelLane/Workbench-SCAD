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
include <workbench/blueprints/blueprints.scad>

use <workbench/partsbin.scad>
use <workbench/multitool.scad>
use <workbench/handfile.scad>

_radial_bearing_library = Collection(
  RADIAL_BEARING,
  [
    ["608zz", "608zz", 8, 22, 7, 0, 0],
    ["mr115zz", "MR115zz", 5, 11, 4, 0, 0] 
  ]);

/*
 * [object] return the RadialBearing object corresponding to the given part code
 * 
 * - code: [string]
 */
function RadialBearing(code) = v(_radial_bearing_library, code);

/*
 * [3D] Render a radial ball bearing based on the given RadialBearing object
 * 
 * - rbr: [object] the bearing to render
 * - no_render: [boolean] proxy for the blueprint no_render parameter
 */
module radial_bearing(rbr, center = false, no_render = false) {
    
  blueprint(str(v(rbr, "code"), " radial ball bearing"), no_render) {
  
    e = min(0.5, v(rbr, "w") / 10);
  
    translate(center ? z(0) : z(v(rbr, "w") / 2))
      difference() {
        
        union() {
          
          cylinder(d = v(rbr, "id") + v(rbr, "od") * 0.1, h = v(rbr, "w"), center = true);
          
          intersection() {
            
            chamfer_extrude(h = v(rbr, "w"), e = e, center = true)
              circle(d = v(rbr, "od"));
              
            linear_extrude(height = v(rbr, "w"), center = true, convexity = 4)
              difference() {
                
                circle(d = v(rbr, "od") + 2);
                
                circle(d = v(rbr, "od") - e*3);
              }
          }

          cylinder(h = v(rbr, "w") - e*2, center = true, d = v(rbr, "od") - 1e-3);
        }
        
        cylinder(d = v(rbr, "id"), h = v(rbr, "w") + 2, center = true);
      }
  }
}

_linear_bearing_library = Collection(
  LINEAR_BEARING,
  [
    ["lme12uu", "LME12uu",  12,   22,   32,   1.3,  0.5,   22.9],
    ["lm12uu",  "LM12uu",   12,   21,   30,   1.3,  0.5,   23],
    ["lm12uw",  "LM12uu-w", 12,   21,   57,   1.3,  0.5,   45.9],
    ["lm8uu",   "LM8uu",    8,    15,   24,   1.1,  0.35,  17.5],
    ["lm8uw",   "LM8uu-w",  8,    15,   45,   1.1,  0.35,  34.9]
  ]); 
 

/*
 * [object] return the LinearBearing object corresponding to the given part code
 * 
 * - code: [string]
 */
function LinearBearing(code) = v(_linear_bearing_library, code);

/*
 * [3D] Render a linear ball bearing based on the given LinearBearing object
 * 
 * - lbr: [object] the bearing to render
 * - no_render: [boolean] proxy for the blueprint no_render parameter
 */
module linear_bearing(lbr, center = false, no_render = false) {

  blueprint(str(v(lbr, "code"), " linear ball bearing"), no_render){
    
    e = 0.4;
    
    translate(center ? z(0) : z(v(lbr, "l") / 2))
      difference() {
        
        union() {
          
          intersection() {
            
            chamfer_extrude(h = v(lbr, "l"), e = e, center = true)
              circle(d = v(lbr, "od"));
              
            linear_extrude(height = v(lbr, "l"), center = true, convexity = 4)
              difference() {
                
                circle(d = v(lbr, "od"));
                
                circle(d = v(lbr, "od") - 2);
              }
          }
          
          cylinder(h = v(lbr, "l") - e*2, d = v(lbr, "od") - e*2, center = true);
        }
        
        cylinder(h = v(lbr, "l") + 2, d = v(lbr, "id"), center = true);
        
        for(m = [0, 1])
          mirror(z(m))
            translate(z(v(lbr, "retainer_groove_spacing") / -2))
              linear_extrude(height = v(lbr, "retainer_groove_w"), convexity = 4)
                difference() {
                  
                  circle(d = v(lbr, "od") + 2);
                  
                  circle(d = v(lbr, "od") - v(lbr, "retainer_groove_depth") * 2); 
                }
      }
  }
}

// test code
grid_array() {
  
  radial_bearing(RadialBearing("608zz"));
  radial_bearing(RadialBearing("mr115zz"), center = true);
  linear_bearing(LinearBearing("lm12uu"));
  linear_bearing(LinearBearing("lme12uu"), center = true);
}



