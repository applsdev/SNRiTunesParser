## SNRiTunesParser: libxml2 based iTunes library parser

`SNRiTunesParser` is a libxml2 based SAX parser for the iTunes Music Library XML file that I wrote hoping to achieve better performance than `NSDictionary`. Unfortunately, the project did not meet that goal (NSDictionary is as fast or faster in almost all cases) but I'm open sourcing it in case anyone wants it for learning purposes. 

It helped me learn more about libxml2, SAX style parsing, and other various bits of C programming that I hadn't had the need to use until now. A few details about the project:

- Should be compiled with ARC. That said, it would be easy to add a few lines of memory management code here and there and use it without ARC because the entire project (aside from the API) is written in C
- Parses everything that's present in the iTunes library XML file, including songs, videos, and playlists. Does not parse apps or ebooks.

**NOTE: Once again, I DO NOT recommend using this code in your projects. NSDictionary is as fast or faster in every case I've tested. This is for educational purposes only.**

## Adding SNRiTunesParser to your project

1. Link against `libxml2.dylib`.
2. Add `$(SDKROOT)/usr/include/libxml2` to the `Header Search Paths` in Project Settings

## Usage

```
SNRiTunesParser *parser = [SNRiTunesParser new];
[parser parse];
SNRiTunesPlaylist *music = parser.music;
for (SNRiTunesTrack *track in music.tracks) {
	NSLog(@"%@ by %@", track.name, track.artist);
}
```

## Who am I?

I'm Indragie Karunaratne, a 17 year old Mac OS X and iOS Developer from Edmonton AB, Canada. Visit [my website](http://indragie.com) to check out my work, or to get in touch with me. ([follow me](http://twitter.com/indragie) on Twitter!)

## Licensing

`SNRiTunesParser is licensed under the [BSD license](http://www.opensource.org/licenses/bsd-license.php).