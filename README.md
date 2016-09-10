# msupcm

## A simple script for generating MSU-1 PCM audio files from source tracks

Dependencies
 * [sox](http://sox.sourceforge.net/)
 * [normalize-audio](http://normalize.nongnu.org/)
 * [wav2msu](https://github.com/jbaiter/wav2msu)
 
Currently runs on Windows, but all of the applications used are available on Linux, so there's nothing stopping me from converting the script to bash.

Tracks are added using a simple configuration file.

Supports different output filename conventions


Global config options
* Input filename prefix (for numbered tracks, so you don't have to specify every file name)
* Ouput filename convention
  * higan (track-#.pcm)
  * SD2SNES (romname-#.pcm)
  * same as original input filename
* Normalization (dBFS RMS)
* Custom effects (sox flags)

Track-specific config options
* Input filename
* Start point (sample #)
* End point (sample #)
* Loop point (sample #)
* Normalization (dBFS RMS)


### Usage

Place this script into the same directory as your source files, and the dependency applications into a subfolder named bin.  Populate the tracks.cfg file with your track configuration and run convert_tracks.bat.


### MP3 Files

sox supports MP3 files through the use of libmad.  The Windows build, by default does not come with libmad, so you must include libmad-0.dll and lbmp3lame-0.dll in the bin directory in order to use MP3 files.  These files are very difficult to find, for some reason, and the only known reliable download is ossbuild, which requires a 1.5GB download.  Another option would be to just convert the MP3 files to a lossless format like FLAC before processing them with this script.
