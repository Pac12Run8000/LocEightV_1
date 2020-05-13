//
//  CoreDataStack.swift
//  LocEightV_1
//
//  Created by Michelle Grover on 4/18/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import Foundation
import UIKit

import CoreData

struct CoreDataStack {
    
    static func removeImage(vc:UIViewController, managedObjectContext:NSManagedObjectContext) {
        var annotationEntity:AnnotationEntity!
        
        let fetchRequest = NSFetchRequest<AnnotationEntity>(entityName: "AnnotationEntity")
        fetchRequest.fetchLimit = 1
        do {
            try annotationEntity = managedObjectContext.fetch(fetchRequest).first
        } catch {
            print("there was an error: \(error.localizedDescription)")
        }
        
        if annotationEntity != nil {
            annotationEntity.image = nil
        }
        
        do {
            try CoreDataStack.saveContext(context: managedObjectContext)
            Alert.alertNotification(vc: vc, title: "Notification", message: "The image was deleted.", buttonTitle: "Ok", style: .alert)
        } catch {
            print("There was a save error:\(error.localizedDescription)")
        }
    }
    
    static func imageFromCoreData(managedObjectContext:NSManagedObjectContext, imageView:UIImageView) {
        var annotationEntity:AnnotationEntity!
        var fetchRequest = NSFetchRequest<AnnotationEntity>(entityName: "AnnotationEntity")
        fetchRequest.fetchLimit = 1
        
        do {
            try annotationEntity = managedObjectContext.fetch(fetchRequest).first
        } catch {
            print("There was an error:\(error.localizedDescription)")
        }
        
        if annotationEntity != nil {
            if let infoData = annotationEntity.image {
                DispatchQueue.main.async {
                    imageView.image = UIImage(data: infoData)
                }
            }
        }
    }
    
    static func saveContext(context:NSManagedObjectContext) throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    static func deleteAllOfAnnotationEntity(managedObjectContext:NSManagedObjectContext) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "AnnotationEntity")
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            let result = try managedObjectContext.execute(request)
            print("Deletion completed")
        } catch {
            print("Error:\(error.localizedDescription)")
        }
    }
    
    static func updateImageForParkingInformation(image:UIImage, managedObjectContext:NSManagedObjectContext) {
        var annotationEntity:AnnotationEntity!
        let fetchRequest = NSFetchRequest<AnnotationEntity>(entityName: "AnnotationEntity")
        fetchRequest.fetchLimit = 1
        do {
            try annotationEntity = managedObjectContext.fetch(fetchRequest).first
        } catch {
            print("Fetch error:\(error.localizedDescription)")
        }
        
        if annotationEntity == nil {
            let annotationEntity = AnnotationEntity(context: managedObjectContext)
            annotationEntity.image = image.jpegData(compressionQuality: 1.0)
            print("Saved image")
        } else {
            annotationEntity.image = image.jpegData(compressionQuality: 1.0)
            print("Updated image")
        }
        
        do {
            try CoreDataStack.saveContext(context: managedObjectContext)
            print("transaction successful")
            
        } catch {
            print("Update error:\(error.localizedDescription)")
            
        }
        
    }
    
    
    static func fetchImage(managedObjectContext:NSManagedObjectContext) -> Bool {
        var annotationEntity:AnnotationEntity!
        let fetch = NSFetchRequest<AnnotationEntity>(entityName: "AnnotationEntity")
        fetch.fetchLimit = 1
        do {
            try annotationEntity = managedObjectContext.fetch(fetch).first
        } catch {
            print("fetch error:\(error.localizedDescription)")
        }
        
        if annotationEntity.image != nil {
            return true
        }
        return false
    }
    
    static func fetchTermsIsConfirmed(managedObjectContext:NSManagedObjectContext, completion:@escaping(_ isConfirmed:Bool,_ error:Error?) -> ()) {
        var termsEntity:TermsEntity!
        
        let fetchRequest = NSFetchRequest<TermsEntity>(entityName: "TermsEntity")
        fetchRequest.fetchLimit = 1

           do {
            termsEntity = try managedObjectContext.fetch(fetchRequest).first
           } catch {
               print("There was an error retrieving the data.")
           }
           guard (termsEntity as? TermsEntity) != nil else {
                print("core data hasn't been set so, not confirmed.")
                completion(false, nil)
                return
           }
        
        if let isConfirmed = termsEntity.confirmed as? Bool, isConfirmed == false {
            completion(false, nil)
        } else {
            completion(true, nil)
        }

           print("isConfirmed:\(termsEntity.confirmed == true ? "confirmed" : "not confirmed")")
    }
    
    
    static func deleteTermsEntity(managedObjectContext:NSManagedObjectContext) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "TermsEntity")
        let batchRequest = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try managedObjectContext.execute(batchRequest)
            print("Deleted the terms confirmation")
        } catch {
            print("error:\(error.localizedDescription)")
        }
    }
    
    static func confirmTerms(managedObjectContext:NSManagedObjectContext, completion:@escaping(_ success:Bool,_ error:Error?) -> ()) {
        var termsEntity:TermsEntity!
        let fetchRequest = NSFetchRequest<TermsEntity>(entityName: "TermsEntity")
        fetchRequest.fetchLimit = 1
        do {
            try termsEntity = managedObjectContext.fetch(fetchRequest).first
        } catch {
            print("There is an error:\(error.localizedDescription)")
        }
        
        if termsEntity == nil {
            let termsEntity = TermsEntity(context: managedObjectContext)
            termsEntity.confirmed = true
        } else {
            termsEntity.confirmed = true
        }
        
        do {
            try CoreDataStack.saveContext(context: managedObjectContext)
            completion(true, nil)
        } catch {
            completion(false, error)
            print("There was an error saving the terms data")
        }
    }
}
