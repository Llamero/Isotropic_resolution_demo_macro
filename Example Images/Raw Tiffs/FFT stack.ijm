i=getTitle();
slices = nSlices;
setBatchMode(true);
for(a=1; a<=slices; a++){
	showProgress(a, slices);
	selectWindow(i);
	setSlice(a);
	run("FFT");
	selectWindow("FFT of " + i);
	if(isOpen("FFT Stack")) run("Concatenate...", "  title=[FFT Stack] image1=[FFT Stack] image2=[FFT of " + i + "] image3=[-- None --]");
	else run("Duplicate...", "title=[FFT Stack]");
	
}
setBatchMode("exit and display");
selectWindow("FFT Stack");
run("Log", "stack");