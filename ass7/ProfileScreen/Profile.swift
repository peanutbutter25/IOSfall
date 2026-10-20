import Foundation

/// Data shown on the profile screen.
struct Profile {
    let initials: String
    let name: String
    let subtitle: String
    let posts: String
    let followers: String
    let following: String
    let about: String
}

extension Profile {
    static let sample = Profile(
        initials: "AB",
        name: "Aigerim Bekova",
        subtitle: "iOS Developer · Almaty",
        posts: "128",
        followers: "4.2K",
        following: "312",
        about: "Building banking apps in Swift. I like clean architecture, coffee and long walks in the mountains around Almaty."
    )

    /// Long text test from the assignment.
    static let longName = Profile(
        initials: "MH",
        name: "Maximilian Alexander von Habsburg",
        subtitle: "iOS Developer · Almaty",
        posts: "128",
        followers: "4.2K",
        following: "312",
        about: "Building banking apps in Swift. I like clean architecture, coffee and long walks in the mountains around Almaty."
    )
}
