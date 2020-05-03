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
    
    static func saveContext(context:NSManagedObjectContext) throws {
        if context.hasChanges {
            try context.save()
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
}
