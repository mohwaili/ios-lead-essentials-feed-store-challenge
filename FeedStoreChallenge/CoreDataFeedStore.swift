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
	
	public init(storeURL: URL, bundle: Bundle = .main) throws {
		self.persistentContainer = try NSPersistentContainer.load(modelName: "LocalFeedImageModel", url: storeURL, in: bundle)
		self.context = self.persistentContainer.newBackgroundContext()
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		perform { context in
			do {
				let request = NSFetchRequest<CacheEntity>(entityName: "CacheEntity")
				let caches = try context.fetch(request)
				for cache in caches {
					context.delete(cache)
				}
				try context.save()
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		perform { context in
			let cacheFetchRequest = NSFetchRequest<CacheEntity>(entityName: "CacheEntity")
			do {
				let caches = try context.fetch(cacheFetchRequest)
				for cache in caches {
					context.delete(cache)
				}
			} catch {
				completion(error)
				return
			}
			
			let newCache = CacheEntity(context: context)
			newCache.timestamp = timestamp
			let feedEntities = NSOrderedSet(array: LocalFeedImageEntity.entities(from: feed,
																				 in: context,
																				 and: timestamp))
			newCache.feed = feedEntities
			do {
				try context.save()
				completion(nil)
			} catch {
				completion(error)
			}
		}
		
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		perform { context in
			let request = NSFetchRequest<CacheEntity>(entityName: "CacheEntity")
			do {
				guard let cache = try context.fetch(request).first else {
					return completion(.empty)
				}
				let feedEntities = cache.feed.compactMap { $0 as? LocalFeedImageEntity }
				if feedEntities.isEmpty {
					completion(.empty)
				} else {
					completion(.found(feed: feedEntities.feed, timestamp: cache.timestamp))
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
	
	static func entities(from images: [LocalFeedImage],
						 in context: NSManagedObjectContext,
						 and timestamp: Date) -> [LocalFeedImageEntity] {
		images.map { image -> LocalFeedImageEntity in
			let entity = LocalFeedImageEntity(context: context)
			entity.id = image.id
			entity.desc = image.description
			entity.location = image.location
			entity.url = image.url
			return entity
		}
	}
	
}
