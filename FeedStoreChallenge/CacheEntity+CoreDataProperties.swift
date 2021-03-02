//
//  CacheEntity+CoreDataProperties.swift
//  FeedStoreChallenge
//
//  Created by Mohammed Alwaili on 02/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData

extension CacheEntity {

    @nonobjc class func fetchRequest() -> NSFetchRequest<CacheEntity> {
        return NSFetchRequest<CacheEntity>(entityName: "CacheEntity")
    }

    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet

}

extension CacheEntity {

}
