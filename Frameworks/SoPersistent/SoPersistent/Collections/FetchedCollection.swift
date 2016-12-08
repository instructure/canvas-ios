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
import SoLazy
import ReactiveCocoa
import Result

extension NSIndexPath {
    var safeCopy: NSIndexPath {
        guard let path = copy() as? NSIndexPath else { ❨╯°□°❩╯⌢"copy should be safe, !" }
        
        return path
    }
}

public class FetchedCollection<Model where Model: NSManagedObject>: NSObject, Collection, SequenceType, NSFetchedResultsControllerDelegate {
    public typealias Object = Model
    
    let fetchedResultsController: NSFetchedResultsController
    let titleForSectionTitle: String?->String?

    private var updateBatch: [CollectionUpdate<Object>] = []
    
    public let collectionUpdates: Signal<[CollectionUpdate<Model>], NoError>
    internal let updatesObserver: Observer<[CollectionUpdate<Model>], NoError>
    
    public func reload() {
        
    }

    public init(frc: NSFetchedResultsController, titleForSectionTitle: String?->String? = { $0 }) throws {
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
    
    public var isEmpty: Bool {
        return fetchedResultsController.fetchedObjects?.isEmpty ?? true
    }

    public func numberOfSections() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    public func numberOfItemsInSection(section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    public func titleForSection(section: Int) -> String? {
        return titleForSectionTitle(fetchedResultsController.sections?[section].name)
    }
    
    public subscript(indexPath: NSIndexPath) -> Object {
        guard let m = fetchedResultsController.objectAtIndexPath(indexPath) as? Object else { ❨╯°□°❩╯⌢"You must have your entities crossed" }
        return m
    }
    
    public var first: Object? {
        return fetchedResultsController.fetchedObjects?.first as? Object
    }
    
    public var last: Object? {
        return fetchedResultsController.fetchedObjects?.last as? Object
    }
    
    public var count: Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        updateBatch = []
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            updateBatch.append(.SectionInserted(sectionIndex))
        case .Delete:
            updateBatch.append(.SectionDeleted(sectionIndex))
        default:
            break // NA sections only insert and delete
        }
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        guard let m = anObject as? Object else { ❨╯°□°❩╯⌢"Make sure the entity type for your FRC matches M" }
        
        switch type {
        case .Insert:
            updateBatch.append(.Inserted(newIndexPath!.safeCopy, m))
        case .Update:
            if let newIndexPath = newIndexPath {
                // RADAR (rdar://279557917): Sends an `update` with two index paths so it's actually a move.
                updateBatch.append(.Deleted(indexPath!.safeCopy, m))
                updateBatch.append(.Inserted(newIndexPath.safeCopy, m))
                return
            }
            updateBatch.append(.Updated(indexPath!.safeCopy, m))
        case .Move:
            let from = indexPath!.safeCopy
            let to = newIndexPath!.safeCopy
            guard from != to else {
                updateBatch.append(.Updated(from, m))
                return
            }
            updateBatch.append(.Moved(from, to, m))
        case .Delete:
            updateBatch.append(.Deleted(indexPath!.safeCopy, m))
        }
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        updatesObserver.sendNext(updateBatch)
    }
    
}

public struct FetchedResultsControllerGenerator<T>: GeneratorType {
    public typealias Element = T
    
    var index: Int = 0
    let fetchedResultsController: NSFetchedResultsController
    
    init(fetchedResultsController: NSFetchedResultsController) {
        self.fetchedResultsController = fetchedResultsController
    }
    
    public mutating func next() -> T? {
        guard index < fetchedResultsController.fetchedObjects?.count else { return nil }
        defer { index += 1 }
        return fetchedResultsController.fetchedObjects?[index] as? T
    }
}

extension FetchedCollection {
    public func generate() -> FetchedResultsControllerGenerator<Object> {
        return FetchedResultsControllerGenerator<Object>(fetchedResultsController: fetchedResultsController)
    }
}
