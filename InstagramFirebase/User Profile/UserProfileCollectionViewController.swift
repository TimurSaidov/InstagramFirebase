//
//  UserProfileCollectionViewController.swift
//  InstagramFirebase
//
//  Created by Timur Saidov on 05/02/2019.
//  Copyright © 2019 Timur Saidov. All rights reserved.
//

import UIKit
import Firebase

class UserProfileCollectionViewController: UICollectionViewController, UserProfileHeaderDelegate {
    
    let loadingScreen = UIView()
    let activityIndicator = UIActivityIndicatorView()
    let loadingLabel = UILabel()
    
    var userUid: String?
    
    var isGridView: Bool = true
    
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    
    @IBAction func logOutButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let logOut = UIAlertAction(title: "Log Out", style: .destructive) { (_) in
            do {
                try Auth.auth().signOut()
                
                self.resetGlobalVariables()
                
                let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "loginSID") as! LoginViewController
                
                self.present(loginViewController, animated: true, completion: nil)
            } catch {
                print("Failed to sign out")
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(logOut)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func resetGlobalVariables() {
        userHome = nil
        profileImageHome = [:]
        postsHome = []
        isUpdateHome = false
        
        imagePostsDictionaryHome = [:]
        
        userProfile = nil
        profileImageProfile = nil
        postsProfile = []
        isUpdateProfile = false
        
        users = []
        filteredUsers = []
        usersProfileImages = [:]
    }
    
    func resetGlobalVariablesForProfile() {
        userProfile = nil
        profileImageProfile = nil
        postsProfile = []
        isUpdateProfile = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("UpdateProfile"), object: nil, queue: nil) { (notification) in
            print("Notification UpdateProfile is catched")
            
            print("Loading new post...")
            
            self.resetGlobalVariablesForProfile()
            
            self.collectionView.reloadData()
            self.setLoadingScreen()
            
            self.fetchUserAndPosts()
        }
        
        collectionView.register(UICollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderId")
        collectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: "CollectionCell")
        
        resetGlobalVariablesForProfile()
        
        setLoadingScreen()
        fetchUserAndPosts()
        
        print("UserProfileCollectionViewController - \(#function)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func fetchUserAndPosts() {
        let uid = userUid ?? (Auth.auth().currentUser?.uid ?? "")
        
        Model.shared.fetchUserAndPostsWithUid(uid: uid) {
            self.removeLoadingScreen()
            self.collectionView.reloadData()
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if isUpdateProfile {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderCell", for: indexPath) as! HeaderCollectionReusableView
            
            if userUid != nil {
                let currentUserUid = Auth.auth().currentUser?.uid
                
                Database.database().reference(withPath: "users").child(currentUserUid!).child("following").child(userUid!).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                        header.editProfileOrFollowButton.setTitle("Unfollow", for: .normal)
                        header.editProfileOrFollowButton.setTitleColor(.black, for: .normal)
                        header.editProfileOrFollowButton.backgroundColor = .white
                        header.editProfileOrFollowButton.layer.borderColor = UIColor.lightGray.cgColor
                        
                        header.editProfileOrFollowButton.addTarget(self, action: #selector(self.handleUnfollow), for: .touchUpInside)
                    } else {
                        header.editProfileOrFollowButton.setTitle("Follow", for: .normal)
                        header.editProfileOrFollowButton.setTitleColor(.white, for: .normal)
                        header.editProfileOrFollowButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
                        header.editProfileOrFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
                        
                        header.editProfileOrFollowButton.addTarget(self, action: #selector(self.handleFollow), for: .touchUpInside)
                    }
                }) { (error) in
                    print("Failed to chech ot following")
                }
            } else {
                header.editProfileOrFollowButton.setTitle("Edit Profile", for: .normal)
                header.editProfileOrFollowButton.layer.borderColor = UIColor.lightGray.cgColor
            }
            
            header.editProfileOrFollowButton.layer.borderWidth = 1
            header.editProfileOrFollowButton.layer.cornerRadius = 3
            
            self.navigationItem.title = userProfile!.username
            
            header.profileImageView.image = profileImageProfile
            header.profileImageView.layer.cornerRadius = 80 / 2
            header.profileImageView.clipsToBounds = true
            
            header.usernameLabel.text = userProfile!.username
            
            let labelsArray = [header.postsLabel, header.followersLabel, header.followingLabel]
            for item in labelsArray {
                switch item {
                case header.postsLabel:
                    let attributedText = NSMutableAttributedString(string: "11\n")
                    attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
                    header.postsLabel.attributedText = attributedText
                case header.followersLabel:
                    let attributedText = NSMutableAttributedString(string: "0\n")
                    attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
                    header.followersLabel.attributedText = attributedText
                case header.followingLabel:
                    let attributedText = NSMutableAttributedString(string: "0\n")
                    attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
                    header.followingLabel.attributedText = attributedText
                default:
                    break
                }
            }
            
            header.delegate = self
            
            return header
        }
        
        let headerWhileFalse = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderId", for: indexPath)
        
        return headerWhileFalse
    }
    
    @objc func handleFollow() {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        
        let values = [userUid!: 1]
        Database.database().reference(withPath: "users").child(currentUserUid).child("following").updateChildValues(values) { (error, ref) in
            if let error = error {
                print("Failed to follow user:", error)
            }
            
            print("Successfully followed user")
            
            self.collectionView.reloadData()
        }
    }
    
    @objc func handleUnfollow() {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference(withPath: "users").child(currentUserUid).child("following").child(userUid!).removeValue { (error, ref) in
            if let error = error {
                print("Failed to unfollow user:", error)
            }
            
            print("Successfully unfollowed user")
            
            self.collectionView.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return postsProfile.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCollectionCell", for: indexPath) as! UserProfileCollectionViewCell
            
            let imageData = postsProfile[indexPath.row].imageData
            cell.photoPostImageView.image = UIImage(data: imageData!)
            cell.photoPostImageView.clipsToBounds = true
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) // as! HomeCollectionViewCell
        
        return cell
    }
    
    // Set the activity indicator into the main view.
    private func setLoadingScreen() {
        // Sets the view which contains the loading text and the activity indicator.
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (view.frame.width / 2) - (width / 2)
        let y = (view.frame.height / 2) - (height / 2) // - (navigationController?.navigationBar.frame.height)!
        loadingScreen.frame = CGRect(x: x, y: y, width: width, height: height)
        
        // Sets loading text.
        loadingLabel.isHidden = false
        loadingLabel.textColor = .gray
        loadingLabel.textAlignment = .center
        loadingLabel.text = "Loading..."
        loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
        
        // Sets activity indicator.
        activityIndicator.style = .gray
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        activityIndicator.startAnimating()
        
        // Adds text and activity indicator to the view.
        loadingScreen.addSubview(activityIndicator)
        loadingScreen.addSubview(loadingLabel)
        
        view.addSubview(loadingScreen)
    }
    
    // Remove the activity indicator from the main view.
    private func removeLoadingScreen() {
        // Hides and stops the text and the activity indicator.
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        loadingLabel.isHidden = true
    }
    
    // Методы протокола UserProfileHeaderDelegate.
    func didChangeToGridView() {
        isGridView = true
        collectionView.reloadData()
    }
    
    func didChangeToListView() {
        isGridView = false
        collectionView.reloadData()
    }
}

extension UserProfileCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isGridView {
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        }
        return CGSize(width: view.frame.width, height: 200)
    }
}
