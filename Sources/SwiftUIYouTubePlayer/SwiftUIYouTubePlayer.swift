import SwiftUI
import SwiftUIWebView

/** Embed and control YouTube videos */
public struct YouTubePlayer: View {
    
    private static let webViewConfig = WebViewConfig(
        javaScriptEnabled: true,
        allowsBackForwardNavigationGestures: false,
        allowsInlineMediaPlayback: true,
        isScrollEnabled: false,
        isOpaque: true,
        backgroundColor: .clear
    )
    
    private static let playerHTML = """
        <!DOCTYPE html>
        <html>
            <head>
                <style>
                    * { margin: 0; padding: 0; }
                    html, body { width: 100%; height: 100%; }
                </style>
            </head>
            <body>
                <div id="player"></div>
                <script src="https://www.youtube.com/iframe_api"></script>
                <script>
                    var player;
                    YT.ready(function() {
                             player = new YT.Player('player', %@);
                             window.location.href = 'ytplayer://onYouTubeIframeAPIReady';
                             });
                             function onReady(event) {
                                 window.location.href = 'ytplayer://onReady?data=' + event.data;
                             }

                function onStateChange(event) {
                    window.location.href = 'ytplayer://onStateChange?data=' + event.data;
                }

                function onPlaybackQualityChange(event) {
                    window.location.href = 'ytplayer://onPlaybackQualityChange?data=' + event.data;
                }
                function onPlayerError(event) {
                    window.location.href = 'ytplayer://onError?data=' + event.data;
                }
                </script>
            </body>
        </html>
        """
    private static let getDurationCommand = "getDuration()"
    private static let getCurrentTimeCommand = "getCurrentTime()"
    
    @Binding var action: YouTubePlayerAction
    @Binding var state: YouTubePlayerState
    
    @State private var webViewAction = WebViewAction.idle
    @State private var webViewState = WebViewState.empty
    @State private var playerVars: YouTubePlayerConfig
    
    public init(
        action: Binding<YouTubePlayerAction>,
        state: Binding<YouTubePlayerState>,
        config: YouTubePlayerConfig = .default
    ) {
        _action = action
        _state = state
        _playerVars = State(initialValue: config)
    }

    public var body: some View {
        WebView(
            config: YouTubePlayer.webViewConfig,
            action: $webViewAction,
            state: $webViewState,
            schemeHandlers: ["ytplayer": handleJSEvent(_:)]
        )
        .onChange(of: action, perform: handleAction(_:))
        //.onChange(of: webViewState, perform: handleWebViewStateChange(_:))
    }
    
    private func handleAction(_ value: YouTubePlayerAction) {
        if value == .idle {
            return
        }
        switch value {
        case .idle:
            break
        case .loadURL(let url):
            if let id = videoIDFromYouTubeURL(url) {
                loadVideo(id: id)
            } else {
                onError(URLError(.badURL))
            }
        case .loadID(let id):
            loadVideo(id: id)
        case .loadPlaylistID(let id):
            // No videoId necessary when listType = playlist, list = [playlist Id]
            playerVars.listType = "playlist"
            playerVars.list = id
            let params = YouTubePlayerParameters(playerVars: playerVars)
            loadWebViewWithParameters(params)
        case .mute:
            evaluatePlayerCommand("mute()")
        case .unmute:
            evaluatePlayerCommand("unMute()")
        case .play:
            evaluatePlayerCommand("playVideo()")
        case .pause:
            evaluatePlayerCommand("pauseVideo()")
        case .stop:
            evaluatePlayerCommand("stopVideo()")
        case .clear:
            evaluatePlayerCommand("clearVideo()")
        case .seek(let seconds, let seekAhead):
            evaluatePlayerCommand("seekTo(\(seconds), \(seekAhead))")
        case .duration:
            evaluatePlayerCommand(YouTubePlayer.getDurationCommand) { result in
                if let value = result as? Double {
                    var newState = state
                    newState.duration = value
                    state = newState
                }
            }
        case .currentTime:
            evaluatePlayerCommand(YouTubePlayer.getCurrentTimeCommand) { result in
                if let value = result as? Double {
                    var newState = state
                    newState.currentTime = value
                    state = newState
                }
            }
        case .previous:
            evaluatePlayerCommand("previousVideo()")
        case .next:
            evaluatePlayerCommand("nextVideo()")
        }
        action = .idle
    }
    
    private func onError(_ error: Error) {
        var newState = state
        newState.error = error
        state = newState
    }
    
    private func loadVideo(id: String) {
        let params = YouTubePlayerParameters(
            playerVars: playerVars,
            videoId: id
        )
        loadWebViewWithParameters(params)
    }

    private func evaluatePlayerCommand(_ command: String, callback: ((Any?) -> Void)? = nil) {
        let fullCommand = "player.\(command);"
        webViewAction = .evaluateJS(fullCommand, { result in
            switch result {
            case .success(let value):
                callback?(value)
            case .failure(let error):
                if (error as NSError).code == 5 { // NOTE: ignore :Void return
                    callback?(nil)
                } else {
                    onError(error)
                }
            }
        })
    }

    // MARK: Player setup
    private func loadWebViewWithParameters(_ parameters: YouTubePlayerParameters) {
        let rawHTMLString = YouTubePlayer.playerHTML
        // Get JSON serialized parameters string
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(parameters)
        let jsonStr = String(data: jsonData, encoding: .utf8)!
        // Replace %@ in rawHTMLString with jsonParameters string
        let htmlString = rawHTMLString.replacingOccurrences(of: "%@", with: jsonStr)
        // Load HTML in web view
        webViewAction = .loadHTML(htmlString)
    }

    private func serializedJSON(_ object: AnyObject) -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
              let string = String(data: jsonData, encoding: .utf8)
        else {
            return nil
        }
        return string
    }

    // MARK: JS Event Handling
    private func handleJSEvent(_ eventURL: URL) {
        // Grab the last component of the queryString as string
        let data: String? = eventURL.queryStringComponents()["data"] as? String
        if let host = eventURL.host, let event = YouTubePlayerEvents(rawValue: host) {
            // Check event type and handle accordingly
            switch event {
            case .youTubeIframeAPIReady:
                var newState = state
                newState.iframeReady = true
                state = newState
            case .ready:
                var newState = state
                newState.ready = true
                state = newState
            case .statusChange:
                if let newStatus = YouTubePlayerStatus(rawValue: data!) {
                    var newState = state
                    newState.status = newStatus
                    state = newState
                }
            case .playbackQualityChange:
                if let newQuality = YouTubePlaybackQuality(rawValue: data!) {
                    var newState = state
                    newState.quality = newQuality
                    state = newState
                }
            }
        }
    }
}

// MARK: - Preview

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
            YouTubePlayer(action: $action, state: $state, config: .init(playInline: false))
                .aspectRatio(16/9, contentMode: .fit)
            Spacer()
        }
    }
}

struct YouTubePlayer_Previews: PreviewProvider {
    static var previews: some View {
        YouTubeTest()
    }
}
