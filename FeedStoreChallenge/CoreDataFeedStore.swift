//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Mohammed Al Waili on 01/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

final public class CoreDataFeedStore: FeedStore {
	
	private let persistentContainer: NSPersistentContainer
	private let context: NSManagedObjectContext
	
	private let entityName: String = "LocalFeedImageEntity"
	
	public init(persistentContainer: NSPersistentContainer) {
		self.persistentContainer = persistentContainer
		self.persistentContainer.loadPersistentStores(completionHandler: { _,_ in })
		self.context = self.persistentContainer.newBackgroundContext()
	}
	
	public init(storeURL: URL, bundle: Bundle = .main) throws {
		self.persistentContainer = try NSPersistentContainer.load(modelName: "LocalFeedImageModel", url: storeURL, in: bundle)
		self.context = self.persistentContainer.newBackgroundContext()
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		let entityName = self.entityName
		perform { context in
			let request = NSFetchRequest<LocalFeedImageEntity>(entityName: entityName)
			do {
				let entities = try context.fetch(request)
				for entity in entities {
					context.delete(entity)
				}
				try context.save()
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		deleteCachedFeed { _ in }
		perform { context in
			let entities = LocalFeedImageEntity.entities(from: feed,
														 in: context,
														 and: timestamp)
			entities.forEach { context.insert($0) }
			do {
				if context.hasChanges {
					try context.save()
				}
				completion(nil)
			} catch {
				completion(error)
			}
		}
		
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		let entityName = self.entityName
		perform { context in
			let request = NSFetchRequest<LocalFeedImageEntity>(entityName: entityName)
			let creationDateSortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
			request.sortDescriptors = [creationDateSortDescriptor]
			do {
				let entities = try context.fetch(request)
				if entities.isEmpty {
					completion(.empty)
				} else {
					let timestmap = entities.first?.timestamp ?? Date()
					completion(.found(feed: entities.feed, timestamp: timestmap))
				}
			} catch {
				completion(.failure(error))
			}
		}
	}
	
	// MARK: - Private
	
	private func perform(block: @escaping (NSManagedObjectContext) -> Void) {
		let context = self.context
		context.perform {
			block(context)
		}
	}
	
}

private extension Array where Element == LocalFeedImageEntity {
	
	var feed: [LocalFeedImage] {
		self.map { entity in
			LocalFeedImage(id: entity.id,
						   description: entity.desc,
						   location: entity.location,
						   url: entity.url)
		}
	}
	
}

private extension LocalFeedImageEntity {
	
	static func entities(from images: [LocalFeedImage], in context: NSManagedObjectContext, and timestamp: Date) -> [LocalFeedImageEntity] {
		images.map { image -> LocalFeedImageEntity in
			let entity = LocalFeedImageEntity(context: context)
			entity.id = image.id
			entity.desc = image.description
			entity.location = image.location
			entity.url = image.url
			entity.timestamp = timestamp
			entity.creationDate = Date()
			return entity
		}
	}
	
}
