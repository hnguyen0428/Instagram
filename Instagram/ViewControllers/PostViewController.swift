//
//  PostViewController.swift
//  Instagram
//
//  Created by Hoang on 2/25/18.
//  Copyright © 2018 Hoang. All rights reserved.
//

import Photos
import UIKit

class PostViewController: UIViewController, UIImagePickerControllerDelegate,
                            UINavigationControllerDelegate, UICollectionViewDelegate,
                            UICollectionViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageCropper: ImageCropper!
    @IBOutlet weak var bottomBar: UIToolbar!
    
    var previous: Int?
    
    var imageArray = [UIImage]()
    var requestOptions: PHImageRequestOptions?
    var fetchResult: PHFetchResult<PHAsset>?
    
    var picked: Bool = false
    var chosenImage: UIImage?
    
    var slidUpCropperFrame: CGRect!
    var slidDownCropperFrame: CGRect!
    var slidDownCollectionViewHeight: CGFloat!
    var slidUp: Bool = false
    var midScrolling: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        slidDownCropperFrame = imageCropper.frame
        let slidUpPoint = CGPoint(x: imageCropper.frame.origin.x, y: imageCropper.frame.origin.y - imageCropper.frame.height)
        slidUpCropperFrame = CGRect(origin: slidUpPoint, size: imageCropper.frame.size)
        slidDownCollectionViewHeight = collectionView.frame.height
        
        imageCropper.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedCropper))
        imageCropper.addGestureRecognizer(tapGesture)
        
        setupCollectionView()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.tabBarController?.tabBar.isHidden = true
        configureNavbar()
        grabPhotos()
    }
    
    
    func configureNavbar() {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancel))
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.leftBarButtonItem?.tintColor = .black
        
        let nextButton = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(nextClicked))
        self.navigationItem.rightBarButtonItem = nextButton
        self.navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    func setupCollectionView() {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellsPerLine: CGFloat = 4
        layout.minimumInteritemSpacing = 1.0
        layout.minimumLineSpacing = 1.0
        let interItemSpacingTotal = layout.minimumInteritemSpacing * (cellsPerLine - 1)
        let width = view.frame.width / cellsPerLine -
            interItemSpacingTotal / cellsPerLine
        layout.itemSize = CGSize(width: width, height: width)
    }
    
    
    func showCamera() {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        
        vc.sourceType = .camera
        self.present(vc, animated: true, completion: nil)
    }
    
    func grabPhotos() {
        let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        self.requestOptions = requestOptions
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                         ascending: true)]
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image,
                                                             options: fetchOptions)
        self.fetchResult = fetchResult
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let side = layout.itemSize.width * CGFloat(2)
        
        if fetchResult.count > 0 {
            let group = DispatchGroup()
            for i in 0..<fetchResult.count {
                group.enter()
                imgManager.requestImage(for: fetchResult.object(at: i),
                                        targetSize: CGSize(width: side, height: side),
                                        contentMode: PHImageContentMode.aspectFill,
                                        options: requestOptions,
                                        resultHandler:
                    { (image, error) in
                        self.imageArray.append(image!)
                        group.leave()
                })
            }
            
            group.notify(queue: .main) {
                self.collectionView.reloadData()
                
                let imgManager = PHImageManager.default()
                imgManager.requestImage(for: fetchResult.object(at: 0),
                                        targetSize: PHImageManagerMaximumSize,
                                        contentMode: PHImageContentMode.aspectFill,
                                        options: requestOptions,
                                        resultHandler:
                    { (image, error) in
                        self.imageCropper.setupImage(image: image!)
                        self.chosenImage = image
                })
            }
        }
    }
    
    
    func slideCropper(up: Bool) {
        let slidDownY = slidDownCropperFrame.origin.y
        let slidUpY = slidUpCropperFrame.origin.y
        if up {
            self.midScrolling = true
            self.slidUp = true
            let slidUpCollectionViewHeight = bottomBar.frame.origin.y - slidUpCropperFrame.maxY
            let frame = CGRect(x: collectionView.frame.origin.x, y: collectionView.frame.origin.y,
                               width: collectionView.frame.width, height: slidUpCollectionViewHeight)
            UIView.animate(withDuration: 0.4, animations:{
                self.collectionView.frame = frame
                self.view.layoutIfNeeded()
            })
            UIView.animate(withDuration: 0.4, animations: {
                self.imageCropper.frame.origin.y = slidUpY
                self.collectionView.frame.origin.y = slidUpY + self.imageCropper.frame.height
            })
            self.navigationController?.navigationBar.isHidden = true
            imageCropper.shade(shaded: true)
        }
        else {
            self.midScrolling = true
            let frame = CGRect(x: collectionView.frame.origin.x, y: collectionView.frame.origin.y,
                               width: collectionView.frame.width, height: slidDownCollectionViewHeight)
            UIView.animate(withDuration: 0.4, animations:{
                self.collectionView.frame = frame
                self.view.layoutIfNeeded()
            })
            UIView.animate(withDuration: 0.4, animations: {
                self.imageCropper.frame.origin.y = slidDownY
                self.collectionView.frame.origin.y = slidDownY + self.imageCropper.frame.height
            }, completion: { _ in
                self.slidUp = false
            })
            self.navigationController?.navigationBar.isHidden = false
            imageCropper.shade(shaded: false)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        
        self.chosenImage = editedImage
        dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "captionSegue", sender: nil)
        })
    }
    
    @objc func tappedCropper(_ sender: UITapGestureRecognizer) {
        print(slidUp)
        if slidUp {
            print("Hello")
            slideCropper(up: false)
        }
    }
    
    @objc func nextClicked(_ sender: UIBarButtonItem) {
        if let _ = self.chosenImage {
            self.performSegue(withIdentifier: "captionSegue", sender: sender)
        }
    }
    
    
    @objc func cancel(_ sender: UIBarButtonItem) {
        if let previous = self.previous {
            tabBarController!.selectedIndex = previous
        }
    }
    
    
    @IBAction func clickedCamera(_ sender: UIBarButtonItem) {
        if slidUp {
            slideCropper(up: false)
        }
        self.midScrolling = false
        showCamera()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        if indexPath.row == 0 && !picked {
            cell.isSelected = true
        }
        cell.setImage(image: imageArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !picked {
            picked = true
            let firstIndexPath = IndexPath(row: 0, section: 0)
            collectionView.reloadItems(at: [firstIndexPath])
        }
        
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.isSelected = true
        
        let imgManager = PHImageManager.default()
        imgManager.requestImage(for: fetchResult!.object(at: indexPath.row),
                                targetSize: PHImageManagerMaximumSize,
                                contentMode: PHImageContentMode.aspectFill,
                                options: requestOptions,
                                resultHandler:
            { (image, error) in
                self.imageCropper.setupImage(image: image!)
                self.chosenImage = image!
        })
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            if midScrolling {
                return
            }
            
            let offset = scrollView.contentOffset.y
            
            if !slidUp && offset > 0 {
                slideCropper(up: true)
            }
            else if offset < 0 {
                slideCropper(up: false)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CaptionViewController {
            if sender is UIBarButtonItem {
                vc.photo = imageCropper.cropImage()
            }
            else {
                vc.photo = chosenImage
            }
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            midScrolling = false
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView == imageCropper {
            return imageCropper.imageView
        }
        return scrollView
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintAdjustmentMode = .normal
        self.navigationController?.navigationBar.tintAdjustmentMode = .automatic
        self.navigationController?.navigationBar.isHidden = slidUp
    }
    
}
