import UIKit

/// Scene delegate (new in v0.1.1 crash fix).
///
/// v0.1 had no scene delegate at all: AppDelegate created the window in
/// `application(_:didFinishLaunchingWithOptions:)`, while Info.plist
/// declared a `UIApplicationSceneManifest` with no `UISceneConfigurations`.
/// Under the scene lifecycle the AppDelegate window is never used, so no
/// window scene ever connected. With the iOS 27 SDK (local build,
/// Xcode 27.2) UIKit turns that into a hard launch failure:
/// "UIScene life cycle is required for apps built with this SDK."
/// This delegate owns the window instead; deployment target stays iOS 15.
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = ViewController()
        window.makeKeyAndVisible()
        self.window = window
    }
}
