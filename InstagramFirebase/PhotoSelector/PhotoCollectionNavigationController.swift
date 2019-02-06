//
//  PhotoCollectionNavigationController.swift
//  InstagramFirebase
//
//  Created by Timur Saidov on 05/02/2019.
//  Copyright © 2019 Timur Saidov. All rights reserved.
//

import UIKit

class PhotoCollectionNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        print("PhotoCollectionNavigationController is loaded")
    }
}

extension UINavigationController {
    override open var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
}
