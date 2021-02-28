//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge
import CoreData

final class CoreDataFeedStore: FeedStore {
	
	private let persistentContainer: NSPersistentContainer
	private let queue = DispatchQueue(label: "\(CoreDataFeedStore.self)Queue", qos: .userInitiated)
	
	init(persistentContainer: NSPersistentContainer) {
		self.persistentContainer = persistentContainer
		self.persistentContainer.loadPersistentStores(completionHandler: { _,_ in })
	}
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		queue.async { [weak self] in
			guard let self = self else { return }
			let context = self.persistentContainer.viewContext
			let request = NSFetchRequest<LocalFeedImageEntity>(entityName: "LocalFeedImageEntity")
			do {
				let entities = try context.fetch(request)
				for entity in entities {
					context.delete(entity)
				}
				if context.hasChanges {
					try context.save()
				}
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		deleteCachedFeed { _ in }
		queue.async { [weak self] in
			guard let self = self else { return }
			let context = self.persistentContainer.viewContext
			for item in feed {
				let entity = self.entity(from: item, and: timestamp)
				context.insert(entity)
			}
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
	
	func retrieve(completion: @escaping RetrievalCompletion) {
		let context = persistentContainer.newBackgroundContext()
		let request = NSFetchRequest<LocalFeedImageEntity>(entityName: "LocalFeedImageEntity")
		let creationDateSortDescription = NSSortDescriptor(key: "creationDate", ascending: true)
		request.sortDescriptors = [creationDateSortDescription]
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
	
	// MARK: - Private
	
	private func entity(from localFeedImage: LocalFeedImage, and timestamp: Date) -> LocalFeedImageEntity {
		let entity = LocalFeedImageEntity(context: persistentContainer.viewContext)
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

class FeedStoreChallengeTests: XCTestCase, FeedStoreSpecs {
	
	//  ***********************
	//
	//  Follow the TDD process:
	//
	//  1. Uncomment and run one test at a time (run tests with CMD+U).
	//  2. Do the minimum to make the test pass and commit.
	//  3. Refactor if needed and commit again.
	//
	//  Repeat this process until all tests are passing.
	//
	//  ***********************
	
	func test_retrieve_deliversEmptyOnEmptyCache() throws {
		let sut = try makeSUT()
		
		assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnEmptyCache() throws {
		let sut = try makeSUT()

		assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_retrieve_deliversFoundValuesOnNonEmptyCache() throws {
		let sut = try makeSUT()

		assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() throws {
		let sut = try makeSUT()

		assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
	}
	
	func test_insert_deliversNoErrorOnEmptyCache() throws {
		let sut = try makeSUT()

		assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
	}
	
	func test_insert_deliversNoErrorOnNonEmptyCache() throws {
		let sut = try makeSUT()

		assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_insert_overridesPreviouslyInsertedCacheValues() throws {
		let sut = try makeSUT()

		assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
	}
	
	func test_delete_deliversNoErrorOnEmptyCache() throws {
		let sut = try makeSUT()

		assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
	}
	
	func test_delete_hasNoSideEffectsOnEmptyCache() throws {
		let sut = try makeSUT()

		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_delete_deliversNoErrorOnNonEmptyCache() throws {
		let sut = try makeSUT()

		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_delete_emptiesPreviouslyInsertedCache() throws {
		let sut = try makeSUT()

		assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
	}
	
	func test_storeSideEffects_runSerially() throws {
//		let sut = try makeSUT()
//
//		assertThatSideEffectsRunSerially(on: sut)
	}
	
	// - MARK: Helpers
	
	private func makeSUT() throws -> FeedStore {
		return CoreDataFeedStore(persistentContainer: makeTestPersistentContainer())
	}
	
	private func makeTestPersistentContainer() -> NSPersistentContainer {
		let modelPath = Bundle(for: LocalFeedImageEntity.self).path(forResource: "LocalFeedImageModel", ofType: "momd")
		let modelURL = URL(fileURLWithPath: modelPath!)
		let model = NSManagedObjectModel(contentsOf: modelURL)!
		
		let persistentContainer = NSPersistentContainer(name: "LocalFeedImageModel", managedObjectModel: model)

		let inMemoryStoreDescription = NSPersistentStoreDescription()
		inMemoryStoreDescription.type = NSInMemoryStoreType
		inMemoryStoreDescription.shouldAddStoreAsynchronously = false
		persistentContainer.persistentStoreDescriptions = [inMemoryStoreDescription]
		persistentContainer.loadPersistentStores(completionHandler: { _, _ in })
		
		return persistentContainer
	}
	
}

//  ***********************
//
//  Uncomment the following tests if your implementation has failable operations.
//
//  Otherwise, delete the commented out code!
//
//  ***********************

//extension FeedStoreChallengeTests: FailableRetrieveFeedStoreSpecs {
//
//	func test_retrieve_deliversFailureOnRetrievalError() throws {
////		let sut = try makeSUT()
////
////		assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
//	}
//
//	func test_retrieve_hasNoSideEffectsOnFailure() throws {
////		let sut = try makeSUT()
////
////		assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
//	}
//
//}

//extension FeedStoreChallengeTests: FailableInsertFeedStoreSpecs {
//
//	func test_insert_deliversErrorOnInsertionError() throws {
////		let sut = try makeSUT()
////
////		assertThatInsertDeliversErrorOnInsertionError(on: sut)
//	}
//
//	func test_insert_hasNoSideEffectsOnInsertionError() throws {
////		let sut = try makeSUT()
////
////		assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
//	}
//
//}

//extension FeedStoreChallengeTests: FailableDeleteFeedStoreSpecs {
//
//	func test_delete_deliversErrorOnDeletionError() throws {
////		let sut = try makeSUT()
////
////		assertThatDeleteDeliversErrorOnDeletionError(on: sut)
//	}
//
//	func test_delete_hasNoSideEffectsOnDeletionError() throws {
////		let sut = try makeSUT()
////
////		assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
//	}
//
//}
