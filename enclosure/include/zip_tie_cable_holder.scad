/*

Zip Tie Anchor by
[PeterEllens](https://www.thingiverse.com/thing:24187)
is licensed under a [CC-BY license](https://creativecommons.org/licenses/by/4.0/)

Modified by [Gerrit Niezen](https://github.com/OpenAirMonitor/OpenAirMonitor/tree/main/enclosure)

*/

module zip_tie_anchor() {
    base_width = 20;
    base_height = 1;
    gap_width = 4;
    gap_height =2;
    top_width = 8;
    top_height = 2.3;
    cross_width = 1.8;

    diaginal_width = sqrt(base_width*base_width+base_width*base_width);

    difference () {
    union() {
    cube(size=[base_width,base_width,base_height],center=true);
    translate(v=[0,0,base_height+(gap_height-base_height)/2]) cube(size=[top_width,top_width,top_height+gap_height],center=true);

    rotate(a=[0,11,45]) translate(v=[diaginal_width/4,0,base_height+gap_height]) cube(size=[diaginal_width/2,cross_width,gap_height+1],center=true);

    rotate(a=[0,11,90+45]) translate(v=[diaginal_width/4,0,base_height+gap_height]) cube(size=[diaginal_width/2,cross_width,gap_height+1],center=true);

    rotate(a=[0,11,180+45]) translate(v=[diaginal_width/4,0,base_height+gap_height]) cube(size=[diaginal_width/2,cross_width,gap_height+1],center=true);

    rotate(a=[0,11,270+45]) translate(v=[diaginal_width/4,0,base_height+gap_height]) cube(size=[diaginal_width/2,cross_width,gap_height+1],center=true);


    }
    translate(v=[0,0,base_height+(gap_height-base_height)/2]) cube(size=[gap_width,top_width+1,gap_height],center=true);
    translate(v=[0,0,base_height+(gap_height-base_height)/2]) cube(size=[top_width+1,gap_width,gap_height],center=true);

    translate(v=[0,0,base_height+(gap_height+base_height)]) cube(size=[top_width,top_width,top_height-gap_height+0.6],center=true);

    translate(v=[0,0,-base_height-(base_height)/2]) cube(size=[base_width+2,base_width+2,base_height*2],center=true);

    translate(v=[0,base_width,0]) cube(size=[base_width+5,base_width,base_height+gap_height+1],center=true);

    translate(v=[0,-base_width,0]) cube(size=[base_width+5,base_width,base_height+gap_height+1],center=true);

    translate(v=[base_width,0,0]) cube(size=[base_width,base_width+5,base_height+gap_height+1],center=true);

    translate(v=[-base_width,0,0]) cube(size=[base_width,base_width+5,base_height+gap_height+1],center=true);

    }
}

zip_tie_anchor();