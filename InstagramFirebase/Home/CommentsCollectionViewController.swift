//
//  CommentsCollectionViewController.swift
//  InstagramFirebase
//
//  Created by Timur Saidov on 06/02/2019.
//  Copyright © 2019 Timur Saidov. All rights reserved.
//

import UIKit

class CommentsCollectionViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .red
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Comments"
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.black, for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        containerView.addSubview(sendButton)
        sendButton.anchor(top: containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 50, height: 0)
        sendButton.addTarget(self, action: #selector(handleSendComment), for: .touchUpInside)
        
        let textField = UITextField()
        textField.placeholder = "Enter comment"
        containerView.addSubview(textField)
        textField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: sendButton.leftAnchor , paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        return containerView
    }()
    
    @objc func handleSendComment() {
        
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}
