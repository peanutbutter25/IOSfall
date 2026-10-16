# Favorites Roulette 🎰🍜

Lab 6 — a single-screen iOS app that shows a random card with one of my **10 favorite dishes**.
Each tap on **Spin** flips the card and shows a new dish: an image, a title and a short description.

**Category:** Food — Beshbarmak, Plov, Manty, Baursaks, Shashlik, Pepperoni Pizza, Sushi, Ramen, Cheeseburger, Ice Cream.

## Screenshots

| Launch screen | Main screen | Home Screen icon |
|:---:|:---:|:---:|
| ![Launch screen](Screenshots/launch.png) | ![Main screen](Screenshots/main.png) | ![Home Screen](Screenshots/home.png) |

## How it works

- `Favorite` is a struct (`imageName`, `title`, `description`); all 10 favorites are stored in the array `Favorite.all`.
- On launch the card shows an initial state (roulette image, “Hungry?” and a hint), not empty views.
- `nextRandomIndex()` removes the currently shown index from the candidates before picking a random one, so the same favorite never appears twice in a row.
- Image, title and description are updated together inside a single flip transition.
- No force unwraps — optionals are handled with `guard let` / `if let`; `!` is used only in `@IBOutlet` declarations.

## Project details

- iOS App template · Interface: Storyboard · Language: Swift
- Display Name: **Favorites Roulette**
- Layout built in `Main.storyboard` with `UIImageView`, `UILabel` and `UIButton`
- **No Auto Layout:** *Use Auto Layout* is turned off in both storyboards, there are no constraints; views use autoresizing masks
- Images use *Aspect Fit* (never stretched); labels wrap and shrink so text is not cut off
- Custom `LaunchScreen.storyboard` in the app's colors, no constraints
- Custom `AppIcon` — 1024 × 1024 PNG without transparency
- Portrait, iPhone, iOS 16+

## Run

1. Open `FavoritesRoulette.xcodeproj` in Xcode.
2. Choose an iPhone simulator (e.g. iPhone 16) and press **Run** (⌘R).
