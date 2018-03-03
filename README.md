# cairo-ios-gles
Implementation of the cairo library using OpenGL ES 

This is the test harness and main project used while porting Cairo-GL to iOS. This completely builds from source now just need to include a guide for building. All that comes down to is getting the missing projects into the main build system and they have all been included now in the WolfSpider code. The goal was not only to run Cairo and 60fps (of course this is not at full resolution yet but possible to tune for this and more) but create a custom multiplatform build system from complete source. iOS works and Android is *known to work* so once that is demonstrated than this part will be complete. Cairo holds many secrets and the *way* it handles cross platform has almost as much value as the technology itself. So...yes blobs are being removed in the spirit of open source. Very WIP for now but good enough to get it up here on GH.

Just click on the images to view these videos on YouTube

[![Cairo IOS](http://i3.ytimg.com/vi/6RsNPNRoXqo/maxresdefault.jpg)](https://youtu.be/6RsNPNRoXqo)

[![Cairo IOS](http://i3.ytimg.com/vi/C4VR_YXZays/maxresdefault.jpg)](https://youtu.be/C4VR_YXZays)


