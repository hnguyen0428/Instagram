//
//  Extensions.swift
//  Instagram
//
//  Created by Hoang on 2/25/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func displayAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(ac, animated: true, completion: nil)
    }
    
    func displayYesNoAlert(title: String, message: String, yesAction: @escaping (UIAlertAction) -> Void) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: yesAction))
        
        self.present(ac, animated: true, completion: nil)
    }
    
    func hideViewWithAnimation(view: UIView, duration: Double, hidden: Bool = true) {
        UIView.transition(with: view, duration: duration, options: .transitionCrossDissolve,
                          animations:
            {
                view.isHidden = hidden
        }, completion: nil)
    }
    
    /**
     Hide keyboard when clicking outside of the keyboard
     */
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    /**
     Dismiss keyboard, called by hideKeyboardWhenTappedAround()
     */
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func shadeView(shaded: Bool) {
        if shaded {
            let mask = UIView(frame: self.view.frame)
            mask.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.view.mask = mask
            self.view.isUserInteractionEnabled = false
        }
        else {
            self.view.mask = nil
            self.view.isUserInteractionEnabled = true
        }
    }
}

extension UIColor {
    convenience public init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(r: r, g: g, b: b, a: 1)
    }
    
    convenience public init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
}
