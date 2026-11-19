import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    // NOTE (v0.1.1 crash fix): window creation was removed from here.
    // v0.1 created the UIWindow in didFinishLaunchingWithOptions, but the
    // app declares a scene manifest, so UIKit runs the scene lifecycle and
    // never uses an AppDelegate-owned window. With the iOS 27 SDK that is
    // a hard launch failure ("UIScene life cycle is required for apps
    // built with this SDK"). The window now lives in SceneDelegate.
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
}
