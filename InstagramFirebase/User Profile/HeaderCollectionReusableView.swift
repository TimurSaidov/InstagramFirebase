//
//  HeaderCollectionReusableView.swift
//  InstagramFirebase
//
//  Created by Timur Saidov on 05/02/2019.
//  Copyright © 2019 Timur Saidov. All rights reserved.
//

import UIKit

protocol UserProfileHeaderDelegate {
    func didChangeToListView()
    func didChangeToGridView()
}

class HeaderCollectionReusableView: UICollectionReusableView {
    
    var delegate: UserProfileHeaderDelegate?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var editProfileOrFollowButton: UIButton!
    @IBOutlet weak var gridButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var ribbonButton: UIButton!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var headerLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    
    override func awakeFromNib() {
        gridButton.tintColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)
        ribbonButton.tintColor = UIColor(white: 0, alpha: 0.2)
        
        gridButton.addTarget(self, action: #selector(handleChangeToGridButton), for: .touchUpInside)
        listButton.addTarget(self, action: #selector(handleChangeToListButton), for: .touchUpInside)
    }
    
    @objc func handleChangeToGridButton() {
        gridButton.tintColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToGridView()
    }
    
    @objc func handleChangeToListButton() {
        listButton.tintColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        gridButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToListView()
    }
}
