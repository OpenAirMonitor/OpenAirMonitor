/*
Downloaded from:
https://github.com/fo-am/sonic-kayaks/blob/master/hardware/3dp/pm-box-home-print.scad

Sonic Kayak sensors, electronics designs and waterproofing systems Copyright (C) 2020 FoAM Kernow

CERN Open Hardware Licence Version 2 - Strongly Reciprocal

*/

$fs=0.5; 
$fa=0.5; 

module sensor() {
    color("blue") 
    cube([47.7,36.7,11.7]);

    // plug
    color("black")
    translate([1.85,36.7-10-2.85,12])
    square([6,10]);

    // air out
    color("black")
    translate([4.45,37,11.7-2-8.75])
    rotate([90,0,0])
    square([9.8,2]);

    // air in
    color("black")
    translate([0,37,11.7-4.4-6.45])
    translate([47.7-11-4.45,0,0]) // ???
    rotate([90,0,0])
    square([11,4.4]);
}

nipple_width=13.0;
nipple_hole_width=11.0;
nipple_height=6.0;
nipple_hole_height=4.0;

module bent_pipe() {
    rotate([0,90,90]) {
        rotate_extrude(angle=90) {
            translate([5,0,0])
            difference() {
                square([6,nipple_width],true);
                square([4,nipple_hole_width],true);
            }            
        }
        translate([5,-1.5,0])
        difference() {
            cube([6,3,nipple_width],true);
            cube([4,3.1,nipple_hole_width],true);
        }
    }
}

module nipple() {
    bent_pipe();
}



module nipples() {
    // in nipple
    translate([69.2,40+2,0])
    rotate([90,90,0])
    nipple();

    // out nipple
    translate([41,40+2,0])
    rotate([90,90,0])
    nipple();
}


//translate([31.5,1.5,4.5]) sensor();

// internal space
//translate([0,0,0])
//color([1,1,1,0.5])
//cube([80,40,20]);

// 6-10mm internal pipe diameter


translate([0,0,3])
difference() {
    union() {
        // bottom wall
        translate([-3,-3,-3]) cube([86,46,3]);
        // back wall
        translate([0,-3,0]) cube([80,3,22]);
        // back wall
        translate([0,40,0]) cube([80,3,22]);
        // end wall
        translate([-3,-3,0]) cube([3,46,22]);
        // end wall
        translate([80,-3,0]) cube([3,46,22]);

        nipples();
        // bottom spacer
        translate([30,-3,-0.5]) cube([50,46,2]);
        // air separators
        translate([30,38.5,0])
        union() {
            cube([2,2,15]);
            translate([0,0,13])
            cube([50.5,2,2]);
            translate([20,0,0])
            cube([10,2,15]);
        }
    }
        
    translate([33,42.5,5])
    rotate([-90,180,0])
    linear_extrude(height=3) {
        union() {
            scale([0.3,0.3,1]) {
//                text("Sonic Kayaks");
                text("Sonic Bikes");
                translate([0,-13,0])
                text("Air pollution sensor");
            }
//            translate([0,5,0])
//            scale([0.75,0.75,1])
//            import("foam-logo-seg.dxf");
            scale([0.5,0.5,0.5])
            translate([0,-252,0])
            import("bri-logo.dxf");
        }
    }
    
    // cut holes through box and nipples 
    union() {
        translate([69.2,40.01,4])
        rotate([90,0,0])
        union () {
            cube([nipple_hole_width,4,10], true);
            translate([41-69.2,0,0])
            cube([nipple_hole_width,4,10], true);
        }
        translate([-5,30,15])
        rotate([0,90,0])
        cylinder(d=3.5,h=10);
    }
}


// lid
translate([-3,-5,3]) 
rotate([180,0,0])
union() {
    cube([86,46,3]);
    translate([3.5,3.5,-2])
    cube([79,39,2]);
}
