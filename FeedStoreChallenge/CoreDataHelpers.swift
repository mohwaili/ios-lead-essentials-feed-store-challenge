//
//  CoreDataHelpers.swift
//  FeedStoreChallenge
//
//  Created by Mohammed Alwaili on 02/03/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

extension NSPersistentContainer {
	
	enum LoadingError: Error {
		case modelNotFound
		case failedToLoadPersistentStore(Error)
	}
	
	static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
		guard let modelURL = bundle.url(forResource: name, withExtension: "momd"),
			  let model = NSManagedObjectModel(contentsOf: modelURL) else {
			throw LoadingError.modelNotFound
		}
		let description = NSPersistentStoreDescription(url: url)
		let container = NSPersistentContainer(name: name, managedObjectModel: model)
		container.persistentStoreDescriptions = [description]
		
		var loadError: Error?
		container.loadPersistentStores { _, error in loadError = error }
		try loadError.map { throw LoadingError.failedToLoadPersistentStore($0) }
		
		return container
	}
	
}
