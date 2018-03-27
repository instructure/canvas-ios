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
    
    


import ReactiveSwift
import Marshal

import CoreData

typealias CustomColors = [ContextID: UIColor]

extension Enrollment {
    static func parseColors(_ json: JSONObject) throws -> CustomColors {
        let customColors: JSONObject = try json <| "custom_colors"
        var contexts: [ContextID: UIColor] = [:]
        
        for (context, hex) in customColors {
            guard let contextID = ContextID(canvasContext: context) else { continue }
            guard let hex = hex as? String, let color = UIColor.colorFromHexString(hex) else { continue }
            
            contexts[contextID] = color
        }
        
        return contexts
    }
    
    static func getCustomColors(_ session: Session) -> SignalProducer<JSONObject, NSError> {
        let path = "/api/v1/users/self/colors"
        
        return attemptProducer { try session.GET(path) }
            .flatMap(.merge, transform: session.JSONSignalProducer)
    }
    
    static func syncFavoriteColors(_ session: Session, inContext context: NSManagedObjectContext) -> SignalProducer<(), NSError> {
        return getCustomColors(session).flatMap(.merge) { writeFavoriteColors($0, inContext: context) }
    }

    static func writeFavoriteColors(_ colors: JSONObject, inContext context: NSManagedObjectContext) -> SignalProducer<(), NSError> {
        let write = { customColors in
            return SignalProducer<Void, NSError> { observer, _ in
                writeFavoriteColors(customColors, inContext: context.syncContext) { error in
                    if let error = error {
                        observer.send(error: error)
                        return
                    }
                    observer.send(value: ())
                    observer.sendCompleted()
                }
            }
            .observe(on: ManagedObjectContextScheduler(context: context.syncContext))
        }
        return attemptProducer { try parseColors(colors) }.flatMap(.latest, transform: write)
    }
    
    static func writeFavoriteColors(_ colors: CustomColors, inContext context: NSManagedObjectContext, completion: @escaping (NSError?) -> Void) {
        context.perform {
            do {
                for (contextID, color) in colors {
                    let enrollment = try Enrollment.findOne(contextID, inContext: context)
                    enrollment?.color.value = color
                }
                
                try context.saveFRD()
                completion(nil)
            } catch let e as NSError {
                completion(e)
            }
        }
    }
}

