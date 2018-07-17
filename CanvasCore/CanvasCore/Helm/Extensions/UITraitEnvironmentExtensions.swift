//
// Copyright (C) 2017-present Instructure, Inc.
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

import UIKit

extension UITraitEnvironment {
    public func sizeClassInfoForJavascriptConsumption() -> [String: String] {
        let horizontalKey = "horizontal"
        let verticalKey = "vertical"
        var data = [String:String]()
        let horizontalSizeClass = self.traitCollection.horizontalSizeClass
        let verticalSizeClass  = self.traitCollection.verticalSizeClass
        data[horizontalKey] = horizontalSizeClass.description
        data[verticalKey] = verticalSizeClass.description
        return data
    }
}
