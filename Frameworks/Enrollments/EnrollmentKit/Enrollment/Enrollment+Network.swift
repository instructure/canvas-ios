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
import ReactiveSwift
import SoPretty
import Marshal

extension Enrollment {
    public static func put(_ session:Session, color: UIColor, forContextID: ContextID) -> SignalProducer<(), NSError> {
        let path = "/api/v1/users/self/colors" / forContextID.canvasContextID
        let params: [String: Any] = ["hexcode": color.hex]
        return attemptProducer { try session.PUT(path, parameters: params) }
            .flatMap(.merge, transform: session.emptyResponseSignalProducer)
    }
}
