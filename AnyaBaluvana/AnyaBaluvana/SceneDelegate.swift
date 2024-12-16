import UIKit
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        let productsViewController = ProductsViewController(viewModel: InventoryViewModel())
        productsViewController.tabBarItem = UITabBarItem(title: "Products", image: UIImage(systemName: "bag"), tag: 0)
        let productsNavigationController = UINavigationController(rootViewController: productsViewController)

        let userViewController = UserViewController(viewModel: UserViewModel())
        let userNavigationController = UINavigationController(rootViewController: userViewController)
        userNavigationController.tabBarItem = UITabBarItem(title: "User", image: UIImage(systemName: "person"), tag: 1)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [productsNavigationController, userNavigationController]
        tabBarController.tabBar.isTranslucent = false

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()

        self.window = window
    }
}
