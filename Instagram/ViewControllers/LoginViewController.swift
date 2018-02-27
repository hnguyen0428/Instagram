//
//  LoginViewController.swift
//  Instagram
//
//  Created by Hoang on 2/25/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Parse
import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 10.0
        signupButton.layer.cornerRadius = 10.0
        loginButton.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.7).cgColor
        signupButton.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.7).cgColor
        loginButton.layer.borderWidth = 1.0
        signupButton.layer.borderWidth = 1.0
    }
    
    
    @IBAction func signup(_ sender: UIButton) {
        if showAlert() {
            return
        }
        
        let newUser = PFUser()
        newUser.username = usernameField.text!
        newUser.password = passwordField.text!
        
        newUser.signUpInBackground { (success, error) in
            if let error = error {
                print(error.localizedDescription)
                self.displayAlert(title: "Signup Failed", message: error.localizedDescription)
            } else {
                print("User Registered successfully")
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        if showAlert() {
            return
        }
        
        let username = usernameField.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password) { (user: PFUser?, error: Error?) in
            if let error = error {
                print("User log in failed: \(error.localizedDescription)")
                self.displayAlert(title: "Login Failed", message: error.localizedDescription)
            } else {
                print("User logged in successfully")
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
    }
    
    func clearFields() {
        usernameField.text = ""
        passwordField.text = ""
    }

    
    func showAlert() -> Bool {
        if let text = usernameField.text {
            if text.isEmpty {
                displayAlert(title: "Missing Info", message: "Fill everything out")
                return true
            }
        }
        
        if let text = passwordField.text {
            if text.isEmpty {
                displayAlert(title: "Missing Info", message: "Fill everything out")
                return true
            }
        }
        return false
    }
    
}
