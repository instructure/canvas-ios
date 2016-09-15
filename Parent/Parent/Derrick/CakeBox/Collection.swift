//
//  Collection.swift
//
//  Created by Derrick Hathaway on 7/17/15.
//

import Foundation
import CoreData

public enum CollectionUpdate {
    case SectionInserted(Int)
    case SectionDeleted(Int)
    
    case Inserted(NSIndexPath)
    case Updated(NSIndexPath)
    case Moved(NSIndexPath, NSIndexPath)
    case Deleted(NSIndexPath)
}

public protocol ViewModelCollection: class {
    typealias ViewModel
    
    var collectionUpdated: [CollectionUpdate] -> () { get set }
    
    var numberOfSections: Int { get }
    
    func numberOfItemsInSection(section: Int) -> Int
    
    func titleForSection(section: Int) -> String
    
    subscript(indexPath: NSIndexPath) -> ViewModel { get }
}

public class FetchedCollection<M, VM>: NSObject, ViewModelCollection, NSFetchedResultsControllerDelegate {
    public typealias ViewModel = VM
    public typealias Model = M
    
    private let frc: NSFetchedResultsController
    private var updateBatch: [CollectionUpdate] = []
    public var collectionUpdated: [CollectionUpdate]->() = { _ in print("noone is watching") }
    
    let viewModelFactory: Model->ViewModel
    
    public init(frc: NSFetchedResultsController, viewModelFactory: Model->ViewModel) throws {
        self.frc = frc
        self.viewModelFactory = viewModelFactory
        super.init()
        frc.delegate = self
        
        try frc.performFetch()
    }
    
    public var numberOfSections: Int {
        return frc.sections?.count ?? 0
    }
    
    public func numberOfItemsInSection(section: Int) -> Int {
        return frc.sections?[section].numberOfObjects ?? 0
    }
    
    public func titleForSection(section: Int) -> String {
        return frc.sections?[section].name ?? ""
    }
    
    public subscript(indexPath: NSIndexPath) -> ViewModel {
        
        
    // Holiday Extravaganza TODO: Use the type system, Derrick
    guard let m = frc.objectAtIndexPath(indexPath) as? Model else { fatalError("Fixme. make this guarded by the type system.") }
        return viewModelFactory(m)
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
        switch type {
        case .Insert:
            updateBatch.append(.Inserted(newIndexPath!))
            print("insert \(newIndexPath!)")
        case .Update:
            updateBatch.append(.Updated(indexPath!))
            print("update \(indexPath!)")
        case .Move:
            updateBatch.append(.Moved(indexPath!, newIndexPath!))
            print("move to \(newIndexPath!)")
        case .Delete:
            updateBatch.append(.Deleted(indexPath!))
            print("delete \(indexPath!)")
        }
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionUpdated(updateBatch)
        updateBatch = []
    }
}

