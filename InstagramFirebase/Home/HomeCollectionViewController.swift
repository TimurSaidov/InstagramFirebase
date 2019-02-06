//
//  HomeCollectionViewController.swift
//  InstagramFirebase
//
//  Created by Timur Saidov on 05/02/2019.
//  Copyright © 2019 Timur Saidov. All rights reserved.
//

import UIKit
import Firebase

class HomeCollectionViewController: UICollectionViewController {
    
    let loadingScreen = UIView()
    let activityIndicator = UIActivityIndicatorView()
    let loadingLabel = UILabel()
    
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        let cameraViewController = CameraViewController()
        present(cameraViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("UpdateHome"), object: nil, queue: nil) { (notification) in
            print("Notification UpdateHome is catched")
            
            print("Loading new post...")
            
            self.resetGlobalVariablesForHome()
            self.fetchPosts()
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CellId")
        
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo2"))
        
        setLoadingScreen()
        fetchPosts()
    }
    
    @objc func handleRefresh() {
        print("Handling refresh...")
        
        resetGlobalVariablesForHome()
        fetchPosts()
    }
    
    func resetGlobalVariablesForHome() {
        userHome = nil
        profileImageHome = [:]
        postsHome = []
        isUpdateHome = false
        
        imagePostsDictionaryHome = [:]
    }
    
    private func fetchPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Model.shared.fetchPostsWithUserUid(uid: uid) {
            self.collectionView.refreshControl?.endRefreshing()
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
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return postsHome.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isUpdateHome {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! HomeCollectionViewCell
            
            let post = postsHome[indexPath.item]
            
            cell.profileImageView.image = profileImageHome["\(post.user.username)"]
            
            cell.userProfileLabel.text = post.user.username
            
            cell.profileImageView.layer.cornerRadius = 40 / 2
            cell.profileImageView.clipsToBounds = true
            
//            let imageData = post.imageData
//            cell.photoImageView.image = UIImage(data: imageData!)
//            cell.photoImageView.clipsToBounds = true
            Model.shared.fetchImageForPostInHome(post: post, indexPath: indexPath, imageView: cell.photoImageView)
            
            let timeAgoDisplay = post.creationDate.timeAgoDisplay()
            let attributedText = NSMutableAttributedString(string: post.user.username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            let caption = post.caption
            attributedText.append(NSAttributedString(string: " " + caption, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
            attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))
            attributedText.append(NSAttributedString(string: timeAgoDisplay, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            cell.captionLabel.attributedText = attributedText
            
            return cell
        }
        
        let cellWhileFalse = collectionView.dequeueReusableCell(withReuseIdentifier: "CellId", for: indexPath)
        
        return cellWhileFalse
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
}

extension HomeCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 40 + 8 + 8
        height += view.frame.width
        height += 50
        height += 60
        
        return CGSize(width: view.frame.width, height: height)
    }
}
