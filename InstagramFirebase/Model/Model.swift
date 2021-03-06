//
//  Model.swift
//  InstagramFirebase
//
//  Created by Timur Saidov on 05/02/2019.
//  Copyright © 2019 Timur Saidov. All rights reserved.
//

import UIKit
import Firebase

var userHome: User?
var profileImageHome: [String: UIImage] = [:]
var postsHome = [Post]()
var isUpdateHome: Bool = false

var imagePostsDictionaryHome: [String: Data] = [:]

var userProfile: User?
var profileImageProfile: UIImage?
var postsProfile = [Post]()
var isUpdateProfile: Bool = false

var users = [User]()
var filteredUsers: [User] = []
var usersProfileImages: [String: Data] = [:]

class Model: NSObject {
    static let shared = Model()
    
    func fetchPostsWithUserUid(uid: String, completionHandler: @escaping () -> ()) {
        Database.database().reference(withPath: "users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            print("UID: \(uid)")
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            print("Fetched user: \(dictionary)")
            userHome = User(uid: uid, dictionary: dictionary)
            guard let user = userHome else { return }
            
            var posts: [String: Any] = [:]
            if dictionary["posts"] != nil {
                guard let postsDictionary = dictionary["posts"] as? [String: Any] else { return }
                posts = postsDictionary
            }
            
            var likeDict: [String: Bool] = [:]
            posts.forEach({ (key, value) in
                Database.database().reference().child("likes").observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let dictionary = snapshot.value as? [String: Any] else { return }
                    
                    dictionary.forEach({ (likeKey, likeValue) in
                        if key == likeKey {
                            let dict = likeValue as! [String: Int]
                            
                            dict.forEach({ (likeUidKey, likeUidValue) in
                                if uid == likeUidKey {
                                    if likeUidValue == 1 {
                                        likeDict[likeKey] = true
                                    } else {
                                        likeDict[likeKey] = false
                                    }
                                }
                            })
                        }
                    })
                }, withCancel: { (error) in
                    print("Failed to fetch like for post:", error)
                })
            })
            
            var followingUid: [String] = []
            if dictionary["following"] != nil {
                guard let followingDictionary = dictionary["following"] as? [String: Any] else { return }
                followingDictionary.forEach({ (key, value) in
                    followingUid.append(key)
                })
                print(followingUid)
            }
            
            var followingCount: Int = 0
            var likeDictFollowing: [String: Bool] = [:]
            followingUid.forEach({ (followUid) in
                Database.database().reference(withPath: "users").child(followUid).observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let dictionaryFollowing = snapshot.value as? [String: Any] else { return }
                    print("Fetched following: \(dictionaryFollowing)")
                    let userFollowing = User(uid: followUid, dictionary: dictionaryFollowing)
                    
                    var postsFollowing: [String: Any] = [:]
                    if dictionaryFollowing["posts"] != nil {
                        guard let postsFollowingDictionary = dictionaryFollowing["posts"] as? [String: Any] else { return }
                        postsFollowing = postsFollowingDictionary
                    }
                    
                    postsFollowing.forEach({ (key, value) in
                        Database.database().reference().child("likes").observeSingleEvent(of: .value, with: { (snapshot) in
                            guard let dictionary = snapshot.value as? [String: Any] else { return }
                            
                            dictionary.forEach({ (likeKey, likeValue) in
                                if key == likeKey {
                                    let dict = likeValue as! [String: Int]
                                    
                                    dict.forEach({ (likeUidKey, likeUidValue) in
                                        if uid == likeUidKey {
                                            if likeUidValue == 1 {
                                                likeDictFollowing[likeKey] = true
                                            } else {
                                                likeDictFollowing[likeKey] = false
                                            }
                                        }
                                    })
                                }
                            })
                        }, withCancel: { (error) in
                            print("Failed to fetch like for post:", error)
                        })
                    })
                    
                    guard let url = URL(string: userFollowing.profileImageUrl) else { return }
                    
                    let taskToLoadFollowingProfileImageAndPosts = URLSession.shared.dataTask(with: url) { (data, response, error) in
                        print("Loading following profile image")
                        
                        if let error = error {
                            print("Failed to fetch profile image", error)
                            return
                        }
                        
                        guard let data = data else { return }
                        print(data)
                        
                        postsFollowing.forEach({ (key, value) in
                            guard let dictionary = value as? [String: Any] else { return }
                            
                            guard let postsFollowingImageUrlString = dictionary["postImageUrl"] as? String else { return }
                            
//                            guard let postFollowingImageUrl = URL(string: postsFollowingImageUrlString) else { return }
//
//                            print("Loading following post image")
//                            do {
//                                let postFollowingImageData = try Data(contentsOf: postFollowingImageUrl)
//
//                                guard let caption = dictionary["caption"] as? String else { return }
//                                guard let creationDate = dictionary["creationDate"] as? Double else { return }
//                                let secondsFrom1970 = Date(timeIntervalSince1970: creationDate)
//
//                                let post = Post(user: userFollowing, imageData: postFollowingImageData, caption: caption, creationDateNum: creationDate, creationDate: secondsFrom1970, imageUrl: nil)
//                                
//                                postsHome.append(post)
//                            } catch {
//                                print("Can't fetch following post image:", error.localizedDescription)
//                            }
                            guard let caption = dictionary["caption"] as? String else { return }
                            guard let creationDate = dictionary["creationDate"] as? Double else { return }
                            let secondsFrom1970 = Date(timeIntervalSince1970: creationDate)
                            
                            var hasLiked: Bool?
                            likeDictFollowing.forEach({ (likeKey, likeValue) in
                                if key == likeKey {
                                    hasLiked = likeValue
                                }
                            })
                            if hasLiked == nil {
                                hasLiked = false
                            }
                            
                            let post = Post(id: key, user: userFollowing, imageData: nil, caption: caption, creationDateNum: creationDate, creationDate: secondsFrom1970, hasLiked: hasLiked, imageUrl: postsFollowingImageUrlString)
                            
                            postsHome.append(post)
                        })
                        
                        DispatchQueue.main.async {
                            profileImageHome["\(userFollowing.username)"] = UIImage(data: data)
                            
                            if !postsFollowing.isEmpty {
                                for byPass in 1..<postsHome.count {
                                    for k in 0..<(postsHome.count - byPass) {
                                        if postsHome[k].creationDateNum < postsHome[k + 1].creationDateNum {
                                            let tmp = postsHome[k]
                                            postsHome[k] = postsHome[k + 1]
                                            postsHome[k + 1] = tmp
                                        }
                                    }
                                }
                            }
                            
                            followingCount += 1 // Получены все данные подписки user'а -> увеливается followingCount.
                            print("followingCount = \(followingCount)")
                            print("followingUid + user = \(followingUid.count + 1)")
                            if followingCount == followingUid.count + 1 {
                                print("Home Collection view is now reloaded")
                                completionHandler()
                            }
                        }
                    }
                    taskToLoadFollowingProfileImageAndPosts.resume()
                }, withCancel: { (error) in
                    print("Failed to fetch following", error)
                })
            })
            
            guard let url = URL(string: user.profileImageUrl) else { return }
            
            let taskToLoadProfileImageAndPosts = URLSession.shared.dataTask(with: url) { (data, response, error) in
                print("Loading profile image")
                
                if let error = error {
                    print("Failed to fetch profile image", error)
                    return
                }
                
                guard let data = data else { return }
                print(data)
                
                posts.forEach({ (key, value) in
                    guard let dictionary = value as? [String: Any] else { return }
                    
                    guard let postsImageUrlString = dictionary["postImageUrl"] as? String else { return }
                    
//                    guard let postImageUrl = URL(string: postsImageUrlString) else { return }
//
//                    print("Loading post image")
//                    do {
//                        let postImageData = try Data(contentsOf: postImageUrl)
//
//                        guard let caption = dictionary["caption"] as? String else { return }
//                        guard let creationDate = dictionary["creationDate"] as? Double else { return }
//                        let secondsFrom1970 = Date(timeIntervalSince1970: creationDate)
//                        
//                        let post = Post(user: user, imageData: postImageData, caption: caption, creationDateNum: creationDate, creationDate: secondsFrom1970, imageUrl: nil)
//
//                        postsHome.append(post)
//                    } catch {
//                        print("Can't load the post image:", error.localizedDescription)
//                    }
                    guard let caption = dictionary["caption"] as? String else { return }
                    guard let creationDate = dictionary["creationDate"] as? Double else { return }
                    let secondsFrom1970 = Date(timeIntervalSince1970: creationDate)
                    
                    var hasLiked: Bool?
                    likeDict.forEach({ (likeKey, likeValue) in
                        if key == likeKey {
                            hasLiked = likeValue
                        }
                    })
                    if hasLiked == nil {
                        hasLiked = false
                    }
                   
                    let post = Post(id: key, user: user, imageData: nil, caption: caption, creationDateNum: creationDate, creationDate: secondsFrom1970, hasLiked: hasLiked, imageUrl: postsImageUrlString)
                    
                    postsHome.append(post)
                })
                
                DispatchQueue.main.async {
                    profileImageHome["\(user.username)"] = UIImage(data: data)
                    
                    isUpdateHome = true
                    
                    if !postsHome.isEmpty {
                        for byPass in 1..<postsHome.count {
                            for k in 0..<(postsHome.count - byPass) {
                                if postsHome[k].creationDateNum < postsHome[k + 1].creationDateNum {
                                    let tmp = postsHome[k]
                                    postsHome[k] = postsHome[k + 1]
                                    postsHome[k + 1] = tmp
                                }
                            }
                        }
                    }
                    
                    followingCount += 1 // Получены все данные пользователя -> увеливается followingCount.
                    print("followingCount = \(followingCount)")
                    print("followingUid + user = \(followingUid.count + 1)")
                    if followingCount == followingUid.count + 1 {
                        print("Home Collection view is now reloaded")
                        completionHandler()
                    }
                }
            }
            taskToLoadProfileImageAndPosts.resume()
        }) { (error) in
            print("Failed to fetch user and his posts:", error)
        }
    }
    
    func fetchUserAndPostsWithUid(uid: String, completionHandler: @escaping () -> ()) {
        Database.database().reference(withPath: "users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            print("Fetched user: \(dictionary)")
            userProfile = User(uid: uid, dictionary: dictionary)
            guard let user = userProfile else { return }
            
            var posts: [String: Any] = [:]
            if dictionary["posts"] != nil {
                guard let postsDictionary = dictionary["posts"] as? [String: Any] else { return }
                posts = postsDictionary
            }
            
            guard let url = URL(string: user.profileImageUrl) else { return }
            
            let taskToLoadProfileImageAndPosts = URLSession.shared.dataTask(with: url) { (data, response, error) in
                print("Loading profile image")
                
                if let error = error {
                    print("Failed to fetch profile image", error)
                    return
                }
                
                guard let data = data else { return }
                print(data)
                
                posts.forEach({ (key, value) in
                    guard let dictionary = value as? [String: Any] else { return }
                    
                    guard let postsImageUrlString = dictionary["postImageUrl"] as? String else { return }
                    
                    guard let postImageUrl = URL(string: postsImageUrlString) else { return }
                    
                    print("Loading post image")
                    do {
                        let postImageData = try Data(contentsOf: postImageUrl)
                        
                        guard let caption = dictionary["caption"] as? String else { return }
                        guard let creationDate = dictionary["creationDate"] as? Double else { return }
                        let secondsFrom1970 = Date(timeIntervalSince1970: creationDate)
                        
                        let post = Post(id: key, user: user, imageData: postImageData, caption: caption, creationDateNum: creationDate, creationDate: secondsFrom1970, hasLiked: nil, imageUrl: nil)
                        
                        postsProfile.append(post)
                    } catch {
                        print("Can't load the post image:", error.localizedDescription)
                    }
                })
                
                DispatchQueue.main.async {
                    profileImageProfile = UIImage(data: data)
                    
                    isUpdateProfile = true
                    
                    if !postsProfile.isEmpty {
                        for byPass in 1..<postsProfile.count {
                            for k in 0..<(postsProfile.count - byPass) {
                                if postsProfile[k].creationDateNum < postsProfile[k + 1].creationDateNum {
                                    let tmp = postsProfile[k]
                                    postsProfile[k] = postsProfile[k + 1]
                                    postsProfile[k + 1] = tmp
                                }
                            }
                        }
                    }
                    
                    print("Profile Collection view is now reloaded")
                    completionHandler()
                }
            }
            taskToLoadProfileImageAndPosts.resume()
        }) { (error) in
            print("Failed to fetch user and his posts:", error)
        }
    }
    
    func fetchUsersForSearch(completionHandler: @escaping () -> ()) {
        print("Fetching users")
        
        Database.database().reference(withPath: "users").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            print(dictionary)
            
            dictionary.forEach({ (key, value) in
                if key == Auth.auth().currentUser?.uid {
                    print("Found myself")
                    completionHandler()
                    return
                }
                
                guard let userDictionary = value as? [String: Any] else { return }
                
                let user = User(uid: key, dictionary: userDictionary)
                print(user.uid, user.username)
                
                users.append(user)
            })
            
            users.sort(by: { (user1, user2) -> Bool in
                return user1.username.compare(user2.username) == .orderedAscending
            })
            
            filteredUsers = users
            
            users.forEach({ (user) in
                guard let profileImageUrl = URL(string: user.profileImageUrl) else { return }
                
                let task = URLSession.shared.dataTask(with: profileImageUrl, completionHandler: { (data, response, error) in
                    guard let data = data else { return }
                    
                    usersProfileImages["\(user.uid)"] = data
                    
                    if usersProfileImages.count >= users.count {
                        DispatchQueue.main.async {
                            completionHandler()
                        }
                    }
                })
                task.resume()
            })
        }) { (error) in
            print("Failed to fetch users for search")
        }
    }
    
    // Загрузка картинок постов уже после того, как все посты отображены.
    func fetchImageForPostInHome(post: Post, indexPath: IndexPath, imageView: UIImageView) {
        imageView.image = nil
        
        for key in imagePostsDictionaryHome.keys {
            if key == "\(indexPath.row)" {
                imageView.image = UIImage(data: imagePostsDictionaryHome["\(indexPath.row)"]!)
                return
            }
        }
        
        let imageUrl = post.imageUrl
        
        guard let url = URL(string: imageUrl!) else {
            print("Can't get URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    print("Can't fetch to load image post")
                    return
                }
            }
            
            guard let data = data else { return }
            
            imagePostsDictionaryHome["\(indexPath.row)"] = data
            print(imagePostsDictionaryHome as Any)
            
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data)
                imageView.clipsToBounds = true
            }
        }
        task.resume()
    }
}
