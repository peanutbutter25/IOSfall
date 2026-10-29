# Lab · Music Player — UIStackView & Auto Layout

A single-screen music player in UIKit: track cover, title, artist and **Previous / Play-Pause / Next** controls that play real audio files bundled with the app.

## Screenshots

| iPhone SE (3rd gen) | iPhone 16 Pro Max |
|:---:|:---:|
| ![iPhone SE](Screenshots/se.png) | ![iPhone 16 Pro Max](Screenshots/promax.png) |

Screen recording (play, pause, next, previous, wrap-around): [`Screenshots/demo.mov`](Screenshots/demo.mov)

## Layout (Main.storyboard only)

```
rootStack            vertical, spacing 28, fill
├── coverImageView   aspect ratio 1:1, aspect fill, corner radius 20
├── labelsStack      vertical, spacing 6, fill
│   ├── titleLabel
│   └── artistLabel
└── controlsStack    horizontal, distribution Fill Equally, alignment Center
    ├── previousButton   backward.fill
    ├── playPauseButton  play.fill / pause.fill
    └── nextButton       forward.fill
```

Only 4 constraints in the whole screen:

- `rootStack.leading = Safe Area.leading + 20`
- `Safe Area.trailing = rootStack.trailing + 20`
- `rootStack.centerY = Safe Area.centerY`
- `coverImageView.width = coverImageView.height` (1:1)

Everything else is decided by the stack views' `axis`, `alignment`, `distribution` and `spacing`. No layout code in Swift: no `NSLayoutConstraint`, anchors, `frame =` or `addSubview`.

## Code

- `Track` — struct with `title`, `artist`, `fileName`, `coverImageName`.
- `TrackLibrary.tracks` — the only place where the 10 tracks are listed.
- `PlayerViewController`
  - keeps `currentIndex`, `isPlaying` and the `AVAudioPlayer` as stored properties (the player lives as long as the screen);
  - loads audio with `Bundle.main.url(forResource:withExtension:)`; a missing or broken file prints a message and shows an alert instead of crashing;
  - Next / Previous wrap around and keep the play state;
  - `audioPlayerDidFinishPlaying` starts the next track automatically;
  - `updateUI()` refreshes the whole screen from the state after every tap.

## Tracks

10 tracks in `MusicPlayer/Audio` (`.m4a`, ~0.6 MB each, all in the app target) and 10 covers in `Assets.xcassets`.
The music and covers were generated procedurally for this project, so they are original and royalty-free.

## Run

Open `MusicPlayer.xcodeproj`, choose an iPhone simulator and press **Run**. No extra setup needed.
