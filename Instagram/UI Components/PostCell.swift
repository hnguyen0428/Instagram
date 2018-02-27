//
//  PostCell.swift
//  Instagram
//
//  Created by Hoang on 2/26/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import UIKit
import ParseUI
import Parse

class PostCell: UITableViewCell {
    @IBOutlet weak var photoImageView: PFImageView!
    
    var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setPost(post: Post, completion: ((UIImage) -> Void)?) {
        self.post = post
        self.photoImageView.file = post["media"] as? PFFile
        self.photoImageView.load { (image, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                completion?(image!)
            }
        }
    }
}

class PostHeader: UIView {
    var profileImageView: PFImageView!
    var usernameLabel: UILabel!
    var user: User! {
        didSet {
            self.loadUserData()
            self.user.loadProfileImage { (image) in
                self.profileImageView.image = image
            }
        }
    }
    
    weak var delegate: PostCellHeaderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        profileImageView = PFImageView()
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.image = #imageLiteral(resourceName: "default_profile")
        self.addSubview(profileImageView)
        let inset: CGFloat = 5.0
        let heightImageView = frame.height - inset * 2
        profileImageView.layer.cornerRadius = heightImageView / 2
        profileImageView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileImageView.layer.borderWidth = 1;
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.widthAnchor.constraint(equalToConstant: heightImageView).isActive = true
        profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: inset).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: inset).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -inset).isActive = true
        
        usernameLabel = UILabel()
        self.addSubview(usernameLabel)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: inset).isActive = true
        usernameLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -inset).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: inset).isActive = true
        usernameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -inset).isActive = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedHeader))
        self.addGestureRecognizer(tapGesture)
    }
    
    func loadUserData() {
        user.fetchIfNeededInBackground { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                let usr = user as? User
                self.usernameLabel.text = usr?.username
            }
        }
    }
    
    @objc func tappedHeader(_ sender: UITapGestureRecognizer) {
        delegate?.didTappedHeader?(user: user, sender: sender)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

@objc protocol PostCellHeaderDelegate: class {
    @objc optional func didTappedHeader(user: User, sender: UITapGestureRecognizer)
}


class PostFooter: UIView {
    var usernameLabel: UILabel!
    var captionLabel: UILabel!
    
    var post: Post! {
        didSet {
            loadPostData()
        }
    }
    var author: User! {
        didSet {
            loadUserData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        usernameLabel = UILabel()
        usernameLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .bold)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(usernameLabel)
        
        captionLabel = UILabel()
        captionLabel.font = UIFont.systemFont(ofSize: 12.0)
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(captionLabel)
        captionLabel.sizeToFit()
        
        let topInset: CGFloat = 3.0
        let bottomInset: CGFloat = -3.0
        let leftInset: CGFloat = 8.0
        let rightInset: CGFloat = -8.0
        
        let widthUsername = frame.width * 0.3
        let heightUsername = frame.height * 0.2
        usernameLabel.widthAnchor.constraint(equalToConstant: widthUsername).isActive = true
        usernameLabel.heightAnchor.constraint(equalToConstant: heightUsername).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: topInset).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: leftInset).isActive = true
        
        captionLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: leftInset).isActive = true
        captionLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: rightInset).isActive = true
        captionLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: bottomInset).isActive = true
        captionLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: topInset).isActive = true
    }
    
    func loadUserData() {
        if let username = author.username {
            usernameLabel.text = username
        }
        else {
            author.fetchIfNeededInBackground(block: { (user, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                else {
                    let usr = user as? User
                    self.usernameLabel.text = usr?.username
                }
            })
        }
    }
    
    func loadPostData() {
        captionLabel.text = post.caption
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


