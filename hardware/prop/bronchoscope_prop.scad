// =============================================================================
//  Bronchoscopy Simulator — Vive scope prop, Mk1
//  Parametric, printable handle with a spring-centred deflection lever and a
//  quick-release Vive Tracker shoe.
//
//  Design intent (see README.md):
//    * the lever is the only instrument axis: up/down deflection, ±32°
//    * torque comes from the wrist, measured by the Tracker's 6-DoF pose
//    * insertion is clutch + scaled hand motion, driven from the other hand's
//      wand in Mk1 (no buttons on the prop yet)
//    * clamshell body: no supports needed, internals accessible
//
//  Units: millimetres, Z up. Print orientation is as modelled.
//  Render:  ./build.sh
//  Preview: openscad bronchoscope_prop.scad
// =============================================================================

/* [Part] */
// handle_right | handle_left | lever | tracker_shoe | shaft_collar |
// scope_cradle | all_preview
part = "handle_right";

/* [Handle] */
handle_w    = 34;     // across the palm (X)
handle_d    = 46;     // front-to-back (Y), +Y is forward
handle_h    = 122;    // bottom to top (Z)
grip_bulge  = 2.0;    // extra width at the bottom
corner_r    = 11;     // vertical edge rounding

/* [Internal bay] */
bay_w       = 22;     // X, split across both halves
bay_d       = 28;     // Y
bay_z0      = 8;
bay_z1      = 44;     // must stay below the lever recess

/* [Lever recess and pivot] */
recess_depth = 25;    // how far the thumb recess cuts into the front
recess_z0    = 46;
recess_z1    = 112;
pivot_y      = 18;
pivot_z      = 104;
lever_arm_l  = 32;
lever_throw  = 22;    // degrees each side
hub_r        = 9.0;
hub_h        = 12;
magnet_d     = 6.3;
magnet_depth = 2.7;
axle_d       = 4.4;   // M4 pivot bolt
spring_z     = 86;    // spring post height
spring_x     = 11.5;  // body spring posts, just inside the recess walls

/* [Fasteners] */
insert_d     = 4.2;   // M3 heat-set insert pilot (into the right half)
insert_depth = 7.5;
clear_d      = 3.4;   // M3 clearance through the left half
head_d       = 6.6;   // M3 socket head counterbore
pin_d        = 3.0;
// screw stations in the YZ plane, measured from the split face
screw_yz     = [[-16, 18], [16, 18], [-16, 74], [16, 74]];
pin_yz       = [[-16, 30], [-16, 64]];

/* [Tracker shoe] */
shoe_size     = 48;
shoe_t        = 6;
tracker_hole  = 7.5;   // 1/4-20 clearance
tripod_head   = 14.5;  // counterbore for the bolt head
keyhole_d     = 4.2;   // drops over M3 screw heads
keyhole_slide = 9;
pad_z         = 74;    // centre of the back mounting pad

/* [Shaft] */
shaft_od   = 10.0;
collar_od  = 20;
collar_h   = 14;

/* [Quality] */
$fn = 56;

// -----------------------------------------------------------------------------
// Primitives
// -----------------------------------------------------------------------------

// Rounded box that is safe for thin slabs (radius clamped to the smallest half
// dimension, so a 6 mm plate cannot silently become 14 mm thick).
module rbox(size, r = 3) {
    rr = min(r, min(size[0], size[1]) / 2 - 0.05, min(size[1], size[2]) / 2 - 0.05,
             min(size[0], size[2]) / 2 - 0.05);
    x = max(size[0] / 2 - rr, 0.01);
    y = max(size[1] / 2 - rr, 0.01);
    z = max(size[2] / 2 - rr, 0.01);
    hull()
        for (sx = [-1, 1]) for (sy = [-1, 1]) for (sz = [-1, 1])
            translate([sx * x, sy * y, sz * z]) sphere(rr);
}

// Prism with rounded vertical edges and flat top/bottom: the printable grip.
module rprism(w, d, h, r, z0 = 0) {
    translate([0, 0, z0])
        hull()
            for (sx = [-1, 1]) for (sy = [-1, 1])
                translate([sx * (w / 2 - r), sy * (d / 2 - r), 0])
                    cylinder(h = h, r = r);
}

// -----------------------------------------------------------------------------
// Handle
// -----------------------------------------------------------------------------

module body_outer() {
    hull() {
        rprism(handle_w + grip_bulge, handle_d + grip_bulge, 5, corner_r, 0);
        rprism(handle_w, handle_d, 5, corner_r, handle_h - 5);
    }
}

module bay_cut() {
    translate([0, 0, bay_z0]) rbox([bay_w, bay_d, bay_z1 - bay_z0], 3);
    // wiring / USB-C tunnel out the back-bottom
    translate([0, -handle_d / 2 + 2, bay_z0 + 4]) rotate([90, 0, 0])
        rbox([13, 7, 12], 1.5);
}

module lever_recess() {
    // thumb cavity, open at the front
    translate([0, handle_d / 2 - recess_depth / 2 + 1, (recess_z0 + recess_z1) / 2])
        rbox([23, recess_depth + 2, recess_z1 - recess_z0], 5);
}

module pivot_ears() {
    // two blocks flanking the recess that carry the axle
    for (sx = [-1, 1])
        translate([sx * 13.0, pivot_y, pivot_z]) rbox([6, 16, 18], 3);
}

module pivot_bore() {
    translate([0, pivot_y, pivot_z]) rotate([0, 90, 0])
        cylinder(h = handle_w + 8, d = axle_d, center = true);
    for (sx = [-1, 1])
        translate([sx * (handle_w / 2 - 0.6), pivot_y, pivot_z]) rotate([0, 90, 0])
            cylinder(h = 4, d = axle_d + 6);
}

module sensor_plate() {
    // AS5600 board mounts flat on this plate, reading the hub magnet across a
    // 3 mm air gap. Part of the left half; bridges to the pivot ear so it is
    // supported inside the thumb recess.
    translate([-10.75, pivot_y, pivot_z]) rbox([3.5, 26, 20], 2);
    // M2 pilot holes for the board
    for (sx = [-1, 1])
        translate([-10.75, pivot_y + sx * 7.5, pivot_z + 7.5]) rotate([0, 90, 0])
            cylinder(h = 5, d = 1.6, center = true);
}

module spring_seat(sx) {
    // post inside the recess wall that an O-ring hooks onto; each half owns one
    translate([sx * 11.0, pivot_y, spring_z]) rotate([0, 90, 0])
        cylinder(h = 6.0, d = 4.5, center = true);
}

module collar_land() {
    // flat top-front land for the shaft collar, bore tilted 20° forward
    translate([0, 10, handle_h - 6]) rotate([20, 0, 0])
        rbox([collar_od + 6, collar_od + 6, 14], 4);
}

module collar_bores() {
    translate([0, 10, handle_h - 6]) rotate([20, 0, 0]) {
        cylinder(h = 44, d = shaft_od + 0.5, center = true);
        for (sx = [-1, 1])
            translate([sx * 7, 0, 0]) cylinder(h = 44, d = 3.2, center = true);
    }
}

module finger_grooves() {
    for (z = [22, 36]) 
        translate([0, handle_d / 2 + 3, z]) rotate([90, 0, 0])
            cylinder(h = 10, r = 7.0);
}

module tracker_pad() {
    translate([0, -handle_d / 2 + 0.5, pad_z]) rbox([shoe_size - 2, 5, shoe_size - 2], 3);
}

module tracker_pad_holes() {
    for (sx = [-1, 1])
        translate([sx * 15, -handle_d / 2 + 1.0, pad_z]) rotate([90, 0, 0]) {
            cylinder(h = 14, d = insert_d, center = true);
            translate([0, 0, -7]) cylinder(h = 6, d = insert_d + 1.8, center = true);
        }
}

module body_common_cuts() {
    bay_cut();
    lever_recess();
    pivot_bore();
    collar_bores();
    finger_grooves();
    tracker_pad_holes();
}

// Fasteners run along X, normal to the split face: that is what actually
// clamps a clamshell together. Insert bores go into the right half, clearance
// holes and counterbores through the left half.
module insert_bores_right() {
    for (p = screw_yz)
        translate([-0.5, p[0], p[1]]) rotate([0, 90, 0]) {
            cylinder(h = insert_depth + 0.6, d = insert_d);
            cylinder(h = 1.8, d = insert_d + 1.8);      // lead-in at the split face
        }
}

module clearance_left() {
    for (p = screw_yz)
        translate([-19, p[0], p[1]]) rotate([0, 90, 0]) {
            cylinder(h = 20, d = clear_d);              // through the half
            cylinder(h = 6.5, d = head_d);              // M3 head counterbore
        }
}

module pins_right() {
    for (p = pin_yz)
        // start slightly inside the right half so the union actually merges
        translate([0.8, p[0], p[1]]) rotate([0, -90, 0]) cylinder(h = 4.4, d = pin_d);
}

module pin_holes_left() {
    for (p = pin_yz)
        translate([0.3, p[0], p[1]]) rotate([0, -90, 0]) cylinder(h = 9, d = pin_d + 0.4);
}

module handle_right() {
    union() {
        intersection() {
            difference() {
                union() { body_outer(); tracker_pad(); collar_land(); pivot_ears(); }
                body_common_cuts();
                insert_bores_right();
            }
            translate([0, -200, -20]) cube([200, 400, 300]);
        }
        spring_seat(1);
        pins_right();
    }
}

module handle_left() {
    difference() {
        intersection() {
            difference() {
                union() { body_outer(); tracker_pad(); collar_land(); pivot_ears();
                          sensor_plate(); spring_seat(-1); }
                body_common_cuts();
            }
            translate([-200, -200, -20]) cube([200, 400, 300]);
        }
        clearance_left();
        pin_holes_left();
    }
}

// -----------------------------------------------------------------------------
// Lever: hub at the pivot, arm hanging into the recess
// -----------------------------------------------------------------------------

module lever() {
    // local origin at the pivot; arm extends -Z
    difference() {
        union() {
            rotate([0, 90, 0]) cylinder(h = hub_h, d = hub_r * 2, center = true);
            translate([0, 0, -lever_arm_l / 2])
                rbox([12, 9, lever_arm_l], 3);
            // thumb pad
            translate([0, 2.5, -lever_arm_l - 2])
                rbox([24, 13, 12], 4);
            // spring posts, one each side of the arm
            for (sx = [-1, 1])
                translate([sx * 7.5, 0, -lever_arm_l / 2]) rotate([0, 90, 0])
                    cylinder(h = 6, d = 4.2, center = true);
        }
        rotate([0, 90, 0]) cylinder(h = hub_h + 2, d = axle_d, center = true);
        // magnet pocket on the -X face, facing the AS5600 in the left wall
        translate([-hub_h / 2 - 0.1, 0, 0]) rotate([0, 90, 0])
            cylinder(h = magnet_depth, d = magnet_d);
        // concave thumb dish, shallow so it cannot eat the arm
        translate([0, 12, -lever_arm_l - 4]) sphere(r = 16);
        // lightening slot low on the arm
        translate([0, 0, -lever_arm_l + 9]) rbox([4.5, 12, 12], 1.5);
    }
}

// -----------------------------------------------------------------------------
// Tracker shoe: bolts to the Tracker, then slides onto two M3 screw heads
// -----------------------------------------------------------------------------

module tracker_shoe() {
    difference() {
        rbox([shoe_size, shoe_t, shoe_size], 4);
        rotate([90, 0, 0]) cylinder(h = shoe_t + 2, d = tracker_hole, center = true);
        // bolt head sits on the handle side
        translate([0, -shoe_t / 2 - 0.1, 0]) rotate([90, 0, 0])
            cylinder(h = 4.2, d = tripod_head);
        for (sz = [-1, 1])
            hull() {
                translate([0, 0, sz * 15]) rotate([90, 0, 0])
                    cylinder(h = shoe_t + 2, d = keyhole_d, center = true);
                translate([0, 0, sz * (15 + keyhole_slide)]) rotate([90, 0, 0])
                    cylinder(h = shoe_t + 2, d = keyhole_d - 0.5, center = true);
                translate([0, 0, sz * (15 + keyhole_slide / 2)]) rotate([90, 0, 0])
                    rbox([keyhole_d, shoe_t + 2, keyhole_slide + keyhole_d], 1.2);
            }
        // cable relief
        translate([0, shoe_t / 2, -shoe_size / 2 + 7]) rotate([90, 0, 0])
            rbox([10, 6, 7], 1.5);
    }
}

// -----------------------------------------------------------------------------
// Shaft collar
// -----------------------------------------------------------------------------

module shaft_collar() {
    difference() {
        union() {
            cylinder(h = collar_h, d = collar_od, center = true);
            translate([0, 0, collar_h / 2 - 1.5]) cylinder(h = 4, d = collar_od + 7, center = true);
        }
        cylinder(h = collar_h + 6, d = shaft_od + 0.3, center = true);
        cube([1.6, collar_od + 2, collar_h + 6], center = true);
        rotate([0, 90, 0]) cylinder(h = collar_od + 4, d = 3.2, center = true);
        translate([0, collar_od / 2 + 1, 0]) rotate([0, 90, 0])
            cylinder(h = 6, d = 6.4, center = true);
        for (sx = [-1, 1])
            translate([sx * 7, 0, 0]) rotate([0, 0, 0]) cylinder(h = collar_h + 6, d = 3.2, center = true);
    }
}

// -----------------------------------------------------------------------------
// Optional cradle for holding a real bronchoscope
// -----------------------------------------------------------------------------

module scope_cradle() {
    difference() {
        union() {
            rbox([46, 42, 26], 4);
            translate([0, 0, -13]) rbox([54, 12, 6], 3);
        }
        translate([0, 2, 7]) rotate([90, 0, 0]) cylinder(h = 46, d = 24, center = true);
        translate([0, 0, -18]) rotate([45, 0, 0]) cube([24, 30, 30], center = true);
        for (sz = [-1, 1]) translate([0, 0, sz * 9]) rbox([50, 6, 4], 1.5);
        translate([0, -18, 0]) rotate([90, 0, 0]) cylinder(h = 22, d = 4.4);
        translate([0, -23, 0]) rotate([90, 0, 0]) cylinder(h = 10, d = 10);
    }
}

// -----------------------------------------------------------------------------
// Dispatch
// -----------------------------------------------------------------------------

// The halves are exported split-face-down so they print with no supports and
// the screw bores come out vertical.
if (part == "handle_right")      rotate([0, 90, 0]) handle_right();
else if (part == "handle_left")  rotate([0, -90, 0]) handle_left();
else if (part == "lever")        lever();
else if (part == "tracker_shoe") tracker_shoe();
else if (part == "shaft_collar") shaft_collar();
else if (part == "scope_cradle") scope_cradle();
else if (part == "all_preview") {
    handle_right();
    translate([55, 0, 0]) handle_left();
    translate([0, 0, pivot_z]) lever();
    translate([95, 0, pad_z]) tracker_shoe();
    translate([0, 70, 30]) shaft_collar();
}
else echo("unknown part: ", part);
