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
