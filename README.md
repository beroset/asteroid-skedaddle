# asteroid-skedaddle
 - [Features](#features)
 - [How to use it](#how-to-use-it)
 - [License](#license-information)

In English "skedaddle" is verb meaning "to run off hastily."  `asteroid-skedaddle` is an outdoor exercise log application that runs on [AsteroidOS](https://asteroidos.org/).  Although initially concieved and developed as a running app, it can be used to track other outdoor exercise, such as bicycle rides, hiking, skiing, etc.  In short, any outdoor activity (so that satellite location services can be used) and that has you moving to different locations over time could be logged.  As such, when this descriptions uses "run", it can be construed to mean any of these kinds of activities, although currently there is no mechanism within the app to distinguish different activities.

![screenshot](https://github.com/beroset/asteroid-skedaddle/raw/main/screenshot.jpg?raw=true, "screen shot")

## Features

 * Preserves your privacy - no data is uploaded anywhere, ever.  Your data is yours.
 * Logs the exercise in [GPX format](https://www.topografix.com/gpx.asp)
 * Uses satellite global positioning on the watch for location
 * Shows number of satellites and currently used satellites for positioning
 * Shows total distance and elapsed time during your exercise
 * Keeps the display on for easy reference during your exercise
 * Spoken updates every half kilometer tells you distance, total time and current pace
 * Multiple languages support

## How to use it
If you're going out for a run (or some other outdoor exercise), you can use this application on your watch to both time/track the run and also to get spoken updates up to every half kilometer.  

### Set up
The first thing to do is to configure the application.  It will remember your preferences, so you need only do this once (or as often as your preference changes).  Tap the "gear" button on the right side of the main screen to enter configuration.  It has two controls:  at the top is a control to set spoken updates, and at the bottom is a control to use miles (or the default, which is kilometers).  They interact, so if you are using kilometers, the speech control will list "off", "half kilometer", and "kilometer" as the three selectable spoken update frequencies.  If you have chosen to use miles, your choices are "off", "half mile" and "mile".  After selecting your chosen preferences, you can swipe right to return to the main screen.

### Wait for satellites
Without location information, the application can't tell how far you have run, so it is little more than a stopwatch without that.  For this reason, you may want to wait a moment to let the watch acquire the location satellites needed to track your distance.  The main screen has two numbers: "sats" and "used" that report how many satellites are "seen" by the watch and how many are in use to determine location.  Geosynchronous satellites are very far away (22,500 km) and the watch's antenna is small, so it often needs a bit of time to acquire the satellite signals.  Accurate positioning requires at least 3 satellites, so the "used" number is color coded.  It is red (really light pink) if the number of satellites is 0, light yellow if the number of satellites is 1, 2, or 3, and light green if the number of satellites is 4 or more.  The more satellites used the better the accuracy.  Due to the way satellite positioning works, it can take up 12 minutes for the watch to get a location, so leave a little extra time before your run.  Also, depending on your location (e.g. dense urban vs. flat fields) and whether you're outdoors or indoors (and if you're inside, the construction of the building you're in) the very weak satellite signals are even harder for the watch to receive, so accuracy may suffer.

### Go run!
Once your watch shows the number of "used" satellites in green, you can start your run.  Do this by pressing the "play" button (triangle icon) on the left side of the screen.  As you run, the distance at the top of the screen and the time at the bottom of the screen will track your progress.  In the middle right, between "used" and the gear icon, the current local time is displayed.  While the application is running, the display will stay on continuously, overriding the usual screen blanking that happens in AsteroidOS.  This is deliberate to keep the satellite tracking "awake" and updating your location every second, but it will use a little more battery power than the usual mode.  For that reason, it's usually best to start a run with a fully charged battery.

### Cool down
After your run, hit the "pause" button, which is in the same location on the screen as the "play" button was before you started.  Your distance and time will stop updating.  The other thing that happens is that the recording of your run will be saved as a file on your watch under the `/home/ceres` directory with a name like `runlog2025-03-20T14:34:42.135Z.gpx`.  The `runlog` at the beginning of the file name and the `.gpx` at the end are fixed and unchanging, but the part in the middle is the date and time in [ISO 8601 format](https://en.wikipedia.org/wiki/ISO_8601).  Because the code uses the javascript [`toISOString()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/toISOString) function internally, this time is always in [UTC](https://en.wikipedia.org/wiki/Coordinated_Universal_Time).  (You *do* have your watch set to the correct timezone, don't you?)  You can move this file from your watch to a computer for further analysis if you like.  The file is in standard [GPX format](https://www.topografix.com/gpx.asp), so one convenient way of plotting your running route from your computer is to use a tool like [GPX studio](https://gpx.studio/).

### Some technical notes
Location data accuracy is largely a function of the watch hardware and how many satellites are being used to track.  I have done some testing by using my phone and watch simultaneously to track a few runs.  Unsurprisingly, the accuracy is much higher on the phone but that is for several reasons:
 1. phones use their cellular communications to both download satellite location data and to get an initial fix on location
 2. some phones use local tower identifications or WiFi hotspot mapping to augment location data
 3. some phones use inertial sensors (gyroscopes and accelerometers) to further augment location data

If you use this app and run often, to avoid filling all of the space on your watch, you will need to occasionally delete files from the watch.  There is currently no provision to do this through the app.

## License Information

asteroid-skedaddle is released under the [GPL version 3](LICENSE) license.
