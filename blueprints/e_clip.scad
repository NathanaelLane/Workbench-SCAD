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
use <workbench/multitool.scad>
use <workbench/geometry/triangle.scad>
use <workbench/partsbin.scad>

_eclip_library = Collection(
  E_CLIP,
  [
    ["d6", 0.7, 11.8, 6],
    ["d4", 0.7, 8.85, 4]
  ]);

/*
 * [object] return the EClip object corresponding to the given part code
 * 
 * - code: [string]
 */
function EClip(code) = v(_eclip_library, code);

/*
 * [3D] Render an e-clip based on the given EClip object
 * 
 * - clp: [object] the clip to render
 */
module e_clip(clp){
    
  echo(str(RENDER_BLUEPRINT_PREFIX, v(clp, "id"), "mm id E-clip"));
  
  linear_extrude(height = v(clp, "h"))
    difference(){
                
      circle(d = v(clp, "od"));
      
      circle(d = v(clp, "id")); 
      
      intersection(){
      
          circle(d = v(clp, "od") * 0.75);
          
          for(a = [-1, 1])
              rotate(z(125 * a))
                  triangle(a = 70, h = v(clp, "od"));
      }
      
      translate(y(v(clp, "id") / 2))
          triangle(h = v(clp, "od"), a = 30);   
  }
}


// test code
grid_array() {
  
  e_clip(EClip("d6"));
  
  e_clip(EClip("d4"));
}
