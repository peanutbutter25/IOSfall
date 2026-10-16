import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        // The window and the root view controller are loaded from Main.storyboard.
        guard scene is UIWindowScene else { return }
    }
}
