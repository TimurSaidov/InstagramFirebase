//
//  UserProfileViewController.swift
//  InstagramFirebase
//
//  Created by Timur Saidov on 05/02/2019.
//  Copyright © 2019 Timur Saidov. All rights reserved.
//

import UIKit
import Firebase

class UserProfileViewController: UIViewController {
    
    var user: User?
    
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var gridButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    
    @IBAction func logOutButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let logOut = UIAlertAction(title: "Log Out", style: .destructive) { (_) in
            do {
                try Auth.auth().signOut()
                
                // Уход на экран Login.
            } catch {
                print("Failed to sign out")
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(logOut)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        editProfileButton.layer.borderColor = UIColor.lightGray.cgColor
        editProfileButton.layer.borderWidth = 1
        editProfileButton.layer.cornerRadius = 3
        
        let buttonsArray = [listButton, bookmarkButton]
        for item in buttonsArray {
            item?.tintColor = UIColor(white: 0, alpha: 0.2)
        }
        
        zeroingUI()
        
        fetchUser()
    }
    
    private func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference(withPath: "users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot, snapshot.value ?? "")
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            self.user = User(uid: uid, dictionary: dictionary)
            
            guard let url = URL(string: self.user!.profileImageUrl) else { return }
            
            let task = URLSession.shared.dataTask(with: url ) { (data, response, error) in
                if let error = error {
                    print("Failed to fetch profile image", error)
                    return
                }
                
                guard let data = data else { return }
                
                print(data)
                
                DispatchQueue.main.async {
                    self.navigationItem.title = self.user!.username
                    self.usernameLabel.text = self.user!.username
                    self.profileImageView.image = UIImage(data: data)
                    self.profileImageView.layer.cornerRadius = 80 / 2
                    self.profileImageView.clipsToBounds = true
                    
                    let labelsArray = [self.postsLabel, self.followersLabel, self.followingLabel]
                    for item in labelsArray {
                        switch item {
                        case self.postsLabel:
                            let attributedText = NSMutableAttributedString(string: "11\n")
                            attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
                            self.postsLabel.attributedText = attributedText
                        case self.followersLabel:
                            let attributedText = NSMutableAttributedString(string: "0\n")
                            attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
                            self.followersLabel.attributedText = attributedText
                        case self.followingLabel:
                            let attributedText = NSMutableAttributedString(string: "0\n")
                            attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
                            self.followingLabel.attributedText = attributedText
                        default:
                            break
                        }
                    }
                }
            }
            task.resume()
        }) { (error) in
            print("Failed to fetch user:", error)
        }
    }
    
    func zeroingUI() {
        postsLabel.text = ""
        followersLabel.text = ""
        followingLabel.text = ""
        usernameLabel.text = ""
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}

extension UserProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 14
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! UserProfileCollectionViewCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
}
