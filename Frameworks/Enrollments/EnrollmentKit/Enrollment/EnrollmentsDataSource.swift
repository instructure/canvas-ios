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

public class EnrollmentsDataSource: NSObject {
    let enrollmentsObserver: ManagedObjectsObserver<Enrollment, ContextID>
    
    
    init(context: NSManagedObjectContext) throws {
        let fetch = NSFetchRequest(entityName: "Enrollment")
        fetch.returnsObjectsAsFaults = false
        fetch.includesPropertyValues = true
        fetch.sortDescriptors = ["id".ascending]
        let frc = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        enrollmentsObserver = ManagedObjectsObserver(context: context, collection: try FetchedCollection(frc: frc)) { $0.contextID }
        
        super.init()

    }
    
    public subscript(contextID: ContextID) -> Enrollment? {
        return enrollmentsObserver[contextID]
    }
    
    public func producer(contextID: ContextID) -> SignalProducer<Enrollment?, NoError> {
        return enrollmentsObserver.producer(contextID)
    }
    
    
    // MARK: Changing things 
    public func setColor(color: UIColor, inSession session: Session, forContextID contextID: ContextID) -> SignalProducer<(), NSError> {
        
        let updateColorAndSave: ()->SignalProducer<(), NSError> = {
            let enrollment = self.enrollmentsObserver[contextID]
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
    
    public var enrollmentsDataSource: EnrollmentsDataSource {
        get {
            guard let source: EnrollmentsDataSource = getAssociatedObject(&Associated.enrollmentsDataSource) else {
                
                let context = try! enrollmentManagedObjectContext()
                let source = try! EnrollmentsDataSource(context: context)
                
                setAssociatedObject(source, forKey: &Associated.enrollmentsDataSource)
                return source
            }
            return source
        }
    }

    public func enrollmentsDataSource(withScope scope: String) -> EnrollmentsDataSource {
        guard let sources: NSMutableDictionary = getAssociatedObject(&Associated.scopedEnrollmentsDataSource) else {

            let context = try! enrollmentManagedObjectContext(scope)
            let source = try! EnrollmentsDataSource(context: context)
            let sources = NSMutableDictionary(dictionary: [scope: source])

            setAssociatedObject(sources, forKey: &Associated.scopedEnrollmentsDataSource)
            return source
        }

        guard let source = sources.objectForKey(scope) as? EnrollmentsDataSource else {

            let context = try! enrollmentManagedObjectContext(scope)
            let source = try! EnrollmentsDataSource(context: context)
            sources.setObject(source, forKey: scope)

            setAssociatedObject(sources, forKey: &Associated.scopedEnrollmentsDataSource)
            return source
        }

        return source
    }
}
