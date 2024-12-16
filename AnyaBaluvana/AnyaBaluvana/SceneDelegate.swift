import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        let productsViewController = ProductsViewController(viewModel: InventoryViewModel())
        productsViewController.tabBarItem = UITabBarItem(title: "Products", image: UIImage(systemName: "bag"), tag: 0)
        let navigationController = UINavigationController(rootViewController: productsViewController)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [navigationController]

        tabBarController.tabBar.isTranslucent = false

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()

        self.window = window
    }
}
