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


import CoreData

import ReactiveSwift
import Result


open class EnrollmentsDataSource: NSObject {
    public let enrollmentsObserver: ManagedObjectsObserver<Enrollment, ContextID>
    
    init(context: NSManagedObjectContext) throws {
        let fetch = NSFetchRequest<Enrollment>(entityName: "Enrollment")
        fetch.returnsObjectsAsFaults = false
        fetch.includesPropertyValues = true
        fetch.sortDescriptors = ["id".ascending]
        let frc = NSFetchedResultsController<Enrollment>(fetchRequest: fetch, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        enrollmentsObserver = ManagedObjectsObserver(context: context, collection: try FetchedCollection(frc: frc)) { $0.contextID }
        
        super.init()

    }
    
    open subscript(contextID: ContextID) -> Enrollment? {
        return enrollmentsObserver[contextID]
    }
    
    open func producer(_ contextID: ContextID) -> SignalProducer<Enrollment?, NoError> {
        return enrollmentsObserver.producer(contextID)
    }
    
    open func color(for contextID: ContextID) -> SignalProducer<UIColor, NoError> {
        let prettyGray = SignalProducer<UIColor, NoError>(value: .prettyGray())
        
        return producer(contextID)
            .flatMap(.latest) { (enrollment: Enrollment?) -> SignalProducer<UIColor, NoError> in
                var course = enrollment
                if let group = enrollment as? Group,
                    group.color.value == nil ||
                    group.color.value!.hex == UIColor.prettyGray().hex, // assumes gray is only ever default, never explicitly set
                    let courseID = group.courseID {
                    course = self.enrollmentsObserver[ContextID.course(withID: courseID)]
                }
                return course?.color.producer.skipNil() ?? prettyGray
            }
    }
    
    @objc open func arcLTIToolId(forCanvasContext canvasContext: String) -> String? {
        guard let contextID = ContextID(canvasContext: canvasContext) else { return nil }
        let enrollment = self.enrollmentsObserver[contextID]
        return enrollment?.arcLTIToolID
    }
    
    @objc open func getGaugeLTILaunchURL(inSession session: Session, completion: @escaping (URL?)->Void) {
        let _ = try? Enrollment.getGaugeLTILaunchURL(session).observe(on: UIScheduler()).on(value: { url in
            completion(url)
        }).start()
    }
    
    // MARK: Changing things 
    open func setColor(_ color: UIColor, inSession session: Session, forContextID contextID: ContextID) -> SignalProducer<(), NSError> {
        
        let updateColorAndSave: ()->SignalProducer<(), NSError> = {
            let enrollment = self.enrollmentsObserver[contextID]
            enrollment?.color.value = color
            
            return attemptProducer { try enrollment?.managedObjectContext?.saveFRD() }
        }
        
        return Enrollment.put(session, color: color, forContextID: contextID)
            .concat(SignalProducer(value: ())) // this will trigger the save since put-ing the color has an empty reponse
            .observe(on: UIScheduler())
            .flatMap(.merge, transform: updateColorAndSave)
    }
}

extension Session {
    fileprivate struct Associated {
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

        guard let source = sources.object(forKey: scope) as? EnrollmentsDataSource else {

            let context = try! enrollmentManagedObjectContext(scope)
            let source = try! EnrollmentsDataSource(context: context)
            sources.setObject(source, forKey: scope as NSString)

            setAssociatedObject(sources, forKey: &Associated.scopedEnrollmentsDataSource)
            return source
        }

        return source
    }
}
