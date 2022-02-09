close("*");
setBatchMode(true);
image_radius = 256;
n_frames = 64;
Dialog.create("Two sphere colocalization demo");
font_size = 16;
Dialog.addMessage("---Image---");
Dialog.addNumber("Frames:", n_frames);
Dialog.addNumber("Border:", 20);
Dialog.addMessage("---Sphere---")
Dialog.addNumber("Radius 1:", 60);
Dialog.addNumber("Radius 2:", 40);
Dialog.addNumber("Z-overlap:", 15);
Dialog.addNumber("Z stretch:", 30);
Dialog.addCheckbox("Show colocalization", true);
Dialog.addNumber("Font size:", font_size);
Dialog.show();
n_frames = Dialog.getNumber();
border = Dialog.getNumber();
s1_radius = Dialog.getNumber();
s2_radius = Dialog.getNumber();
s_overlap = Dialog.getNumber();
z_stretch = Dialog.getNumber();
show_coloc = Dialog.getCheckbox();
font_size = Dialog.getNumber();
setFont("Sans Serif", font_size);
i_width = (s1_radius + 2*s2_radius + border - s_overlap)*2;
i_height = i_width;
i_depth = i_width + 2*z_stretch;

//Generate high-NA sphere movie
y_center = round(i_height/2);
x_center = i_width/2;
z_center = i_depth/2;
run("3D Draw Shape", "size="+i_width+","+i_height+","+i_depth+" center="+x_center+","+y_center+","+z_center+" radius="+s1_radius+","+s1_radius+","+s1_radius+" vector1=1.0,0.0,0.0 vector2=0.0,1.0,0.0 res_xy=1.000 res_z=1.000 unit=pix value=255 display=[New stack]");
selectWindow("Shape3D");
rename("ref1");
x_center_step = (i_width)/n_frames;
for(a=1; a<=n_frames; a++){
	showProgress(a, n_frames*4);
	selectWindow("ref1");
	run("Duplicate...", "title=Shape3D duplicate");
	if(isOpen("C1")){
		run("Concatenate...", "  title=C1 open image1=C1 image2=Shape3D");
	}
	else{
		selectWindow("Shape3D");
		rename("C1");
	}
}
close("ref1");

y_center = round(i_height/2);
x_center = i_width;
z_center = i_depth;
run("3D Draw Shape", "size="+2*i_width+","+i_height+","+2*i_depth+" center="+x_center+","+y_center+","+z_center+" radius="+s2_radius+","+s2_radius+","+s2_radius+" vector1=1.0,0.0,0.0 vector2=0.0,1.0,0.0 res_xy=1.000 res_z=1.000 unit=pix value=255 display=[New stack]");
selectWindow("Shape3D");
rename("ref2");
x_center_step = (i_width)/n_frames;
r = s1_radius + s2_radius - s_overlap;
for(a=1; a<=n_frames; a++){
	showProgress(a+n_frames, n_frames*4);
	selectWindow("ref2");
	angle = 2*PI*(a-1)/n_frames;
	x_center = round(i_width/2 + r*cos(angle));
	z_center = round(i_depth/2 + r*sin(angle))+1;
	makeRectangle(x_center, 0, i_width, i_height);
	run("Duplicate...", "title=Shape3D duplicate range=" + z_center + "-" + z_center+i_depth-1);
	if(isOpen("C2")){
		run("Concatenate...", "  title=C2 open image1=C2 image2=Shape3D");
	}
	else{
		selectWindow("Shape3D");
		rename("C2");
	}
}
close("ref2");

//Generate low NA sphere movie
y_center = round(i_height/2);
x_center = i_width/2;
z_center = i_depth/2;
run("3D Draw Shape", "size="+i_width+","+i_height+","+i_depth+" center="+x_center+","+y_center+","+z_center+" radius="+s1_radius+","+s1_radius+","+s1_radius+z_stretch+" vector1=1.0,0.0,0.0 vector2=0.0,1.0,0.0 res_xy=1.000 res_z=1.000 unit=pix value=255 display=[New stack]");
selectWindow("Shape3D");
rename("ref1");
x_center_step = (i_width)/n_frames;
for(a=1; a<=n_frames; a++){
	showProgress(a+2*n_frames, n_frames*4);
	selectWindow("ref1");
	run("Duplicate...", "title=Shape3D duplicate");
	if(isOpen("C1_s")){
		run("Concatenate...", "  title=C1_s open image1=C1_s image2=Shape3D");
	}
	else{
		selectWindow("Shape3D");
		rename("C1_s");
	}
}
close("ref1");

y_center = round(i_height/2);
x_center = i_width;
z_center = i_depth;
run("3D Draw Shape", "size="+2*i_width+","+i_height+","+2*i_depth+" center="+x_center+","+y_center+","+z_center+" radius="+s2_radius+","+s2_radius+","+s2_radius+z_stretch+" vector1=1.0,0.0,0.0 vector2=0.0,1.0,0.0 res_xy=1.000 res_z=1.000 unit=pix value=255 display=[New stack]");
selectWindow("Shape3D");
rename("ref2");
x_center_step = (i_width)/n_frames;
r = s1_radius + s2_radius - s_overlap;
for(a=1; a<=n_frames; a++){
	showProgress(a+3*n_frames, n_frames*4);
	selectWindow("ref2");
	angle = 2*PI*(a-1)/n_frames;
	x_center = round(i_width/2 + r*cos(angle));
	z_center = round(i_depth/2 + r*sin(angle))+1;
	makeRectangle(x_center, 0, i_width, i_height);
	run("Duplicate...", "title=Shape3D duplicate range=" + z_center + "-" + z_center+i_depth-1);
	if(isOpen("C2_s")){
		run("Concatenate...", "  title=C2_s open image1=C2_s image2=Shape3D");
	}
	else{
		selectWindow("Shape3D");
		rename("C2_s");
	}
}
close("ref2");

//Generate 3D coloc stack
run("Merge Channels...", "c2=C1 c6=C2 create ignore");
run("Split Channels");
imageCalculator("AND create stack", "C1-Merged","C2-Merged");
selectWindow("Result of C1-Merged");
rename("3D coloc");

imageCalculator("AND create stack", "C1_s","C2_s");
selectWindow("Result of C1_s");
rename("3D coloc stretch");

//Measure 3D coloc
selectWindow("C1-Merged");
run("Duplicate...", "title=[C1_Volume] duplicate frames=" + n_frames/2);
selectWindow("C1_Volume");
Stack.getStatistics(dummy, s1_volume, dummy, dummy, dummy);
close("C1_Volume");
selectWindow("C2-Merged");
run("Duplicate...", "title=[C2_Volume] duplicate frames=" + n_frames/2);
selectWindow("C2_Volume");
Stack.getStatistics(dummy, s2_volume, dummy, dummy, dummy);
close("C2_Volume");
coloc_array_3D = newArray(n_frames);
selectWindow("3D coloc");
for(a=1; a<=n_frames; a++){
	selectWindow("3D coloc");
	run("Duplicate...", "title=frame duplicate frames=" + a);
	selectWindow("frame");
	Stack.getStatistics(dummy, coloc_volume, dummy, dummy, dummy);
	coloc_array_3D[a-1] = coloc_volume;
	close("frame");
}
close("3D coloc");

//Measure 3D stretch coloc
selectWindow("C1_s");
run("Duplicate...", "title=[C1_Volume] duplicate frames=" + n_frames/2);
selectWindow("C1_Volume");
Stack.getStatistics(dummy, s1_volume_stretch, dummy, dummy, dummy);
close("C1_Volume");
selectWindow("C2_s");
run("Duplicate...", "title=[C2_Volume] duplicate frames=" + n_frames/2);
selectWindow("C2_Volume");
Stack.getStatistics(dummy, s2_volume_stretch, dummy, dummy, dummy);
close("C2_Volume");
coloc_stretch_array_3D = newArray(n_frames);
selectWindow("3D coloc stretch");
for(a=1; a<=n_frames; a++){
	selectWindow("3D coloc stretch");
	run("Duplicate...", "title=frame duplicate frames=" + a);
	selectWindow("frame");
	Stack.getStatistics(dummy, coloc_volume, dummy, dummy, dummy);
	coloc_stretch_array_3D[a-1] = coloc_volume;
	close("frame");
}
close("3D coloc stretch");

//Generate XY projection
selectWindow("C1-Merged");
run("Z Project...", "projection=[Sum Slices] all");
selectWindow("SUM_C1-Merged");
Stack.getStatistics(dummy, dummy, min, max, dummy);
setMinAndMax(min, max);
run("8-bit");
selectWindow("C2-Merged");
run("Z Project...", "projection=[Sum Slices] all");
selectWindow("SUM_C2-Merged");
Stack.getStatistics(dummy, dummy, min, max, dummy);
setMinAndMax(min, max);
run("8-bit");
run("Merge Channels...", "c1=[SUM_C1-Merged] c2=[SUM_C2-Merged] create");
selectWindow("Merged");
rename("SUM_3D XY merge");

//Generate XZ projection
selectWindow("C1-Merged");
run("TransformJ Turn", "z-angle=0 y-angle=0 x-angle=270");
close("C1-Merged");
selectWindow("C1-Merged turned");
run("Z Project...", "projection=[Sum Slices] all");
selectWindow("SUM_C1-Merged turned");
Stack.getStatistics(dummy, dummy, min, max, dummy);
setMinAndMax(min, max);
run("8-bit");
selectWindow("C2-Merged");
run("TransformJ Turn", "z-angle=0 y-angle=0 x-angle=270");
close("C2-Merged");
selectWindow("C2-Merged turned");
run("Z Project...", "projection=[Sum Slices] all");
selectWindow("SUM_C2-Merged turned");
Stack.getStatistics(dummy, dummy, min, max, dummy);
setMinAndMax(min, max);
run("8-bit");
run("Merge Channels...", "c1=[SUM_C1-Merged turned] c2=[SUM_C2-Merged turned] create");
close("C1-Merged turned");
close("C2-Merged turned");
selectWindow("Merged");
rename("SUM_3D merge turned");

//Generate XZ stretch projection
selectWindow("C1_s");
run("TransformJ Turn", "z-angle=0 y-angle=0 x-angle=270");
close("C1_s");
selectWindow("C1_s turned");
run("Z Project...", "projection=[Sum Slices] all");
selectWindow("SUM_C1_s turned");
Stack.getStatistics(dummy, dummy, min, max, dummy);
setMinAndMax(min, max);
run("8-bit");
selectWindow("C2_s");
run("TransformJ Turn", "z-angle=0 y-angle=0 x-angle=270");
close("C2_s");
selectWindow("C2_s turned");
run("Z Project...", "projection=[Sum Slices] all");
selectWindow("SUM_C2_s turned");
Stack.getStatistics(dummy, dummy, min, max, dummy);
setMinAndMax(min, max);
run("8-bit");
run("Merge Channels...", "c1=[SUM_C1_s turned] c2=[SUM_C2_s turned] create");
close("C1_s turned");
close("C2_s turned");
selectWindow("Merged");
rename("SUM_3D stretch merge turned");

//Tile movies
newImage("blank", "8-bit composite-mode", i_width, i_height, 2, 1, n_frames);
run("Combine...", "stack1=[SUM_3D XY merge] stack2=[SUM_3D merge turned] combine");
selectWindow("Combined Stacks");
rename("1");
run("Combine...", "stack1=blank stack2=[SUM_3D stretch merge turned] combine");
selectWindow("Combined Stacks");
rename("2");
run("Combine...", "stack1=1 stack2=2");
selectWindow("Combined Stacks");
Stack.setChannel(1);
run("Green");
Stack.setChannel(2);
run("Magenta");
run("RGB Color", "frames");
setColor(255, 255, 255);
setForegroundColor(255, 255, 255);
makeLine(i_width, 0, i_width, i_height+i_depth);
run("Draw", "stack");
makeLine(0, i_height, 2*i_width, i_height);
run("Draw", "stack");
run("Select None");

//Add labels
close("3D XY merge");
if(show_coloc){
	selectWindow("Combined Stacks");
	makeText("3D XY Projection", 0, 0);
	run("Draw", "stack");
	makeText("3D XZ - High NA (Isotropic)", 0, i_height+1);
	run("Draw", "stack");
	makeText("3D XZ - Low NA (Anisotropic)", i_width+1, i_height+1);
	run("Draw", "stack");
	run("Select None");
	
	selectWindow("Combined Stacks");
	for(a=1; a<=n_frames; a++){
		selectWindow("Combined Stacks");
		Stack.setFrame(a);
		angle = round(360*(a-1)/(n_frames));
		string = "Relative Orientation: " + angle + "°\n\nIsotropic colocalization (High NA):\nGreen:Magenta = " + coloc_array_3D[a-1]/s1_volume + "\nMagenta:Green = " + coloc_array_3D[a-1]/s2_volume;
		string += "\n\nAnsotropic colocalization (Low NA):\nGreen:Magenta = " + coloc_stretch_array_3D[a-1]/s1_volume_stretch + "\nMagenta:Green = " + coloc_stretch_array_3D[a-1]/s2_volume_stretch;
		makeText(string, i_width+1, 0);
		run("Draw", "slice");
	}
	run("Select None");
}
setBatchMode("exit and display");



