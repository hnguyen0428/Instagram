//
//  User.swift
//  Instagram
//
//  Created by Hoang on 2/26/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Parse

class User: PFUser {
    @NSManaged var profile : PFFile
    @NSManaged var biography : String?
    
    func postUserImage(image: UIImage, withCompletion completion: PFBooleanResultBlock?) {
        self.profile = User.getPFFileFromImage(image)
        self.saveInBackground(block: completion)
    }
    
    func loadProfileImage(withCompletion completion: @escaping (UIImage?) -> Void) {
        self.profile.getDataInBackground(block: { (data, error) in
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
        return PFFile(name: "profile.png", data: imageData)!
    }
}

