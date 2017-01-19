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
import ReactiveSwift
import Nimble

extension SignalProducerProtocol {
    public func waitUntilFirst() -> Value? {
        var value: Value?
        
        waitUntil(timeout: 5) { done in
            self.start { event in
                switch event {
                case .value(let v):
                    value = v
                    done()
                case .completed:
                    break
                case .interrupted:
                    fail("interrupted")
                case .failed(let error):
                    fail("failed with error \(stringify(error))")
                }
            }
        }
        return value
    }
}
