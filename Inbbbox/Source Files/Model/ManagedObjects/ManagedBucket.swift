//
//  ManagedBucket.swift
//  Inbbbox
//
//  Created by Peter Bruz on 08/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import CoreData

class ManagedBucket: NSManagedObject {
    
    @NSManaged var mngd_identifier: String
    @NSManaged var mngd_name: String
    @NSManaged var mngd_htmlDescription: NSAttributedString?
    @NSManaged var mngd_shotsCount: NSNumber
    @NSManaged var mngd_createdAt: NSDate
    
    @NSManaged var shots: NSSet?
}

extension ManagedBucket: BucketType {
    var identifier: String { return mngd_identifier }
    var name: String { return mngd_name }
    var htmlDescription: NSAttributedString? { return mngd_htmlDescription }
    var shotsCount: Int { return mngd_shotsCount.integerValue}
    var createdAt: NSDate { return mngd_createdAt }
}
