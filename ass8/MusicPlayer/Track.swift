import Foundation

/// One song in the player.
struct Track {
    let title: String
    let artist: String
    /// Audio file name in the app bundle, without extension.
    let fileName: String
    /// Image set name in Assets.xcassets.
    let coverImageName: String
    let fileExtension: String = "m4a"
}
