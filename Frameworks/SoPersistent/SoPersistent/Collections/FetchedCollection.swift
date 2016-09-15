//
//  ViewModelCollection.swift
//
//  Created by Derrick Hathaway on 7/17/15.
//

import Foundation
import CoreData
import SoLazy

extension NSIndexPath {
    var safeCopy: NSIndexPath {
        guard let path = copy() as? NSIndexPath else { ❨╯°□°❩╯⌢"copy should be safe, !" }
        
        return path
    }
}

public class FetchedCollection<Model>: NSObject, Collection, SequenceType, NSFetchedResultsControllerDelegate {
    public typealias Object = Model
    
    let fetchedResultsController: NSFetchedResultsController
    let titleForSectionTitle: String?->String?
    public var collectionUpdated: [CollectionUpdate<Object>]->() = { _ in print("no one is watching!") }
    var updateBatch: [CollectionUpdate<Object>] = []

    public init(frc: NSFetchedResultsController, titleForSectionTitle: String?->String? = { $0 }) throws {
        self.fetchedResultsController = frc
        self.titleForSectionTitle = titleForSectionTitle
        super.init()
        frc.delegate = self
        try frc.performFetch()
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
            updateBatch.append(.Updated(indexPath!.safeCopy, m))
            
        case .Move:
            let from = indexPath!.safeCopy
            let to = newIndexPath!.safeCopy
            updateBatch.append(.Moved(from, to, m))
        case .Delete:
            updateBatch.append(.Deleted(indexPath!.safeCopy, m))
        }
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionUpdated(updateBatch)
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