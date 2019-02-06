//
//  MainTabBarController.swift
//  InstagramFirebase
//
//  Created by Timur Saidov on 05/02/2019.
//  Copyright © 2019 Timur Saidov. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        view.backgroundColor = .white
        
        print("MainTabBarController - \(#function)")
        print(Auth.auth().currentUser as Any)
        
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "loginSID") as! LoginViewController
                
                self.present(loginViewController, animated: true, completion: nil)
            }
        } else {
            DispatchQueue.main.async {
                let homeNavController = self.templateNavController(withIdentifier: "homeNavControllerSID", unselectedImage: "home_unselected", selectedImage: "home_selected")
                
                let searchNavController = self.templateNavController(withIdentifier: "searchNavControllerSID", unselectedImage: "search_unselected", selectedImage: "search_selected")
                
                let photoCollectionNavController = self.templateNavController(withIdentifier: "photoNavControllerSID", unselectedImage: "plus_unselected", selectedImage: "plus_unselected")
                
                let userProfileNavController = self.templateNavController(withIdentifier: "profileNavControllerSID", unselectedImage: "profile_unselected", selectedImage: "profile_selected")
                
                self.viewControllers = [homeNavController, searchNavController, photoCollectionNavController, userProfileNavController]
                
                self.tabBar.tintColor = .black
                
                guard let items = self.tabBar.items else { return }
                
                for item in items {
                    item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("MainTabBarController - \(#function)")
        print(Auth.auth().currentUser as Any)
    }
    
    func templateNavController(withIdentifier identifier: String, unselectedImage: String, selectedImage: String) -> UINavigationController {
        let navController = self.storyboard?.instantiateViewController(withIdentifier: identifier) as! UINavigationController
        
        navController.tabBarItem.image = UIImage(named: unselectedImage)
        navController.tabBarItem.selectedImage = UIImage(named: selectedImage)
        
        return navController
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.index(of: viewController)
        
        if index == 2 {
            let photoNavController = self.storyboard?.instantiateViewController(withIdentifier: "photoNavControllerSID") as! UINavigationController
            
            self.present(photoNavController, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
}
