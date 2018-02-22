# cairo-ios-gles
Implementation of the cairo library using OpenGL ES 

This is the test harness and main project used while porting Cairo-GL to iOS. libpixman-1 is for iPhone6/7 and works with iOS 10.3. 
libpixman-1_X86_64 is for the simulator and libpixman-1_armv7 is for my aging IPad 2 but the only way I can get into GL Frame Capture
since the iOS 10.3 update which broke it. I built pixman with a modified Mapnik makefile so there is nothing unique about it I just
need to sort out the makefile situation to get an end to end build. Very WIP for now but good enough to get it up here on GH.

Just click on the images to view these videos on YouTube

[![Cairo IOS](http://i3.ytimg.com/vi/6RsNPNRoXqo/maxresdefault.jpg)](https://youtu.be/6RsNPNRoXqo)

[![Cairo IOS](http://i3.ytimg.com/vi/C4VR_YXZays/maxresdefault.jpg)](https://youtu.be/C4VR_YXZays)


