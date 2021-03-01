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
	
	public init(persistentContainer: NSPersistentContainer) {
		self.persistentContainer = persistentContainer
		self.persistentContainer.loadPersistentStores(completionHandler: { _,_ in })
		self.context = self.persistentContainer.newBackgroundContext()
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		context.perform { [weak self] in
			guard let self = self else { return }
			let request = NSFetchRequest<LocalFeedImageEntity>(entityName: "LocalFeedImageEntity")
			do {
				let entities = try self.context.fetch(request)
				for entity in entities {
					self.context.delete(entity)
				}
				if self.context.hasChanges {
					try self.context.save()
				}
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		deleteCachedFeed { _ in }
		context.perform { [weak self] in
			guard let self = self else { return }
			for item in feed {
				let entity = self.entity(from: item, and: timestamp)
				self.context.insert(entity)
			}
			do {
				if self.context.hasChanges {
					try self.context.save()
				}
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		context.perform { [weak self] in
			guard let self = self else { return }
			let request = NSFetchRequest<LocalFeedImageEntity>(entityName: "LocalFeedImageEntity")
			let creationDateSortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
			request.sortDescriptors = [creationDateSortDescriptor]
			do {
				let entities = try self.context.fetch(request)
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
	
	private func entity(from localFeedImage: LocalFeedImage, and timestamp: Date) -> LocalFeedImageEntity {
		let entity = LocalFeedImageEntity(context: context)
		entity.id = localFeedImage.id
		entity.desc = localFeedImage.description
		entity.location = localFeedImage.location
		entity.url = localFeedImage.url
		entity.timestamp = timestamp
		entity.creationDate = Date()
		return entity
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
