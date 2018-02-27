//
//  Post.swift
//  Instagram
//
//  Created by Hoang on 2/26/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Parse

class Post: PFObject, PFSubclassing {
    @NSManaged var media : PFFile
    @NSManaged var author: PFUser
    @NSManaged var caption: String
    
    
    /* Needed to implement PFSubclassing interface */
    class func parseClassName() -> String {
        return "Post"
    }
    
    class func postUserImage(image: UIImage, withCaption caption: String, withCompletion completion: PFBooleanResultBlock?) {
        let post = Post()
        
        post.media = getPFFileFromImage(image)
        post.author = PFUser.current()!
        post.caption = caption
        
        post.saveInBackground(block: completion)
    }
    
    func loadImage(withCompletion completion: @escaping (UIImage?) -> Void) {
        self.media.getDataInBackground(block: { (data, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            }
            else {
                let image = UIImage(data: data!)
                completion(image)
            }
        })
    }
    
    class func getPFFileFromImage(_ image: UIImage) -> PFFile {
        let imageData = UIImagePNGRepresentation(image)!
        return PFFile(name: "image.png", data: imageData)!
    }
}
