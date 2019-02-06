//
//  SharePhotoViewController.swift
//  InstagramFirebase
//
//  Created by Timur Saidov on 05/02/2019.
//  Copyright © 2019 Timur Saidov. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoViewController: UIViewController {
    
    var selectedImage: UIImage?
    var storageRef: StorageReference!
    var ref: DatabaseReference!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTextView: UITextView!
    
    @IBAction func shareBarButtonItemTapped(_ sender: UIBarButtonItem) {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        guard let image = selectedImage else { return }
        guard let caption = self.photoTextView.text, caption != "" else {
            //
            
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            return
        }
        
        guard let uploadData = image.jpegData(compressionQuality: 0.5) else { return }
        
        let filename = NSUUID().uuidString
        
        storageRef.child(filename).putData(uploadData, metadata: nil) { (metadata, error) in
            if let error = error {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to upload post image:", error)
                return
            }
            
            self.storageRef.child(filename).downloadURL(completion: { (url, error) in
                guard let postImageUrl = url?.absoluteString else { return }
                
                print("Successfully uploaded post image", postImageUrl)
                
                let dictionaryValues = ["postImageUrl": postImageUrl, "caption": caption, "imageWidth": image.size.width, "imageHeight": image.size.height, "creationDate": Date().timeIntervalSince1970] as [String : Any]
                
                let ref = self.ref.childByAutoId()
                
                ref.setValue(dictionaryValues, withCompletionBlock: { (error, ref) in
                    if let err = error {
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        print("Failed to save post in Database", err)
                        return
                    }
                    
                    print("Successfully saved post in Database")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("UpdateHome"), object: self)
                    NotificationCenter.default.post(name: NSNotification.Name("UpdateProfile"), object: self)
                    
                    self.dismiss(animated: true, completion: nil)
                })
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoImageView.image = selectedImage
        photoImageView.clipsToBounds = true
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        storageRef = Storage.storage().reference().child("posts")
        ref = Database.database().reference(withPath: "users").child(uid).child("posts")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
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
