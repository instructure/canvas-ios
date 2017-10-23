//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

//
//  ViewModelCollection.swift
//
//  Created by Derrick Hathaway on 7/17/15.
//

import Foundation
import CoreData

import ReactiveSwift
import Result

open class FetchedCollection<Model>: NSObject, Collection, Sequence, NSFetchedResultsControllerDelegate where Model: NSManagedObject {
    public typealias Object = Model
    
    let fetchedResultsController: NSFetchedResultsController<Model>
    let titleForSectionTitle: (String?)->String?

    open let collectionUpdates: Signal<[CollectionUpdate<Model>], NoError>
    internal let updatesObserver: Observer<[CollectionUpdate<Model>], NoError>
    
    open func reload() {
        
    }

    public init(frc: NSFetchedResultsController<Model>, titleForSectionTitle: @escaping (String?)->String? = { $0 }) throws {
        self.fetchedResultsController = frc
        self.titleForSectionTitle = titleForSectionTitle
        (collectionUpdates, updatesObserver) = Signal.pipe()
        super.init()
        frc.delegate = self
        try frc.performFetch()
    }
    
    deinit {
        self.fetchedResultsController.delegate = nil
    }
    
    open var isEmpty: Bool {
        return fetchedResultsController.fetchedObjects?.isEmpty ?? true
    }

    open func numberOfSections() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    open func numberOfItemsInSection(_ section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    open func titleForSection(_ section: Int) -> String? {
        return titleForSectionTitle(fetchedResultsController.sections?[section].name)
    }
    
    open subscript(indexPath: IndexPath) -> Object {
        return fetchedResultsController.object(at: indexPath)
    }

    public func indexPath(forObject object: Model) -> IndexPath? {
        return fetchedResultsController.indexPath(forObject: object)
    }
    
    open var first: Object? {
        return fetchedResultsController.fetchedObjects?.first
    }
    
    open var last: Object? {
        return fetchedResultsController.fetchedObjects?.last
    }
    
    open var count: Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    open func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updatesObserver.send(value: [.reload])
    }
    
}

public struct FetchedResultsControllerGenerator<T: NSManagedObject>: IteratorProtocol {
    public typealias Element = T
    
    var index: Int = 0
    let fetchedResultsController: NSFetchedResultsController<T>
    
    init(fetchedResultsController: NSFetchedResultsController<T>) {
        self.fetchedResultsController = fetchedResultsController
    }
    
    public mutating func next() -> T? {
        guard let count = fetchedResultsController.fetchedObjects?.count else { return nil}
        guard index < count else { return nil }
        defer { index += 1 }
        return fetchedResultsController.fetchedObjects?[index]
    }
}

extension FetchedCollection {
    public func makeIterator() -> FetchedResultsControllerGenerator<Object> {
        return FetchedResultsControllerGenerator<Object>(fetchedResultsController: fetchedResultsController)
    }
}
