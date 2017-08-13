//
//  CustomTabBarController.swift
//  FacebookMessenger
//
//  Created by Korita on 07.08.17.
//  Copyright © 2017 Korita. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        let friendsController = FriendsViewController(collectionViewLayout: layout)
        let recentMessagesNavController = UINavigationController(rootViewController: friendsController)
        recentMessagesNavController.tabBarItem.title = "Recent"
        recentMessagesNavController.tabBarItem.image = #imageLiteral(resourceName: "recent")
        viewControllers = [recentMessagesNavController, createNavViewController(title: "Calls", imageName: "calls"), createNavViewController(title: "Groups", imageName: "groups"), createNavViewController(title: "People", imageName: "people"), createNavViewController(title: "Settings", imageName: "settings")]
        
        
    }
    
    
    private func createNavViewController (title: String, imageName: String) -> UINavigationController {
        let viewController = UIViewController()
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        
        return navController

    }
}
