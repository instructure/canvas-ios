//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
