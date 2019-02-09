//
//  CommentsCollectionViewController.swift
//  InstagramFirebase
//
//  Created by Timur Saidov on 06/02/2019.
//  Copyright © 2019 Timur Saidov. All rights reserved.
//

import UIKit
import Firebase

class CommentsCollectionViewController: UICollectionViewController, CommentInputAccessoryViewDelegate {
    
    var post: Post?
    
    let cellId = "cellId"
    
    var comments: [Comment] = []
    
    var count: Int = 0
    var currentCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Comments"
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.register(CommentsCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
        commentsCount()
        fetchComments()
    }
    
    fileprivate func commentsCount() {
        guard let postId = self.post?.id else { return }
        
        let reference = Database.database().reference().child("comments").child(postId)
        reference.observe(.value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            self.count = dictionary.keys.count
            print(self.count)
        }) { (error) in
            print("Failed to fetch comments count")
        }
    }
    
    fileprivate func fetchComments() {
        guard let postId = self.post?.id else { return }
        
        let reference = Database.database().reference().child("comments").child(postId)
        reference.observe(.childAdded, with: { (snapshot) in // .childAdded - поэтому при отправке комментария (send), он появляется на экране, то есть обновляется Collection View.
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            guard let uid = dictionary["uid"] as? String else { return }
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionaryOfUser = snapshot.value as? [String: Any] else { return }
                
                let user = User(uid: uid, dictionary: dictionaryOfUser)
                
                let comment = Comment(user: user, dictionary: dictionary)
                
                self.comments.append(comment)
                
                self.currentCount += 1
                if self.currentCount == self.count {
                    self.collectionView.reloadData()
                }
            }, withCancel: { (error) in
                print("Failed to fetch user", error)
            })
        }) { (error) in
            print("Failed to observe comments", error)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentsCollectionViewCell
        
        cell.comment = self.comments[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
//    let commentTextField: UITextField = {
//        let textField = UITextField()
//        textField.placeholder = "Enter comment"
//        return textField
//    }()
    
    lazy var containerView: CommentInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let commentInputAccessoryView = CommentInputAccessoryView(frame: frame)
        
        commentInputAccessoryView.delegate = self
        
        return commentInputAccessoryView
        
//        let containerView = UIView()
//        containerView.backgroundColor = .white
//        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
//        
//        let sendButton = UIButton(type: .system)
//        sendButton.setTitle("Send", for: .normal)
//        sendButton.setTitleColor(.black, for: .normal)
//        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
//        containerView.addSubview(sendButton)
//        sendButton.anchor(top: containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 50, height: 0)
//        sendButton.addTarget(self, action: #selector(handleSendComment), for: .touchUpInside)
//        
//        containerView.addSubview(commentTextField)
//        commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: sendButton.leftAnchor , paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
//        
//        let lineSeparatorView = UIView()
//        lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
//        containerView.addSubview(lineSeparatorView)
//        lineSeparatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
//        
//        return containerView
    }()
    
//    @objc func handleSendComment() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//
//        let postId = self.post?.id ?? ""
//        let values = ["text": commentTextField.text ?? "", "creationDate": Date().timeIntervalSince1970, "uid": uid] as [String: Any]
//
//        Database.database().reference().child("comments").child(postId).childByAutoId().updateChildValues(values) { (err, ref) in
//            if let error = err {
//                print("Failed to inser comment:", error)
//            }
//
//            print("Successfully inserted comment")
//        }
//
//        commentTextField.text = ""
//    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // Метод протокола CommentInputAccessoryViewDelegate.
    func didSend(comment: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let postId = self.post?.id ?? ""
        let values = ["text": comment, "creationDate": Date().timeIntervalSince1970, "uid": uid] as [String: Any]
        
        Database.database().reference().child("comments").child(postId).childByAutoId().updateChildValues(values) { (err, ref) in
            if let error = err {
                print("Failed to inser comment:", error)
            }
            
            print("Successfully inserted comment")
            
            self.containerView.clearCommentTextView()
        }
    }
}

extension CommentsCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let cell = CommentsCollectionViewCell(frame: frame)
        
//        cell.comment = comments[indexPath.item]
        
        cell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = cell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
    }
}
