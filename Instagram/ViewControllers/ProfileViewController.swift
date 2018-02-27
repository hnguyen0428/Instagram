//
//  ProfileViewController.swift
//  Instagram
//
//  Created by Hoang on 2/25/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Parse
import ParseUI
import UIKit

class ProfileViewController: UIViewController, UITabBarControllerDelegate,
                            UIImagePickerControllerDelegate, UINavigationControllerDelegate,
                            UICollectionViewDataSource, UICollectionViewDelegate,
                            UIScrollViewDelegate {
    @IBOutlet weak var changePicButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var posts: [Post] = []
    var user: User? = nil
    var currentUser: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setupProfilePage()
        
        setupCollectionView()
        setupProfileImageView()
        setupChangePicButton()
        setupRefreshControl()
        queryProfile()
        queryPosts()
    }
    
    func setupProfilePage() {
        if let usr = self.user, usr.objectId != PFUser.current()?.objectId {
            self.changePicButton.isHidden = true
            navigationItem.title = usr.username
            navigationItem.rightBarButtonItem = nil
            usernameLabel.text = usr.username
        }
        else {
            currentUser = true
            let user = PFUser.current() as? User
            navigationItem.title = user?.username
            usernameLabel.text = user?.username
        }
        
        
    }
    
    func setupCollectionView() {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellsPerLine: CGFloat = 3
        layout.minimumInteritemSpacing = 2.0
        layout.minimumLineSpacing = 2.0
        let interItemSpacingTotal = layout.minimumInteritemSpacing * (cellsPerLine - 1)
        let width = view.frame.width / cellsPerLine -
            interItemSpacingTotal / cellsPerLine
        layout.itemSize = CGSize(width: width, height: width)
    }
    
    func setupProfileImageView() {
        profileImageView.image = #imageLiteral(resourceName: "default_profile")
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileImageView.layer.borderWidth = 1
    }
    
    func setupChangePicButton() {
        changePicButton.layer.cornerRadius = 5.0
        changePicButton.layer.borderWidth = 1.0
        changePicButton.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        scrollView.insertSubview(refreshControl, at: 0)
    }
    
    
    @objc func didPullToRefresh(_ sender: UIRefreshControl) {
        queryPosts {
            sender.endRefreshing()
        }
    }
    
    
    func queryProfile() {
        var user: User?
        if let usr = self.user, usr != PFUser.current() {
            user = usr
        }
        else {
            user = PFUser.current() as? User
        }
        user?.loadProfileImage(withCompletion: { (image) in
            self.profileImageView.image = image
        })
    }
    
    func queryPosts(completion: (() -> Void)? = nil) {
        var user: PFUser?
        if let usr = self.user, usr != PFUser.current() {
            user = usr
        }
        else {
            user = PFUser.current()
        }
        
        let query = Post.query()
        query?.whereKey("author", equalTo: user)
        query?.findObjectsInBackground(block: { (posts, error) in
            completion?()
            if let error = error {
                print(error.localizedDescription)
            }
            else if let posts = posts as? [Post] {
                self.posts = posts
                self.collectionView.reloadData()
            }
        })
    }
    
    @IBAction func changeProfilePic(_ sender: UIButton) {
        showPicker()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.title == "PostViewController" {
            let nvc = viewController as! UINavigationController
            let pvc = nvc.viewControllers.first as! PostViewController
            pvc.previous = tabBarController.selectedIndex
        }
        return true
    }
    
    func showPicker() {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        
        vc.sourceType = .photoLibrary
        self.present(vc, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        
        profileImageView.image = editedImage
        let user = PFUser.current() as? User
        user?.postUserImage(image: editedImage!, withCompletion: { (success, error) in
            self.dismiss(animated: true, completion: nil)
            if let error = error {
                print(error)
                self.displayAlert(title: "Error", message: "Was not able to upload profile image")
            }
        })
        
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let post = posts[indexPath.row]
        
        post.loadImage { (image) in
            if let image = image {
                cell.photoImageView.image = image
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PostDetailViewController {
            let cell = sender as! PhotoCell
            let indexPath = collectionView.indexPath(for: cell)!
            vc.post = posts[indexPath.row]
            
        }
    }
    
}
