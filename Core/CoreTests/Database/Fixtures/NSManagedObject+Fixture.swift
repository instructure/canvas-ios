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
import CoreData
import RealmSwift
@testable import Core

extension Fixture where Self: NSManagedObject {
    static func make(_ template: Template = [:], in client: Persistence) -> Self {
        var t = self.template
        for (key, _) in template {
            t[key] = template[key]
        }
        let fixture: Self = client.insert()
        for (key, value) in t {
            fixture.setValue(value, forKey: key)
        }
        return fixture
    }
}

extension Persistence {
    func make<T>(_ template: Template = [:]) -> T where T: Fixture, T: NSManagedObject {
        let fixture: T = T.make(template, in: self)
        try! addOrUpdate(fixture)
        return fixture
    }
}
