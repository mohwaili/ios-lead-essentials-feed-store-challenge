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

    @NSManaged var id: UUID
    @NSManaged var desc: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
	@NSManaged var timestamp: Date
	@NSManaged var creationDate: Date

}
