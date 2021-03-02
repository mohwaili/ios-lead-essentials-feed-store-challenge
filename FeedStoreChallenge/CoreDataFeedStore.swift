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
				if let cache = try CacheEntity.fetch(in: context) {
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
			do {
				let newCache = try CacheEntity.newInstance(in: context)
				newCache.timestamp = timestamp
				newCache.feed = NSOrderedSet(array: LocalFeedImageEntity.entities(from: feed, in: context))
				context.insert(newCache)
				try context.save()
				completion(nil)
			} catch {
				completion(error)
			}
		}
		
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		perform { context in
			do {
				if let cache = try CacheEntity.fetch(in: context) {
					completion(.found(feed: CacheEntity.localFeed(from: cache.feed), timestamp: cache.timestamp))
				} else {
					completion(.empty)
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
			LocalFeedImage(id: entity.id, description: entity.desc, location: entity.location, url: entity.url)
		}
	}
	
}

private extension LocalFeedImageEntity {
	
	static func entities(from images: [LocalFeedImage], in context: NSManagedObjectContext) -> [LocalFeedImageEntity] {
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

private extension CacheEntity {
	
	static func localFeed(from entities: NSOrderedSet) -> [LocalFeedImage] {
		entities.compactMap { $0 as? LocalFeedImageEntity }.feed
	}
	
}
