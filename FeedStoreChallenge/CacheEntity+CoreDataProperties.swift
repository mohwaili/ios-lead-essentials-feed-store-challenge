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

// MARK: Generated accessors for feed
extension CacheEntity {

    @objc(insertObject:inFeedAtIndex:)
    @NSManaged func insertIntoFeed(_ value: LocalFeedImageEntity, at idx: Int)

    @objc(removeObjectFromFeedAtIndex:)
    @NSManaged func removeFromFeed(at idx: Int)

    @objc(insertFeed:atIndexes:)
    @NSManaged func insertIntoFeed(_ values: [LocalFeedImageEntity], at indexes: NSIndexSet)

    @objc(removeFeedAtIndexes:)
    @NSManaged func removeFromFeed(at indexes: NSIndexSet)

    @objc(replaceObjectInFeedAtIndex:withObject:)
    @NSManaged func replaceFeed(at idx: Int, with value: LocalFeedImageEntity)

    @objc(replaceFeedAtIndexes:withFeed:)
    @NSManaged func replaceFeed(at indexes: NSIndexSet, with values: [LocalFeedImageEntity])

    @objc(addFeedObject:)
    @NSManaged func addToFeed(_ value: LocalFeedImageEntity)

    @objc(removeFeedObject:)
    @NSManaged func removeFromFeed(_ value: LocalFeedImageEntity)

    @objc(addFeed:)
    @NSManaged func addToFeed(_ values: NSOrderedSet)

    @objc(removeFeed:)
    @NSManaged func removeFromFeed(_ values: NSOrderedSet)

}

extension CacheEntity : Identifiable {

}
