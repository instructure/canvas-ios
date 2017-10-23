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
