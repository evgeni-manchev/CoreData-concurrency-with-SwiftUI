//
//  CoreDataManager.swift
//  CoreDataToDO
//
//  Created by Evgeni Manchev on 20.11.19.
//  Copyright © 2019 Evgeni Manchev. All rights reserved.
//

import CoreData
import SwiftUI

class CoreDataManager {
    
    static let sharedInstance = CoreDataManager()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    lazy var saveManagedObjectContext: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.persistentStoreCoordinator = appDelegate.persistentContainer.persistentStoreCoordinator
        return moc
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.parent = self.saveManagedObjectContext
        return managedObjectContext
    }()
    
    let request : NSFetchRequest<ToDoItem> = ToDoItem.getAllToDoItems()
    
    func fetchItems() -> [ToDoItem] {
        if let results = try? CoreDataManager.sharedInstance.managedObjectContext.fetch(request) {
            return results
        } else {
            print("Could not fetch CoreData objects!")
            return [ToDoItem]()
        }
    }
    
    func saveContext() {
        guard  managedObjectContext.hasChanges || saveManagedObjectContext.hasChanges else {
            return
        }
        
        do {
            try CoreDataManager.sharedInstance.managedObjectContext.obtainPermanentIDs(for: Array(CoreDataManager.sharedInstance.managedObjectContext.insertedObjects))
        } catch {
            print("Failed to obtain permanent object IDs!")
        }
        
        managedObjectContext.performAndWait {
            do {
                try self.managedObjectContext.save()
            } catch {
                fatalError("Error saving main managed object context! \(error)")
            }
        }
        
        saveManagedObjectContext.perform {
            do {
                try self.saveManagedObjectContext.save()
            } catch {
                fatalError("Error saving private managed object context! \(error)")
            }
        }
    }
    
    func delete(object: ToDoItem) {
        let objectID = object.objectID
        
        if let object = try? saveManagedObjectContext.existingObject(with:objectID) {
            saveManagedObjectContext.delete(object)
            let startTime = CFAbsoluteTimeGetCurrent()
            
            saveContext()
            
            let endTime = CFAbsoluteTimeGetCurrent()
            let elapsedTime = (endTime - startTime) * 1000
            print("Deleting the object took \(elapsedTime) ms")
        } else {
            print("Could not delete object!")
        }
    }
}
