//"{\n\"width\":\"100%\",\n\"height\":\"100%\",\n\"playerVars\":{\n\"playsinline\":0,\n\"controls\":0,\n\"showinfo\":0\n},\n\"events\":{\n\"onPlaybackQualityChange\":\"onPlaybackQualityChange\",\n\"onStateChange\":\"onStateChange\",\n\"onReady\":\"onReady\",\n\"onError\":\"onPlayerError\"\n},\n\"videoId\":\"dQw4w9WgXcQ\"\n}"

struct YouTubePlayerParameters: Encodable {
    let events = Events()
    let height = "100%"
    let width = "100%"
    
    var playerVars: YouTubePlayerConfig = .default
    var videoId: String?
}

struct Events: Encodable {
    let onPlaybackQualityChange = "onPlaybackQualityChange"
    let onStateChange = "onStateChange"
    let onReady = "onReady"
    let onError = "onPlayerError"
}
