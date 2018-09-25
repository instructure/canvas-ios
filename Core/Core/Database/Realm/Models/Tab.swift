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
import RealmSwift

public class Tab: Object {
    @objc public dynamic var id: String = ""
    @objc public dynamic var htmlUrl: String?
    @objc public dynamic var fullUrl: String = ""
    @objc public dynamic var label: String = ""
    @objc public dynamic var position: Int = 0
    @objc public dynamic var contextID: String = ""

    override public class func primaryKey() -> String? {
        return #keyPath(Tab.fullUrl)
    }
}
