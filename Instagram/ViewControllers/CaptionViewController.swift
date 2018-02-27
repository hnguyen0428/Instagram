//
//  CaptionViewController.swift
//  Instagram
//
//  Created by Hoang on 2/26/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class CaptionViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    var photo: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        photoView.layer.borderColor = UIColor.lightGray.cgColor
        photoView.layer.borderWidth = 1.0
        
        self.captionTextView.delegate = self
        self.hideKeyboardWhenTappedAround()
        
        if let image = photo {
            photoView.image = image
        }
        
        configureNavbar()
    }
    
    func configureNavbar() {
        self.navigationItem.title = "Caption"
        let barbutton = UIBarButtonItem(title: "Share", style: .done, target: self, action: #selector(sharePost))
        barbutton.tintColor = .black
        self.navigationItem.rightBarButtonItem = barbutton
        self.navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func sharePost() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        self.view.alpha = 0.5
        self.view.isUserInteractionEnabled = false
        Post.postUserImage(image: self.photo!, withCaption: captionTextView.text) { (success, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.view.alpha = 1.0
            self.view.isUserInteractionEnabled = true
            if let error = error {
                self.displayAlert(title: "Error", message: error.localizedDescription)
            }
            else {
                self.navigationController?.popToRootViewController(animated: true)
                self.tabBarController?.selectedIndex = 0
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Write a caption..." {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Write a caption..."
            textView.textColor = UIColor.lightGray
        }
    }
}
