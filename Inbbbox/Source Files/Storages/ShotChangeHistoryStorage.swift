//
//  ShotChangeHistoryStorage.swift
//  Inbbbox
//
//  Created by Peter Bruz on 07/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import CoreData

final class ShotChangeHistoryStorage {
    
    private static let EntityName = "ShotChange"
    
    private enum Attribute: String {
        case ShotID = "shot_id"
        case OperationType = "operation_type"
        case BucketID = "bucket_id"
    }
    
    private static let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    private static let managedContext = appDelegate.managedObjectContext
    private static let entity = NSEntityDescription.entityForName(EntityName, inManagedObjectContext: managedContext)
    private static let fetchRequest = NSFetchRequest(entityName: EntityName)
    
    class func insertRecord(shotID: Int, operation: ShotOperation, bucketID: Int? = nil) throws {
        
        let changeRecord = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        changeRecord.setValue(shotID, forKey: Attribute.ShotID.rawValue)
        changeRecord.setValue(operation.rawValue, forKey: Attribute.OperationType.rawValue)
        
        do {
            try managedContext.save()
        } catch {
            throw error
        }
    }
    
    class func allRecords() throws -> Array<ShotChange>? {
        
        do {
            guard let results = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject] else { return nil }
            
            var changeHistory = Array<ShotChange>()
            
            _ = results.map {
                changeHistory.append(ShotChange(shotID: $0.valueForKey(Attribute.ShotID.rawValue) as! Int, operation: ShotOperation(rawValue: $0.valueForKey(Attribute.OperationType.rawValue) as! Int)!, bucketID: $0.valueForKey(Attribute.BucketID.rawValue) as? Int))
            }
            
            return changeHistory
            
        } catch {
            throw error
        }
    }
    
    class func clearHistory() throws {
        
        do {
            if let objects = try! managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
                _ = objects.map { managedContext.deleteObject($0) }
                
                try managedContext.save()
            }
        } catch {
            throw error
        }
    }
}

struct ShotChange {
    
    var shotID: Int
    var operationType: ShotOperation
    var bucketID: Int?
    
    init(shotID: Int, operation: ShotOperation, bucketID: Int? = nil) {
        self.shotID = shotID
        operationType = operation
    }
}

enum ShotOperation: Int {
    case Like = 0
    case Unlike = 1
    case AddToBucket = 2
    case RemoveFromBucket = 3
}