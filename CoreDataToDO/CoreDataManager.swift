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
    
    lazy var mainManagedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.parent = self.saveManagedObjectContext
        return managedObjectContext
    }()
    
    func fetchItems() -> [ToDoItem] {
        let request : NSFetchRequest<ToDoItem> = ToDoItem.getAllToDoItems()
        if let results = try? CoreDataManager.sharedInstance.mainManagedObjectContext.fetch(request) {
            return results
        } else {
            print("Could not fetch CoreData objects!")
            return [ToDoItem]()
        }
    }
    
    func saveContext() {
        guard  mainManagedObjectContext.hasChanges || saveManagedObjectContext.hasChanges else {
            return
        }
        
        do {
            try CoreDataManager.sharedInstance.mainManagedObjectContext.obtainPermanentIDs(for: Array(CoreDataManager.sharedInstance.mainManagedObjectContext.insertedObjects))
        } catch {
            print("Failed to obtain permanent object IDs!")
        }
        
        mainManagedObjectContext.performAndWait {
            do {
                try self.mainManagedObjectContext.save()
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
