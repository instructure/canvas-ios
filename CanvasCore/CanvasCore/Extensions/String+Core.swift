//
// Copyright (C) 2018-present Instructure, Inc.
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

extension String {
    func populatePathWithParams(_ params: PageViewEventDictionary?) -> String? {
        guard let url = URL(string: self), params?.count ?? 0 > 0 else {
            return nil
        }
        var components = url.pathComponents
        let componentsCopy = components

        for (index, c) in componentsCopy.enumerated() {
            if c.hasPrefix(":") || c.hasPrefix("*"), let replacementVal = params?[String(c.dropFirst())] {
                components[index] = replacementVal.description
            }
        }
        return NSString.path(withComponents: components) as String
    }
    
    func pruneApiVersionFromPath() -> String {
        let regex = "\\/{0,1}api\\/v\\d+"
        guard let range = self.range(of: regex, options: .regularExpression, range: nil, locale: nil) else {
            return self
        }
        let prefix = String(self[self.startIndex..<range.lowerBound]) ?? ""
        let suffix = String(self[range.upperBound..<self.endIndex]) ?? ""
        return prefix + suffix
    }
}
