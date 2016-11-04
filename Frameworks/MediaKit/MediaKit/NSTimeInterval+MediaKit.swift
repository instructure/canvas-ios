
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



private let numberFormatter: NSNumberFormatter = {
    let numberFormatter = NSNumberFormatter()
    numberFormatter.minimumIntegerDigits = 2
    return numberFormatter
    }()


extension NSTimeInterval {
    func formatted(includeSubSeconds: Bool = false) -> String {
        let effectiveTime = self < 0 ? -self : self
        
        let seconds = numberFormatter.stringFromNumber(Int(effectiveTime) % 60) ?? "!!"
        let justTheMinutes = Int(effectiveTime) / 60
        // if `justTheMinutes` is more than 99 just use the whole thing.
        let minutes = numberFormatter.stringFromNumber(justTheMinutes) ?? "\(justTheMinutes)"

        let subSeconds: String
        if includeSubSeconds {
            let tenthOfASecond = Int((effectiveTime - trunc(effectiveTime)) * 10)
            subSeconds = ".\(tenthOfASecond)"
        } else {
            subSeconds = ""
        }
        
        return "\(minutes):\(seconds)\(subSeconds)"
    }
}