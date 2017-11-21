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
    
    

import Foundation

// ---------------------------------------------
// MARK: - Domainify
// ---------------------------------------------
extension String {
    mutating func domainify() {
        stripURLScheme()
        removeSlashes()
        removeWhitespace()
        addInstructureDotComIfNeeded()
    }
    
    mutating func stripURLScheme() {
        let schemes = ["http://", "https://"]
        for scheme in schemes {
            if self.hasPrefix(scheme) {
                self = (self as NSString).substring(from: scheme.characters.count)
            }
        }
    }
    
    mutating func removeSlashes() {
        self = self.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    mutating func removeWhitespace() {
        self = self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    mutating func addInstructureDotComIfNeeded() {
        if self.range(of: ":") == nil && self.range(of: ".") == nil {
            self += ".instructure.com"
        }
    }

    mutating func addURLScheme() {
        self = "https://\(self)"
    }
}
