//
//  CoreDataStack.swift
//  LocEightV_1
//
//  Created by Michelle Grover on 4/18/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import Foundation

import CoreData

struct CoreDataStack {
    
    static func saveContext(context:NSManagedObjectContext) throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
