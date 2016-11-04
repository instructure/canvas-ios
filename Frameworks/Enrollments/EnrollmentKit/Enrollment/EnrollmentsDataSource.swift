
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
    
    

import Foundation
import TooLegit
import SoPersistent
import CoreData
import SoLazy
import ReactiveCocoa
import Result

public protocol ContextDataSource: class {
    var enrollmentsByContextID: [ContextID: Enrollment] { get }

    subscript(contextID: ContextID) -> Enrollment? { get }
    
    /// sends the current value of enrollment followed by updated values over time
    func producer(contextID: ContextID) -> SignalProducer<Enrollment?, NoError>
    
    func setColor(color: UIColor, inSession session: Session, forContextID contextID: ContextID) -> SignalProducer<(), NSError>
}

class EnrollmentsDataSource: NSObject, ContextDataSource {
    // implicitly unwrapped because `init` can't throw before `collection` is set otherwise
    var collection: FetchedCollection<Enrollment>! = nil
    var enrollmentsByContextID: [ContextID: Enrollment] = [:]
    var pipesByContextID: [ContextID: (SignalProducer<Enrollment?, NoError>, Observer<Enrollment?, NoError>)] = [:]
    
    init(context: NSManagedObjectContext) throws {
        super.init()

        let fetch = NSFetchRequest(entityName: "Enrollment")
        fetch.returnsObjectsAsFaults = false
        fetch.includesPropertyValues = true
        fetch.sortDescriptors = ["id".ascending]
        let frc = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        collection = try FetchedCollection(frc: frc)
        setup()
        collection.collectionUpdated = { [unowned self] updates in
            self.processCollectionUpdates(updates)
        }
    }
    
    func processCollectionUpdates(updates: [CollectionUpdate<Enrollment>]) {
        for update in updates {
            switch update {
            case .Updated(_, let enrollment):
                pipesByContextID[enrollment.contextID]?.1.sendNext(enrollment)
            case .Inserted(_, let enrollment):
                let contextID = enrollment.contextID
                enrollmentsByContextID[contextID] = enrollment
                pipesByContextID[enrollment.contextID]?.1.sendNext(enrollment)
            case .Deleted(_, let enrollment):
                pipesByContextID[enrollment.contextID] = nil
                enrollmentsByContextID[enrollment.contextID] = nil
            default: break
            }
        }
    }
    
    func setup() {
        for enrollment in collection {
            enrollmentsByContextID[enrollment.contextID] = enrollment
        }
    }
    
    subscript(contextID: ContextID) -> Enrollment? {
        return enrollmentsByContextID[contextID]
    }
    
    func producer(contextID: ContextID) -> SignalProducer<Enrollment?, NoError> {
        let signal: SignalProducer<Enrollment?, NoError>
        if let pipe = pipesByContextID[contextID] {
            signal = pipe.0
        } else {
            let pipe = SignalProducer<Enrollment?, NoError>.buffer(1)
            pipesByContextID[contextID] = pipe
            pipe.1.sendNext(enrollmentsByContextID[contextID])
            signal = pipe.0
        }
        
        return signal
    }
    
    
    // MARK: Changing things 
    func setColor(color: UIColor, inSession session: Session, forContextID contextID: ContextID) -> SignalProducer<(), NSError> {
        
        let updateColorAndSave: ()->SignalProducer<(), NSError> = {
            let enrollment = self.enrollmentsByContextID[contextID]
            enrollment?.color = color
            
            return attemptProducer { try enrollment?.managedObjectContext?.saveFRD() }
        }
        
        return Enrollment.put(session, color: color, forContextID: contextID)
            .concat(SignalProducer(value: ())) // this will trigger the save since put-ing the color has an empty reponse
            .observeOn(UIScheduler())
            .flatMap(.Merge, transform: updateColorAndSave)
    }
}

extension Session {
    private struct Associated {
        static var enrollmentsDataSource = "enrollmentsDataSource"
        static var scopedEnrollmentsDataSource = "scopedEnrollmentsDataSource"
    }
    
    public var enrollmentsDataSource: ContextDataSource {
        get {
            guard let source: ContextDataSource = getAssociatedObject(&Associated.enrollmentsDataSource) else {
                
                let context = try! enrollmentManagedObjectContext()
                let source = try! EnrollmentsDataSource(context: context)
                
                setAssociatedObject(source, forKey: &Associated.enrollmentsDataSource)
                return source
            }
            return source
        }
    }

    public func enrollmentsDataSource(withScope scope: String) -> ContextDataSource {
        guard let sources: NSMutableDictionary = getAssociatedObject(&Associated.scopedEnrollmentsDataSource) else {

            let context = try! enrollmentManagedObjectContext(scope)
            let source = try! EnrollmentsDataSource(context: context)
            let sources = NSMutableDictionary(dictionary: [scope: source])

            setAssociatedObject(sources, forKey: &Associated.scopedEnrollmentsDataSource)
            return source
        }

        guard let source = sources.objectForKey(scope) as? ContextDataSource else {

            let context = try! enrollmentManagedObjectContext(scope)
            let source = try! EnrollmentsDataSource(context: context)
            sources.setObject(source, forKey: scope)

            setAssociatedObject(sources, forKey: &Associated.scopedEnrollmentsDataSource)
            return source
        }

        return source
    }
}