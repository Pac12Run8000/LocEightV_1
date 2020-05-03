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
    var annotationEntity:AnnotationEntity!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let fetchRequest = NSFetchRequest<AnnotationEntity>(entityName: "AnnotationEntity")
//        fetchRequest.fetchLimit = 1
//        do {
//            try annotationEntity = managedObjectContext.fetch(fetchRequest).first
//        } catch {
//            print("There was an error fetching data:\(error.localizedDescription)")
//        }
        
        
        
        managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistantContainer.viewContext
        
        
        imageViewHeightConstraint.constant = imageView.bounds.width
        
        
        var fetchRequest = NSFetchRequest<AnnotationEntity>(entityName: "AnnotationEntity")
        fetchRequest.fetchLimit = 1
        
        do {
            try annotationEntity = managedObjectContext.fetch(fetchRequest).first
        } catch {
            print("There was an error:\(error.localizedDescription)")
        }
        
        if annotationEntity != nil {
            if let infoData = annotationEntity.image {
                imageView.image = UIImage(data: infoData)
            }
        }
    }
    
    
    
    

    

}
