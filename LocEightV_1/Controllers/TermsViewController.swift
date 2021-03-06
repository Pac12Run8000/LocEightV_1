//
//  TermsViewController.swift
//  LocEightV_1
//
//  Created by Michelle Grover on 5/12/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit
import CoreData
import WebKit

class TermsViewController: UIViewController {
    
    var managedObjectContext:NSManagedObjectContext!
    
    @IBOutlet weak var webKitView: WKWebView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUILayout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistantContainer.viewContext
        
        view.backgroundColor = UIColor.blue2
        
        
    }
    

    @IBAction func termsButtonAction(_ sender: Any) {
        CoreDataStack.confirmTerms(managedObjectContext: managedObjectContext) { (isSaved, error) in
            guard error == nil else {
                print("There was an error confirming the terms and conditions.")
                return
            }
            
            if isSaved {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    

}

// MARK:- UI Layout
extension TermsViewController {
    
    func configureUILayout() {
        webKitView.loadHTMLString(TermsAndConditions.getTermsAndConditionsText(), baseURL: nil)
    }
    
}




