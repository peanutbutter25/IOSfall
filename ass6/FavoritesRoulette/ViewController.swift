import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var spinButton: UIButton!

    private let favorites = Favorite.all
    /// Index of the favorite currently on the card (nil = initial state).
    private var currentIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        styleViews()
        showInitialState()
    }

    // MARK: - Actions

    @IBAction func spinTapped(_ sender: UIButton) {
        guard let index = nextRandomIndex() else { return }
        currentIndex = index
        show(favorites[index])
    }

    // MARK: - Logic

    /// Random index that is never equal to the one currently shown,
    /// so the same favorite can't appear twice in a row.
    private func nextRandomIndex() -> Int? {
        var candidates = Array(favorites.indices)
        if let current = currentIndex {
            candidates.removeAll { $0 == current }
        }
        return candidates.randomElement()
    }

    // MARK: - UI

    private func showInitialState() {
        favoriteImageView.image = UIImage(named: "start")
        titleLabel.text = "Hungry?"
        descriptionLabel.text = "Tap Spin and the roulette will pick one of my 10 favorite dishes for you."
    }

    private func show(_ favorite: Favorite) {
        // Image, title and description are updated together in one transition.
        UIView.transition(with: cardView,
                          duration: 0.35,
                          options: [.transitionFlipFromLeft, .allowUserInteraction]) {
            self.favoriteImageView.image = UIImage(named: favorite.imageName)
            self.titleLabel.text = favorite.title
            self.descriptionLabel.text = favorite.description
        }
    }

    private func styleViews() {
        cardView.layer.cornerRadius = 24
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.12
        cardView.layer.shadowRadius = 14
        cardView.layer.shadowOffset = CGSize(width: 0, height: 6)

        spinButton.layer.cornerRadius = 28
        spinButton.layer.shadowColor = UIColor.black.cgColor
        spinButton.layer.shadowOpacity = 0.18
        spinButton.layer.shadowRadius = 8
        spinButton.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
}
