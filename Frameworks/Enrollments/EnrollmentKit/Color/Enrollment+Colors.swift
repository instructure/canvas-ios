//
//  Enrollment+Colors.swift
//  Enrollments
//
//  Created by Derrick Hathaway on 3/9/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import TooLegit
import ReactiveCocoa
import Marshal

import CoreData
import SoPersistent

extension Enrollment {
    static func parseColors(json: JSONObject) -> SignalProducer<[ContextID: UIColor], NSError> {
        return attemptProducer {
            let customColors: JSONObject = try json <| "custom_colors"
            var contexts: [ContextID: UIColor] = [:]
            
            for (context, hex) in customColors {
                guard let contextID = ContextID(canvasContext: context) else { continue }
                guard let hex = hex as? String, color = UIColor.colorFromHexString(hex) else { continue }
                
                contexts[contextID] = color
            }
            
            return contexts
        }
    }
    
    static func getCustomColors(session: Session) -> SignalProducer<[ContextID: UIColor], NSError> {
        let path = "/api/v1/users/self/colors"
        
        return attemptProducer { try session.GET(path) }
            .flatMap(.Merge, transform: session.JSONSignalProducer)
            .flatMap(.Merge, transform: parseColors)
    }
    
    static func syncFavoriteColors(session: Session, inContext context: NSManagedObjectContext) -> SignalProducer<(), NSError> {
        let sync = context.syncContext
        return getCustomColors(session)
            .observeOn(ManagedObjectContextScheduler(context: sync))
            .flatMap(.Merge) { colors in
                return attemptProducer {
                    for (contextID, color) in colors {
                        let enrollment = try Enrollment.findOne(contextID, inContext: sync)
                        enrollment?.color = color
                    }
                    
                    try sync.save()
                }
            }
    }
}

