//
//  LocalFeedImageEntity+CoreDataProperties.swift
//  FeedStoreChallenge
//
//  Created by Mohammed Al Waili on 28/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData


extension LocalFeedImageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalFeedImageEntity> {
        return NSFetchRequest<LocalFeedImageEntity>(entityName: "LocalFeedImageEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var desc: String?
    @NSManaged public var location: String?
    @NSManaged public var url: URL
	@NSManaged public var timestamp: Date

}
