//
//  Alert+ActionSheet.swift
//  LocEightV_1
//
//  Created by Michelle Grover on 4/28/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import Foundation
import UIKit

struct Alert {
    
    static func insureUserActionsAlert(vc:UIViewController, title:String, msg:String, completionHandler:@escaping(_ areProceeding:Bool) -> ()) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Proceed", style: .default) { (action) in
            completionHandler(true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            completionHandler(false)
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        vc.present(alert, animated: true, completion: nil)
    }
    
}

struct ActionSheet {
    
    static func handleImageFunctionality(vc:UIViewController, title:String, message:String, completion handler:@escaping(_ imagePickerState:ImagePickerState) -> ()) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            handler(.photoLibrary)
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            handler(.camera)
        }
        let showImage = UIAlertAction(title: "Show Image", style: .default) { (action) in
            handler(.showImage)
        }
        let clearImage = UIAlertAction(title: "Remove Image", style: .default) { (action) in
            handler(.removeImage)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            handler(.cancel)
        }
        actionSheet.addAction(photoLibraryAction)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(showImage)
        actionSheet.addAction(clearImage)
        actionSheet.addAction(cancelAction)
        vc.present(actionSheet, animated: true, completion: nil)
        
        
    }
    
}


// MARK: Functionality to add image to actionsheet
extension UIAlertController {
    
    func addImage(image:UIImage) {
        let maxSize = CGSize(width: 245, height: 300)
        let imageSize = image.size
        var ratio:CGFloat!
        if imageSize.width > imageSize.height {
            ratio = maxSize.width / imageSize.width
        } else {
            ratio = maxSize.height / imageSize.height
        }
        
        let scaledSize = CGSize(width: imageSize.width * ratio, height: imageSize.height * ratio)
        
        let resizedImage = image.imageWithSize(size: scaledSize)
        
        
        let imageAction = UIAlertAction(title: "", style: .default, handler: nil)
        imageAction.isEnabled = false
        imageAction.setValue(resizedImage.withRenderingMode(.alwaysOriginal), forKey: "image")
        self.addAction(imageAction)
    }
}

extension UIImage {
    
    func imageWithSize(size:CGSize) -> UIImage {
        var scaledImageRect = CGRect.zero
        
        let aspectWidth:CGFloat = size.width / self.size.width
        let aspectHeight:CGFloat = size.height / self.size.height
        let aspectRatio:CGFloat = min(aspectWidth, aspectHeight)
        
        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard scaledImage != nil else {
            print("There is no scaled image")
            return UIImage()
        }
        
        return scaledImage!
    }
}


