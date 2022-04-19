# SwiftUI YouTube Player for iOS and MacOS

Fully functional, SwiftUI-ready YouTube player for iOS 14+ and MacOS 11+. Actions and state are both delivered via SwiftUI `@Binding`s, meaking it dead-easy to integrate into any existing SwiftUI View.

![Preview iOS](https://github.com/globulus/swiftui-youtube-player/blob/main/Images/preview_ios.gif?raw=true)

## Installation

This component is distributed as a **Swift package**. Just add this repo's URL to XCode:

```text
https://github.com/globulus/swiftui-youtube-player
```

## How to use

* Pass the **config** parameter to optionally set various player properties:
  + `playInline`
  + `allowsControls`
  + `showInfo`
 * The **action** binding is used to control the player - whichever action you want it to perform, just set the variable's value to it. Available actions:
   + `idle` - does nothing and can be used as the default value.
   + `load(URLRequest)` - loads the video from the provided URL.
   + `loadID(String)` - loads the video based on its YouTube ID.
   + `loadPlaylistId(String)` - loads a playlist based on its YouTube ID.
   + `mute`
   + `unmute`
   + `play`
   + `pause`
   + `stop`
   + `clear`
   + `seek(Float, Bool` - seeks the given position in the video.
   + `duration` - evaluates the video's duration and updates the state.
   + `currentTime` - evaluates the current play time and updates the state.
   + `previous`
   + `next`
 * The **state** binding reports back the current state of the player. Available data:
   + `ready` - `true` if the player is ready to play a video.
   + `status` - `unstarted, ended, playing, paused, buffering, queued`
   + `quality` - `small, medium, large, hd720, hd1080, highResolution`
   + `duration` -  will be set after the `duration` action is invoked.
   + `currentTime` -  will be set after the `currentTime` action is invoked.
   + `error` - set if an error ocurred while playing the video, `nil` otherwise.
   
## Sample code

```swift
import SwiftUIYouTubePlayer

struct YouTubeTest: View {
    @State private var action = YouTubePlayerAction.idle
    @State private var state = YouTubePlayerState.empty
    
    private var buttonText: String {
        switch state.status {
        case .playing:
            return "Pause"
        case .unstarted,  .ended, .paused:
            return "Play"
        case .buffering, .queued:
            return "Wait"
        }
    }
    private var infoText: String {
        "Q: \(state.quality)"
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("Load") {
                    action = .loadID("v1PBptSDIh8")
                }
                Button(buttonText) {
                    if state.status != .playing {
                        action = .play
                    } else {
                        action = .pause
                    }
                }
                Text(infoText)
                Button("Prev") {
                    action = .previous
                }
                Button("Next") {
                    action = .next
                }
            }
            YouTubePlayer(action: $action, state: $state)
            Spacer()
        }
    }
}
```

## Recipe

For a more detailed description of the code, [visit this recipe](https://swiftuirecipes.com/blog/swiftui-play-youtube-video). Check out [SwiftUIRecipes.com](https://swiftuirecipes.com) for more **SwiftUI recipes**!

## Acknowledgements

 * The component internally uses [SwiftUI WebView](https://github.com/globulus/swiftui-webview) to render YouTube content.
 * Most functionality was inspired by the [Swift YouTube Player](https://github.com/gilesvangruisen/Swift-YouTube-Player) component.

## Changelog

* 1.0.2 - Fixed player vars, code cleanup.
* 1.0.1 - Update to work with SwiftUIWebView 1.0.5.
* 1.0.0 - Initial release.
