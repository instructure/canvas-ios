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

