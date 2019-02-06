//
//  SignUpViewController.swift
//  InstagramFirebase
//
//  Created by Timur Saidov on 05/02/2019.
//  Copyright © 2019 Timur Saidov. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    
    @IBOutlet weak var plusPhotoButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBAction func plusPhotoButtonTapped(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.lightGray.cgColor
        plusPhotoButton.layer.borderWidth = 3
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        let formValid = emailTextField.text?.count ?? 0 > 0 && usernameTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        
        if formValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let username = usernameTextField.text, let password = passwordTextField.text else { return }
        guard email != "" && username != "" && password != "" else {
            print("Not all fields are filled")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let err = error {
                print("Failed to create user:", err)
                return
            }
            
            let user = Auth.auth().currentUser
            print("Successfully created user:", user?.uid ?? "")
            
            guard let image = self.plusPhotoButton.imageView?.image else { return }
            
            guard let uploadImage = image.jpegData(compressionQuality: 0.3) else { return }
            
            let filename = NSUUID().uuidString
            
            self.storageRef.child(filename).putData(uploadImage, metadata: nil, completion: { (metadata, error) in
                if let err = error {
                    print("Failed to upload profile image", err)
                    return
                }
                
                print(metadata as Any)
                var profileImageUrl: String?
                self.storageRef.child(filename).downloadURL(completion: { (url, error) in
                    profileImageUrl = url?.absoluteString
                    
                    print("Successfully uploaded profile image", profileImageUrl ?? "")
                    
                    guard let uid = user?.uid else { return }
                    
                    let dictionaryValues = ["username": username, "profileImageUrl": profileImageUrl]
                    
                    self.ref.child(uid).setValue(dictionaryValues, withCompletionBlock: { (error, ref) in
                        if let err = error {
                            print("Failed to save user info in Database", err)
                            return
                        }
                        
                        print("Successfully saved user info in Database")
                        
                        let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "mainTabBarSID") as! MainTabBarController
                        
                        self.present(mainTabBarController, animated: true, completion: nil)
                    })
                })
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference(withPath: "users")
        storageRef = Storage.storage().reference().child("profile_image")
        
        loadScreen()
    }
    
    func loadScreen() {
        let textFieldArray = [emailTextField, usernameTextField, passwordTextField]
        for item in textFieldArray {
            backgroundColorTF(sender: item!)
        }
        signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244) // Расширение класса UIColor.
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.layer.cornerRadius = 5
        signUpButton.isEnabled = false
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign In.", attributes: [NSAttributedString.Key.foregroundColor: UIColor.rgb(red: 17, green: 154, blue: 237)]))
        signInButton.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    func backgroundColorTF(sender: UITextField) {
        sender.backgroundColor = UIColor(white: 0, alpha: 0.03)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
