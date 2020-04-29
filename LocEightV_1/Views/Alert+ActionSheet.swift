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
