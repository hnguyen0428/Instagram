//
//  PostDetailViewController.swift
//  Instagram
//
//  Created by Hoang on 2/26/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Foundation
import UIKit
import Parse

class PostDetailViewController: UIViewController, UITableViewDelegate,
                                UITableViewDataSource, PostCellHeaderDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var post: Post!
    var rowHeight: CGFloat?
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = tableView.frame.width
        tableView.delegate = self
        tableView.dataSource = self
        
        post.author.fetchIfNeededInBackground { (object, error) in
            if let user = object as? User {
                self.user = user
                self.tableView.reloadData()
            }
            else if let error = error {
                print(error)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        cell.setPost(post: self.post, completion: { image in
            let size = image.size
            let heightToWidth = size.height / size.width
            let newHeight = self.tableView.frame.width * heightToWidth
            self.rowHeight = newHeight
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let width: CGFloat = self.tableView.frame.width
        let height: CGFloat = self.tableView.frame.height * 0.07
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        let header = PostHeader(frame: frame)
        if let user = self.user {
            header.user = user
        }
        header.delegate = self
        
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let width: CGFloat = self.tableView.frame.width
        let height: CGFloat = self.tableView.frame.height * 0.15
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        let footer = PostFooter(frame: frame)
        footer.post = post
        if let user = self.user {
            footer.author = user
        }
        
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = rowHeight {
            return height
        }
        else {
            return tableView.frame.width
        }
    }

    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.tableView.frame.height * 0.15
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView.frame.height * 0.07
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func didTappedHeader(user: User, sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "showProfile", sender: user)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ProfileViewController {
            vc.user = sender as? User
        }
    }
}
