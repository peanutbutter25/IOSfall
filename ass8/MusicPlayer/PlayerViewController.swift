import UIKit
import AVFoundation

/// Layout lives entirely in Main.storyboard.
/// This class only keeps player state and refreshes the screen from it.
final class PlayerViewController: UIViewController {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!

    // MARK: - State (single source of truth)

    private let tracks = TrackLibrary.tracks
    private var currentIndex = 0
    private var isPlaying = false

    /// Stored property: the player lives as long as the screen does.
    private var player: AVAudioPlayer?

    private var currentTrack: Track { tracks[currentIndex] }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAudioSession()
        loadCurrentTrack()
        updateUI()
    }

    // MARK: - Actions

    @IBAction func playPauseTapped(_ sender: UIButton) {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            startPlayback()
        }
        updateUI()
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        switchTrack(by: 1)
    }

    @IBAction func previousTapped(_ sender: UIButton) {
        switchTrack(by: -1)
    }

    // MARK: - Player logic

    /// Moves to another track with wrap-around and keeps the play state.
    private func switchTrack(by step: Int) {
        guard !tracks.isEmpty else { return }
        let wasPlaying = isPlaying
        player?.stop()
        isPlaying = false

        currentIndex = (currentIndex + step + tracks.count) % tracks.count
        loadCurrentTrack()

        if wasPlaying {
            startPlayback()
        }
        updateUI()
    }

    /// Creates a new AVAudioPlayer for the current track.
    /// A missing or broken file never crashes the app.
    private func loadCurrentTrack() {
        player = nil
        let track = currentTrack

        guard let url = Bundle.main.url(forResource: track.fileName, withExtension: track.fileExtension) else {
            print("⚠️ File not found in bundle: \(track.fileName).\(track.fileExtension)")
            showError("Can't find the file for “\(track.title)”.")
            return
        }

        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.delegate = self
            newPlayer.prepareToPlay()
            player = newPlayer
        } catch {
            print("⚠️ Can't play \(url.lastPathComponent): \(error.localizedDescription)")
            showError("Can't play “\(track.title)”.")
        }
    }

    private func startPlayback() {
        guard let player else {
            isPlaying = false
            return
        }
        isPlaying = player.play()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("⚠️ Audio session error: \(error.localizedDescription)")
        }
    }

    // MARK: - UI

    /// Refreshes the whole screen from the current state.
    private func updateUI() {
        let track = currentTrack
        if let cover = UIImage(named: track.coverImageName) {
            coverImageView.image = cover
        } else {
            print("⚠️ Cover not found: \(track.coverImageName)")
            coverImageView.image = UIImage(systemName: "music.note")
        }
        titleLabel.text = track.title
        artistLabel.text = track.artist

        let symbol = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: symbol), for: .normal)
        playPauseButton.accessibilityLabel = isPlaying ? "Pause" : "Play"
    }

    private func showError(_ message: String) {
        // Before the screen is on-screen an alert can't be shown; the print above covers that case.
        guard view.window != nil, presentedViewController == nil else { return }
        let alert = UIAlertController(title: "Playback error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - AVAudioPlayerDelegate

extension PlayerViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            // Still "playing" in our state, so the next track starts automatically.
            self.switchTrack(by: 1)
        }
    }
}
