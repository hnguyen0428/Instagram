//
//  PhotoCell.swift
//  Instagram
//
//  Created by Hoang on 2/25/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Foundation
import UIKit

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    
    override var isSelected: Bool {
        willSet {
            onSelected(newValue)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setImage(image: UIImage) {
        photoImageView.image = image
    }
    
    func turnonShade() {
        photoImageView.alpha = 0.5
    }
    
    func turnoffShade() {
        photoImageView.alpha = 1.0
    }
    
    func onSelected(_ newValue: Bool) {
        if newValue {
            turnonShade()
        }
        else {
            turnoffShade()
        }
    }
}
