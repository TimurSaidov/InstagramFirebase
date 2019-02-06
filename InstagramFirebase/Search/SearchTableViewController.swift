//
//  SearchTableViewController.swift
//  InstagramFirebase
//
//  Created by Timur Saidov on 05/02/2019.
//  Copyright © 2019 Timur Saidov. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    let loadingScreen = UIView()
    let activityIndicator = UIActivityIndicatorView()
    let loadingLabel = UILabel()
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search"
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        
        sb.delegate = self
        
        return sb
    }()
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) { // called when text starts editing.
        searchBar.setShowsCancelButton(true, animated: true)
        tableView.resignFirstResponder()
        searchBarCancelButtonClicked(searchBar: searchBar)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) { // called when text changes (including clear).
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter({ (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            })
        }
        
        tableView.reloadData()
    }
    
    private func searchBarCancelButtonClicked(searchBar: UISearchBar) { // called when cancel button pressed.
        var cancelButton: UIButton
        let topView: UIView = searchBar.subviews[0] as UIView
        for subView in topView.subviews {
            if subView.isKind(of: NSClassFromString("UINavigationButton")!) {
                cancelButton = subView as! UIButton
                cancelButton.setTitleColor(.black, for: .normal)
                cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
            }
        }
    }
    
    @objc func cancelTapped() {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredUsers = users
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = searchBar
        
        setLoadingScreen()
        Model.shared.fetchUsersForSearch {
            self.removeLoadingScreen()
            self.tableView.reloadData()
        }
        
        tableView.keyboardDismissMode = .onDrag
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchBar.isHidden = false
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SearchTableViewCell
        
        let user = filteredUsers[indexPath.row]
        let userProfileImageData = usersProfileImages["\(user.uid)"]
        
        cell.usernameLabel.text = user.username
        if let data = userProfileImageData {
            cell.profileImageView.image = UIImage(data: data)
        }
        
        cell.profileImageView.layer.cornerRadius = 50 / 2
        cell.profileImageView.clipsToBounds = true
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        
        let selectedUser = filteredUsers[indexPath.row]
        print(selectedUser.username)
        
        let userProfileCollectionViewController = self.storyboard?.instantiateViewController(withIdentifier: "profileCVCSID") as! UserProfileCollectionViewController
        userProfileCollectionViewController.userUid = selectedUser.uid
        navigationController?.pushViewController(userProfileCollectionViewController, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Set the activity indicator into the main view.
    private func setLoadingScreen() {
        // Sets the view which contains the loading text and the activity indicator.
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (tableView.frame.width / 2) - (width / 2)
        let y = (tableView.frame.height / 2) - (height / 2) - 1.72*(navigationController?.navigationBar.frame.height)!
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
        
        tableView.addSubview(loadingScreen)
    }
    
    // Remove the activity indicator from the main view.
    private func removeLoadingScreen() {
        // Hides and stops the text and the activity indicator.
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        loadingLabel.isHidden = true
    }
}
