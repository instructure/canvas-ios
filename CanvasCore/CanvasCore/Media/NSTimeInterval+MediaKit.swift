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



private let numberFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.minimumIntegerDigits = 2
    return numberFormatter
    }()


extension TimeInterval {
    func formatted(_ includeSubSeconds: Bool = false) -> String {
        let effectiveTime = self < 0 ? -self : self
        
        let seconds = numberFormatter.string(from: NSNumber(value: Int(effectiveTime) % 60)) ?? "!!"
        let justTheMinutes = Int(effectiveTime) / 60
        // if `justTheMinutes` is more than 99 just use the whole thing.
        let minutes = numberFormatter.string(from: NSNumber(value: justTheMinutes)) ?? "\(justTheMinutes)"

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
