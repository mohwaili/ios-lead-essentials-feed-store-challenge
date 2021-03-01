//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

class FeedStoreIntegrationTests: XCTestCase {
	
	//  ***********************
	//
	//  Uncomment and implement the following tests if your
	//  implementation persists data to disk (e.g., CoreData/Realm)
	//
	//  ***********************
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		
		try setupEmptyStoreState()
	}
	
	override func tearDownWithError() throws {
		try undoStoreSideEffects()
		
		try super.tearDownWithError()
	}
	
	func test_retrieve_deliversEmptyOnEmptyCache() throws {
		let sut = try makeSUT()

		expect(sut, toRetrieve: .empty)
	}
	
	func test_retrieve_deliversFeedInsertedOnAnotherInstance() throws {
		let storeToInsert = try makeSUT()
		let storeToLoad = try makeSUT()
		let feed = uniqueImageFeed()
		let timestamp = Date()

		insert((feed, timestamp), to: storeToInsert)

		expect(storeToLoad, toRetrieve: .found(feed: feed, timestamp: timestamp))
	}
	
	func test_insert_overridesFeedInsertedOnAnotherInstance() throws {
		let storeToInsert = try makeSUT()
		let storeToOverride = try makeSUT()
		let storeToLoad = try makeSUT()

		insert((uniqueImageFeed(), Date()), to: storeToInsert)

		let latestFeed = uniqueImageFeed()
		let latestTimestamp = Date()
		insert((latestFeed, latestTimestamp), to: storeToOverride)

		expect(storeToLoad, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
	}
	
	func test_delete_deletesFeedInsertedOnAnotherInstance() throws {
		let storeToInsert = try makeSUT()
		let storeToDelete = try makeSUT()
		let storeToLoad = try makeSUT()

		insert((uniqueImageFeed(), Date()), to: storeToInsert)

		deleteCache(from: storeToDelete)

		expect(storeToLoad, toRetrieve: .empty)
	}
	
	// - MARK: Helpers
	
	private func makeSUT() throws -> FeedStore {
		return CoreDataFeedStore(persistentContainer:
			makeTestPersistentContainer())
	}
	
	private func setupEmptyStoreState() throws {
		try removeTestStore()
	}
	
	private func undoStoreSideEffects() throws {
		try removeTestStore()
	}
	
	func removeTestStore() throws {
		let fileManager = FileManager.default
		guard fileManager.fileExists(atPath: testStoreURL.path) else {
			return
		}
		try fileManager.removeItem(at: testStoreURL)
	}
	
	private func cacheDirectory() -> URL {
		FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
	}
	
	private var testStoreURL: URL {
		cacheDirectory().appendingPathComponent("\(String(describing: self)).store")
	}
	
	private func makeTestPersistentContainer() -> NSPersistentContainer {
		let modelPath = Bundle(for: LocalFeedImageEntity.self).path(forResource: "LocalFeedImageModel", ofType: "momd")
		let modelURL = URL(fileURLWithPath: modelPath!)
		let model = NSManagedObjectModel(contentsOf: modelURL)!

		let persistentContainer = NSPersistentContainer(name: "LocalFeedImageModel", managedObjectModel: model)

		let storeDescription = NSPersistentStoreDescription(url: testStoreURL)
		persistentContainer.persistentStoreDescriptions = [storeDescription]
		persistentContainer.loadPersistentStores(completionHandler: { _, _ in })

		return persistentContainer
	}
	
}
