import Foundation

public enum YouTubePlayerAction: Equatable {
    case idle
    case loadURL(URL)
    case loadID(String)
    case loadPlaylistID(String)
    case mute
    case unmute
    case play
    case pause
    case stop
    case clear
    case seek(Float, Bool)
    case duration
    case currentTime
    case previous
    case next
}
