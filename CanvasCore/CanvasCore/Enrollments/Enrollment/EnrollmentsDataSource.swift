//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import CoreData
import ReactiveSwift

open class EnrollmentsDataSource: NSObject {
    public let enrollmentsObserver: ManagedObjectsObserver<Enrollment, Context>
    
    @objc init(context: NSManagedObjectContext) throws {
        let fetch = NSFetchRequest<Enrollment>(entityName: "Enrollment")
        fetch.returnsObjectsAsFaults = false
        fetch.includesPropertyValues = true
        fetch.sortDescriptors = ["id".ascending]
        let frc = NSFetchedResultsController<Enrollment>(fetchRequest: fetch, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        enrollmentsObserver = ManagedObjectsObserver(context: context, collection: try FetchedCollection(frc: frc)) { $0.contextID }
        
        super.init()

    }
    
    open subscript(contextID: Context) -> Enrollment? {
        return enrollmentsObserver[contextID]
    }
    
    open func producer(_ contextID: Context) -> SignalProducer<Enrollment?, Never> {
        return enrollmentsObserver.producer(contextID)
    }
    
    open func color(for contextID: Context) -> SignalProducer<UIColor, Never> {
        let prettyGray = SignalProducer<UIColor, Never>(value: .prettyGray())
        
        return producer(contextID)
            .flatMap(.latest) { (enrollment: Enrollment?) -> SignalProducer<UIColor, Never> in
                var course = enrollment
                if let group = enrollment as? Group,
                    group.color.value == nil ||
                    group.color.value!.hex == UIColor.prettyGray().hex, // assumes gray is only ever default, never explicitly set
                    let courseID = group.courseID {
                    course = self.enrollmentsObserver[Context.course(courseID)]
                }
                return course?.color.producer.skipNil() ?? prettyGray
            }
    }
    
    @objc open func arcLTIToolId(forCanvasContext canvasContext: String) -> String? {
        guard let contextID = Context(canvasContextID: canvasContext) else { return nil }
        let enrollment = self.enrollmentsObserver[contextID]
        return enrollment?.arcLTIToolID
    }
    
    @objc open func getGaugeLTILaunchURL(inSession session: Session, completion: @escaping (URL?)->Void) {
        let _ = try? Enrollment.getGaugeLTILaunchURL(session).observe(on: UIScheduler()).on(value: { url in
            completion(url)
        }).start()
    }
    
    // MARK: Changing things 
    open func setColor(_ color: UIColor, inSession session: Session, forContextID contextID: Context) -> SignalProducer<(), NSError> {
        
        let updateColorAndSave: ()->SignalProducer<(), NSError> = {
            let enrollment = self.enrollmentsObserver[contextID]
            enrollment?.color.value = color
            
            return attemptProducer { try enrollment?.managedObjectContext?.saveFRD() }
        }
        
        return Enrollment.put(session, color: color, forContextID: contextID)
            .concat(SignalProducer(value: ())) // this will trigger the save since put-ing the color has an empty response
            .observe(on: UIScheduler())
            .flatMap(.merge, updateColorAndSave)
    }
}

extension Session {
    fileprivate struct Associated {
        static var enrollmentsDataSource = "enrollmentsDataSource"
        static var scopedEnrollmentsDataSource = "scopedEnrollmentsDataSource"
    }
    
    @objc public var enrollmentsDataSource: EnrollmentsDataSource {
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

    @objc public func enrollmentsDataSource(withScope scope: String) -> EnrollmentsDataSource {
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
