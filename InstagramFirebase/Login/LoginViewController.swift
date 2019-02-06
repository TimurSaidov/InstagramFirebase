//
//  LoginViewController.swift
//  InstagramFirebase
//
//  Created by Timur Saidov on 05/02/2019.
//  Copyright © 2019 Timur Saidov. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        let formValid = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        
        if formValid {
            loginButton.isEnabled = true
            loginButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Failed to sign in with email", error)
                return
            }
            
            let uid = Auth.auth().currentUser?.uid
            print("Successfully logged back with user:", uid ?? "")
            
            let mainTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "mainTabBarSID") as! MainTabBarController
            
            self.present(mainTabBarController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadScreen()
        
        print("LoginViewController - \(#function)")
    }
    
    func loadScreen() {
        logoView.backgroundColor = UIColor.rgb(red: 0, green: 120, blue: 175)
        
        let textFieldArray = [emailTextField, passwordTextField]
        for item in textFieldArray {
            backgroundColorTF(sender: item!)
        }
        
        loginButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244) // Расширение класса UIColor.
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 5
        loginButton.isEnabled = false
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account? ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign Up.", attributes: [NSAttributedString.Key.foregroundColor: UIColor.rgb(red: 17, green: 154, blue: 237)]))
        signUpButton.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    func backgroundColorTF(sender: UITextField) {
        sender.backgroundColor = UIColor(white: 0, alpha: 0.03)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
