//
//  DisplayImageViewController.swift
//  LocEightV_1
//
//  Created by Michelle Grover on 5/3/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit
import CoreData

class DisplayImageViewController: UIViewController {
    
    var managedObjectContext:NSManagedObjectContext!
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistantContainer.viewContext
        
        imageViewHeightConstraint.constant = imageView.bounds.width
        
        CoreDataStack.imageFromCoreData(managedObjectContext: managedObjectContext, imageView: imageView)
        
        imageView.layer.borderColor = UIColor.pink.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        
        view.backgroundColor = UIColor.cyanLightBlue
        
        
    }
    
    
    
    

    

}
