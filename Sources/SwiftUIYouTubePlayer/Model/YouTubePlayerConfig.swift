public struct YouTubePlayerConfig {
    let playInline: Bool
    let allowControls: Bool
    let showInfo: Bool
    
    public init(playInline: Bool,
                allowControls: Bool,
                showInfo: Bool) {
        self.playInline = playInline
        self.allowControls = allowControls
        self.showInfo = showInfo
    }
    
    public static let `default` = YouTubePlayerConfig(playInline: true,
                                                      allowControls: false,
                                                      showInfo: false)
}
