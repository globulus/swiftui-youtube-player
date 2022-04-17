public struct YouTubePlayerConfig: Encodable {
    var playInline: Bool
    var allowControls: Bool
    var showInfo: Bool
    var listType: String?
    var list: String?
    
    public init(
        playInline: Bool = true,
        allowControls: Bool = false,
        showInfo: Bool = true
    ) {
        self.playInline = playInline
        self.allowControls = allowControls
        self.showInfo = showInfo
    }
    
    public static var `default`: Self {
        .init(
            playInline: true,
            allowControls: false,
            showInfo: false
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case playInline = "playsinline"
        case allowControls = "controls"
        case showInfo = "showinfo"
        case listType
        case list
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(playInline ? 1 : 0, forKey: .playInline)
        try container.encode(allowControls ? 1 : 0, forKey: .allowControls)
        try container.encode(showInfo ? 1 : 0, forKey: .showInfo)
        try container.encode(listType, forKey: .listType)
        try container.encode(list, forKey: .list)
    }
}
