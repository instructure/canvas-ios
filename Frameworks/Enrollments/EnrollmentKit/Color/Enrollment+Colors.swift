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
    
    

import TooLegit
import ReactiveSwift
import Marshal
import SoPretty
import CoreData
import SoPersistent

extension Enrollment {
    static func parseColors(_ json: JSONObject) -> SignalProducer<[ContextID: UIColor], NSError> {
        return attemptProducer {
            let customColors: JSONObject = try json <| "custom_colors"
            var contexts: [ContextID: UIColor] = [:]
            
            for (context, hex) in customColors {
                guard let contextID = ContextID(canvasContext: context) else { continue }
                guard let hex = hex as? String, let color = UIColor.colorFromHexString(hex) else { continue }
                
                contexts[contextID] = color
            }
            
            return contexts
        }
    }
    
    static func getCustomColors(_ session: Session) -> SignalProducer<[ContextID: UIColor], NSError> {
        let path = "/api/v1/users/self/colors"
        
        return attemptProducer { try session.GET(path) }
            .flatMap(.merge, transform: session.JSONSignalProducer)
            .flatMap(.merge, transform: parseColors)
    }
    
    static func syncFavoriteColors(_ session: Session, inContext context: NSManagedObjectContext) -> SignalProducer<(), NSError> {
        let sync = context.syncContext
        return getCustomColors(session)
            .observe(on: ManagedObjectContextScheduler(context: sync))
            .flatMap(.merge) { colors in
                return attemptProducer {
                    for (contextID, color) in colors {
                        let enrollment = try Enrollment.findOne(contextID, inContext: sync)
                        enrollment?.color.value = color
                    }
                    
                    try sync.save()
                }
            }
    }
}

