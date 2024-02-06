<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

Batteries included audio util package

## About

I needed a quick way to scaffold applications that needed audio in flutter,
and I needed them to work on all platforms without any additional setup.

Without this library, I would have to write all player logic, controller classes and do the state management manually.

This library allows you to hit the ground running. Just do the initial device-specific setup, and you are good to go.

## QuickStart
Step 1. include the lib in ``pubspec.yml``

```yaml
  vinyl:
    git:
      url: https://github.com/RA341/vinyl
      ref: [latest commit reference]

```

Step 2. Setup according to the [specific platforms](#getting-started) 

Step 3. Initialize Vinyl
```dart
Future<void> main() async {
  ....
  await vinyl.init(AudioConfig(...)) // if you need background player support
  // or
  await vinyl.init() // if you don't
  ....
  runapp()
}
```

Step 4. You are good to go 

Just call ``vinyl.player`` to get access player methods and metadata.  

### Please Note
Who this library isn't for 

If you need more customization with the audio player, this may not be the library.

While I tried to have most features accessible, you do lose the granularity that comes with doing the setup code yourself.

If you feel something is lacking, feel free to open an issue


## Getting started

### Setup platforms for background audio

All instructions are taken from [Audio service](https://pub.dev/packages/audio_service)

#### Android

These instructions assume that your project follows the Flutter 1.12 project template or later. If
your project was created prior to 1.12 and uses the old project structure, you can update your
project to follow the new project template.

1. Make the following changes to your project's AndroidManifest.xml file:

```xml

<manifest xmlns:tools="http://schemas.android.com/tools" ...><!-- ADD THESE TWO PERMISSIONS -->
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />

<application ...>
    ...

    <!-- EDIT THE android:name ATTRIBUTE IN YOUR EXISTING "ACTIVITY" ELEMENT -->
<activity android:name="com.ryanheise.audioservice.AudioServiceActivity" ...>...</activity>

    <!-- ADD THIS "SERVICE" element -->
    <service android:name="com.ryanheise.audioservice.AudioService"
    android:foregroundServiceType="mediaPlayback" android:exported="true" tools:ignore="Instantiatable">
    <intent-filter>
        <action android:name="android.media.browse.MediaBrowserService" />
    </intent-filter>
    </service>
    
        <!-- ADD THIS "RECEIVER" element -->
    <receiver android:name="com.ryanheise.audioservice.MediaButtonReceiver" android:exported="true"
    tools:ignore="Instantiatable">
    <intent-filter>
        <action android:name="android.intent.action.MEDIA_BUTTON" />
    </intent-filter>
    </receiver></application></manifest>
```

Note: when targeting Android 12 or above, you must set android:exported on each component that has
an intent filter (the main activity, the service and the receiver). If the manifest merging process
causes "Instantiable" lint warnings, use tools:ignore="Instantiable" (as above) to suppress them.

If you use any custom icons in notification, create the file android/app/src/main/res/raw/keep.xml
to prevent them from being stripped during the build process:
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources xmlns:tools="http://schemas.android.com/tools"
tools:keep="@drawable/*" />
```
By default plugin's default icons are not stripped by R8. If you don't use them, you may selectively
strip them. For example, the rules below will keep all your icons and discard all the plugin's:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources xmlns:tools="http://schemas.android.com/tools"
tools:keep="@drawable/*"
tools:discard="@drawable/audio_service_*"
/>
```
For more information about shrinking see Android documentation.
Custom Android activity

If your app needs to use its own custom activity, make sure you update your AndroidManifest.xml file
to reference your activity's class name instead of AudioServiceActivity. For example, if your
activity class is named MainActivity, then use:

```xml
<activity android:name=".MainActivity" ...>
```

Depending on whether you activity is a regular Activity or a FragmentActivity, you must also include
some code to link to audio_service's shared FlutterEngine. The easiest way to accomplish this is to
inherit that code from one of audio_service's provided base classes.

Integration as an Activity:

```kotlin
import com.ryanheise.audioservice.AudioServiceActivity;

class MainActivity extends AudioServiceActivity {
// ...
}
```

Integration as a FragmentActivity:

```kotlin
import com.ryanheise.audioservice.AudioServiceFragmentActivity;

class MainActivity extends AudioServiceFragmentActivity {
// ...
}
```

You can also write your own activity class from scratch, and override the provideFlutterEngine,
getCachedEngineId and shouldDestroyEngineWithHost methods yourself. For inspiration, see the source
code of the provided AudioServiceActivity and AudioServiceFragmentActivity classes.

#### IOS

Insert this in your Info.plist file:
```
<key>UIBackgroundModes</key>
<array>
<string>audio</string>
</array>
```
The example project may be consulted for context.

Note that the audio background mode permits an app to run in the background only for the purpose of playing audio. The OS may kill your process if it sits idly without playing audio, for example, by using a timer to sleep for a few seconds. If your app needs to pause for a few seconds between audio tracks, consider playing a silent audio track to create that effect rather than using an idle timer.

#### MacOS

Insert this in your Info.plist file:

<key>UIBackgroundModes</key>
<array>
<string>audio</string>
</array>

The example project may be consulted for context.

Note that the audio background mode permits an app to run in the background only for the purpose of playing audio. The OS may kill your process if it sits idly without playing audio, for example, by using a timer to sleep for a few seconds. If your app needs to pause for a few seconds between audio tracks, consider playing a silent audio track to create that effect rather than using an idle timer.

#### Web

No Additional setup required

#### Windows

Not supported

#### Linux

### Initialize Vinyl

AudioServiceConfig is required for background audio read more about [here](https://pub.dev/packages/audio_service)

**Note**

'vinyl' is a helper variable for your convenience.

Callable from anywhere, will always return the initialized instance of Vinyl

Vinyl itself is a singleton and will always have only single instance

Internally it is initialized like so
```vinyl = Vinyl.i;```


if you need to use background player

```dart
final config = AudioServiceConfig(....);
vinyl.init(audioConfig:config);
```

Without background
```dart
vinyl.init();
```


## Usage
All media methods are accessed using the player controller

```dart
vinyl.player
```

```dart
vinyl.player.play()
vinyl.player.pause()
vinyl.player.loadMedia()
.....
```

More Information can be found in [example](/example/)

## Credits

This library is a helpful wrapper around the excellent work done by authors of mediakit and audioservice.

Please consider supporting them if you can

[Mediakit](https://github.com/media-kit/media-kit)

[audio_service](https://pub.dev/packages/audio_service)

Inspired by the blog written by sugrach

https://suragch.medium.com/background-audio-in-flutter-with-audio-service-and-just-audio-3cce17b4a7d

## Contributing

Anyone is welcome is contribute, as usual fork the repo make your changes and open a pull request.

