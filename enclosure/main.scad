$fn = 40;
sideLength = 12;

//faceplate
rotate([90, 0, 0]) {
    difference() {
        cube([90, 20, 1]);
        
        //antenna hole
        translate([12, 12, 0])
        cylinder(2, d = 8);
        
        // PMS7003 holes
        translate([36, 15, 0]) {
            cube([10, 3, 2]);
            
            translate([26, -3, 0])
            cube([12.5, 6, 2]);
        }
    }
}


//bottom
cube([90, sideLength, 1]);

translate([4, 10, 0])
cylinder(5, d = 1.7);

translate([83, 8, 0])
cylinder(5, d = 1.7);

//sides
rotate([90, 0, 90]) {
    cube([sideLength, 20, 1]);
    translate([0, 0, 89])
    cube([sideLength, 20, 1]);
}