public struct YouTubePlayerState: Equatable {
    public internal(set) var ready: Bool
    public internal(set) var status: YouTubePlayerStatus
    public internal(set) var quality: YouTubePlaybackQuality
    public internal(set) var duration: Double?
    public internal(set) var currentTime: Double?
    public internal(set) var error: Error?
    internal var iframeReady: Bool
    
    public static let empty = YouTubePlayerState(ready: false,
                                                 status: .unstarted,
                                                 quality: .small,
                                                 duration: nil,
                                                 currentTime: nil,
                                                 error: nil,
                                                 iframeReady: false)
    
    public static func == (lhs: YouTubePlayerState, rhs: YouTubePlayerState) -> Bool {
        lhs.ready == rhs.ready
            && lhs.status == rhs.status
            && lhs.quality == rhs.quality
            && lhs.duration == rhs.duration
            && lhs.currentTime == rhs.currentTime
            && lhs.error?.localizedDescription == rhs.error?.localizedDescription
            && lhs.iframeReady == rhs.iframeReady
    }
}
