//
//  SettingsViewController.swift
//  Instagram
//
//  Created by Hoang on 2/25/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Parse
import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logout(_ sender: UIButton) {
        displayYesNoAlert(title: "Log out", message: "Are you sure?") { _ in
            PFUser.logOutInBackground(block: { (error) in
                if let error = error {
                    self.displayAlert(title: "Could not logout", message: error.localizedDescription)
                }
                else {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                    UIView.animate(withDuration: 0.5, animations:
                        {
                            UIApplication.shared.keyWindow?.rootViewController = loginVC
                    })
                }
            })
        }
    }
}
