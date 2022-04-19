public enum YouTubePlayerEvents: String, Equatable {
    case youTubeIframeAPIReady = "onYouTubeIframeAPIReady"
    case ready = "onReady"
    case statusChange = "onStateChange"
    case playbackQualityChange = "onPlaybackQualityChange"
}
