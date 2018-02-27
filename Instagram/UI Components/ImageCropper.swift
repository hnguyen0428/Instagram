//
//  ImageCropper.swift
//  Instagram
//
//  Created by Hoang on 2/25/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import UIKit

class ImageCropper: UIScrollView {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var landscape: Bool = false
    static let MIN_ZOOM_SCALE: CGFloat = 1.0
    static let MAX_ZOOM_SCALE: CGFloat = 10.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.black.cgColor
        self.minimumZoomScale = ImageCropper.MIN_ZOOM_SCALE
        self.maximumZoomScale = ImageCropper.MAX_ZOOM_SCALE
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.backgroundColor = UIColor(r: 245, g: 245, b: 245)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupImage(image: UIImage) {
        let imageSize = image.size
        let imageRatio = imageSize.width / imageSize.height
        
        // Scale the frame of image based on the ratio of the image
        if imageSize.width < imageSize.height { // portrait image
            landscape = false
            let width = self.frame.width
            let height = self.frame.width / imageRatio
            let origin = CGPoint.zero
            let frame = CGRect(x: origin.x, y: origin.y,
                               width: width, height: height)
            imageView.frame = frame
        }
        else { // landscape image
            landscape = true
            let height = self.frame.height
            let width = self.frame.height * imageRatio
            let origin = CGPoint.zero
            let frame = CGRect(x: origin.x, y: origin.y,
                               width: width, height: height)
            imageView.frame = frame
        }
        imageView.image = image
        
        self.contentSize.height = imageView!.frame.height
        self.contentSize.width = imageView!.frame.width
    }
    
    func cropImage() -> UIImage {
        let cropArea = calculateCropArea()
        let croppedCGImage = imageView?.image?.cgImage?.cropping(to: cropArea)
        let croppedImage = UIImage(cgImage: croppedCGImage!)
        
        return croppedImage
    }
    
    func calculateCropArea() -> CGRect {
        let scale = 1 / self.zoomScale
        
        guard let imageView = self.imageView else {return CGRect.zero}
        guard let image = imageView.image else {return CGRect.zero}
        let heightRatio = image.size.height / imageView.frame.height
        let widthRatio = image.size.width / imageView.frame.width
        
        // Calculate how much of the image view isn't shown in the scroll view
        var width = image.size.width * scale
        var height = image.size.height * scale
        width = width > height ? height : width
        height = width > height ? height : width
        
        let xOffset = self.contentOffset.x
        let yOffset = self.contentOffset.y
        
        // Calculate how much Y is lost
        let x = xOffset * widthRatio
        let y = yOffset * heightRatio
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func shade(shaded: Bool) {
        if shaded {
            self.alpha = 0.5
        }
        else {
            self.alpha = 1.0
        }
    }
}
