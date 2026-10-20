# Assignment 7 · Auto Layout — Variant A (Profile)

A profile screen built in UIKit with a **Storyboard only**: every view and every constraint is set in Interface Builder.

- No `UIStackView`: everything is positioned with constraints.
- Swift code only fills in data (`ProfileViewController.show(_:)`). It never sets frames, creates constraints or uses anchors.
- Corner radii are set in Interface Builder via *User Defined Runtime Attributes* (`layer.cornerRadius`).

## Layout

| Element | Constraints |
|---|---|
| Avatar | width 96, height 96, centerX = safe area, top = safe area + 20, corner radius 48 (circle) |
| Name | top = avatar.bottom + 16, leading/trailing = safe area ± 16, `numberOfLines = 2`, centered |
| Subtitle | top = name.bottom + 6, leading/trailing ± 16 |
| Stats card | top = subtitle.bottom + 20, leading/trailing ± 16. Inside: 3 columns + 2 dividers (1 pt) chained left to right, **column 2 and 3 Equal Widths to column 1** |
| Follow / Message | height 48 each, 12 pt between them, **Message Equal Widths to Follow**, Message.top = Follow.top |
| About card | top = Follow.bottom + 24, leading/trailing ± 16. Text label: `numberOfLines = 0`, card height comes from the text (bottom = text.bottom + 16) |

Side margins are 16 pt from the safe area, so content never goes under the notch / Dynamic Island.

## Long text test

In `ProfileViewController.swift` set:

```swift
private let runLongTextTest = true
```

The name becomes **“Maximilian Alexander von Habsburg”**: it wraps to 2 lines, stays centered and pushes the rest of the screen down without overlaps.

## Checked on

- iPhone SE (3rd generation)
- iPhone 16 Pro Max

No red or orange warnings in the Document Outline and no “Unable to simultaneously satisfy constraints” in the console.

## Screenshots

| iPhone SE (3rd gen) | iPhone 16 Pro Max | Long text test |
|:---:|:---:|:---:|
| ![SE](Screenshots/se.png) | ![Pro Max](Screenshots/promax.png) | ![Long text](Screenshots/longtext.png) |
