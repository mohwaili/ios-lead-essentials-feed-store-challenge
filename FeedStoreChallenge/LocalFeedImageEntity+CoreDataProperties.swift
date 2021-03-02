//
//  LocalFeedImageEntity+CoreDataProperties.swift
//  FeedStoreChallenge
//
//  Created by Mohammed Alwaili on 02/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData

extension LocalFeedImageEntity {

    @nonobjc class func fetchRequest() -> NSFetchRequest<LocalFeedImageEntity> {
        return NSFetchRequest<LocalFeedImageEntity>(entityName: "LocalFeedImageEntity")
    }

    @NSManaged var desc: String?
    @NSManaged var id: UUID
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: CacheEntity

}

extension LocalFeedImageEntity : Identifiable {

}
