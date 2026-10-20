import UIKit

/// All views and constraints live in Main.storyboard.
/// This class only fills the labels with data: no frames, constraints or anchors.
class ProfileViewController: UIViewController {

    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var postsCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var aboutTextLabel: UILabel!

    /// Set to `true` to run the long text test
    /// (name "Maximilian Alexander von Habsburg").
    private let runLongTextTest = false

    override func viewDidLoad() {
        super.viewDidLoad()
        show(runLongTextTest ? Profile.longName : Profile.sample)
    }

    private func show(_ profile: Profile) {
        initialsLabel.text = profile.initials
        nameLabel.text = profile.name
        subtitleLabel.text = profile.subtitle
        postsCountLabel.text = profile.posts
        followersCountLabel.text = profile.followers
        followingCountLabel.text = profile.following
        aboutTextLabel.text = profile.about
    }
}
