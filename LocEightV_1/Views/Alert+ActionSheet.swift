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
