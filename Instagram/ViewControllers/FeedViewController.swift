//
//  FeedViewController.swift
//  Instagram
//
//  Created by Hoang on 2/25/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Foundation
import UIKit

class FeedViewController: UIViewController, UITableViewDelegate,
                            UITableViewDataSource, UITabBarControllerDelegate,
                            PostCellHeaderDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts: [Post] = []
    var rowHeights: [Int:CGFloat] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        tabBarController?.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        setupRefreshControl()
        fetchPosts()
        let font = UIFont(name: "Cochin-BoldItalic", size: 25.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: font]
    }
    
    func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.title == "PostViewController" {
            let nvc = viewController as! UINavigationController
            let pvc = nvc.viewControllers.first as! PostViewController
            pvc.previous = tabBarController.selectedIndex
        }
        return true
    }
    
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        fetchPosts {
            refreshControl.endRefreshing()
        }
    }
    
    
    func fetchPosts(completion: (() -> Void)? = nil) {
        let query = Post.query()
        query?.order(byDescending: "createdAt")
        query?.includeKey("author")
        query?.includeKey("media")
        query?.limit = 20
        
        query?.findObjectsInBackground(block: { (posts, error) in
            completion?()
            if let error = error {
                print(error.localizedDescription)
            }
            else if let posts = posts as? [Post] {
                self.posts = posts
                self.tableView.reloadData()
            }
        })
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView.frame.height * 0.07
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let width: CGFloat = self.tableView.frame.width
        let height: CGFloat = self.tableView.frame.height * 0.07
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        let post = posts[section]
        let author = post.author as! User
        let header = PostHeader(frame: frame)
        header.user = author
        header.delegate = self
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.tableView.frame.height * 0.15
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let width: CGFloat = self.tableView.frame.width
        let height: CGFloat = self.tableView.frame.height * 0.15
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        let post = posts[section]
        let author = post.author as! User
        let footer = PostFooter(frame: frame)
        footer.author = author
        footer.post = post
        
        return footer
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        let post = posts[indexPath.section]
        cell.setPost(post: post, completion: { image in
            let size = image.size
            let heightToWidth = size.height / size.width
            let newHeight = self.tableView.frame.width * heightToWidth
            self.rowHeights[indexPath.section] = newHeight
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = self.rowHeights[indexPath.section] {
            return height
        }
        else {
            return self.tableView.frame.width
        }
    }
    
    func didTappedHeader(user: User, sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "showProfile", sender: user)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ProfileViewController {
            vc.user = sender as? User
        }
    }
}
