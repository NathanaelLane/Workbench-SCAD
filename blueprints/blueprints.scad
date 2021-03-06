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

use <workbench/partsbin.scad>

RENDER_BLUEPRINT_PREFIX = "[rendering model] ";

// stepper motors
STEPPER = Template("product_name, body_l, shaft_l, steps_per_rev, torque, coil_current");
STEPPER_TYPE = Template("size, screw_spacing, screw, screw_depth, w, shaft_d, boss_d, boss_h");


// t-slot aluminum extrusion
TSLOT_PROFILE = Template("side_w, slot_w, lip_h, t_w, t_depth, corner_r, end_screw");

// fasteners
THREAD = Template("thread_d, pilot_d, pitch");
SCREW_HEAD = Template("socket_type, head_type, socket_d, head_h, head_d");
NUT = Template("type, h, flat_d");
WASHER = Template("type, h, od, id");


// bearings
RADIAL_BEARING = Template("code, id, od, w, flange_d, flange_l");
LINEAR_BEARING = Template("code, id, od, l, retainer_groove_w, retainer_groove_depth, retainer_groove_spacing");

// e-clip
E_CLIP = Template("h, od, id");

// timing belt
TIMING_BELT = Template("type, thickness, tooth_h, pitch");
/*
 * [string] return the string prefix for the "echo" statement issued when rendering an object 
 * from within the Blueprint library. Wrapping it in a function allows for modules to "use" blueprints.scad 
 * instead of "include"-ing it.
 */
function getRenderObjectPrefix() = RENDER_BLUEPRINT_PREFIX;

/*
 * [2D], [3D] "Echo" a text representation of the blueprint and then render it conditionally. 
 * Blueprint implementations should wrap rendering code in this module for uniform implementation.
 * 
 * - id_string: [string] a string representation of the given object.
 * - no_render: [boolean] a value indicating whether or not to render the geometry. Useful for 
 *     generating BOMs
 */
module blueprint(id_string, no_render) {
  echo(str(RENDER_BLUEPRINT_PREFIX, id_string));
  if(!no_render)
    children();
}
