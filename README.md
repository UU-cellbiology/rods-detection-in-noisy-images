Rods detection in noisy images
===

<img src="http://katpyxa.info/software/rods_detection_logo.png" align="right" style="padding:100px"/>This is a collection of [ImageJ](https://imagej.nih.gov/ij/)/[FIJI](http://fiji.sc/) macros for detection of rods (straight line segments of approximately same length) in noisy images and movies. Developed mostly for <i>in vitro</i> microtubule [gliding assays](https://www.youtube.com/watch?v=yRjU-bgfL0I), but can be applied to anything else (rod-shaped bacteria, etc). Uses [Template matching plugin]( https://sites.google.com/site/qingzongtseng/template-matching-ij-plugin) by Qingzong Tseng. 

In addition, contains Matlab scripts to link detections to tracks based on modified [SimpleTracker](https://nl.mathworks.com/matlabcentral/fileexchange/34040-simple-tracker) code by Jean-Yves Tinevez and tools to find tracks with directional runs (based on [this paper](https://www.nature.com/articles/ncomms14772)).  

For description and manual refer to <a href="https://github.com/ekatrukha/rods-detection-in-noisy-images/wiki"><strong>Wiki page</strong></a>.   
Main topics:   
* **[How to install and run rods detection (ImageJ macro)](https://github.com/ekatrukha/rods-detection-in-noisy-images/wiki/How-to-install-and-run-rods-detection-%28ImageJ-macro%29)** 
* **[How to compose detection to tracks (Matlab)](https://github.com/ekatrukha/rods-detection-in-noisy-images/wiki/How-to-compose-detection-to-tracks-%28Matlab%29)**
* **[How does detection work?](https://github.com/ekatrukha/rods-detection-in-noisy-images/wiki/How-does-detection-work%3F)**
* **[Rods enchancement filter](https://github.com/ekatrukha/rods-detection-in-noisy-images/wiki/Rods-enhancement-filter-%28ImageJ-macro%29)**

Alternatively, to detect and track rods in movies with high signal-to-noise ratio, you can use [FIESTA](https://www.bcube-dresden.de/fiesta/wiki/Configuration) package from Stephan Diez lab, based on [this publication](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3117161/).


<br />
<br />
Developed in <a href='http://cellbiology.science.uu.nl/'>Cell Biology group</a> of Utrecht University.   
 
<a href="mailto:katpyxa@gmail.com">E-mail</a> for any questions.
