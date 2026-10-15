import UIKit

/// Launch-environment switches shared with the Flutter example, so one script
/// drives both: `VIB_SCENE` picks the page, `VIB_DARK` the interface style.
enum Parity {
    static let env = ProcessInfo.processInfo.environment
    static let scene = env["VIB_SCENE"] ?? "card"
    static let dark = env["VIB_DARK"] == "1"
}

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting session: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "Default", sessionRole: session.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: scene)
        window.overrideUserInterfaceStyle = Parity.dark ? .dark : .light
        let controller: UIViewController
        switch Parity.scene {
        case "dump": controller = DumpViewController()
        case "swatches": controller = SwatchesViewController()
        default: controller = CardViewController()
        }
        window.rootViewController = controller
        self.window = window
        window.makeKeyAndVisible()
    }
}
