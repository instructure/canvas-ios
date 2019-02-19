//
// Copyright (C) 2018-present Instructure, Inc.
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
import CoreData
@testable import Core

extension Fixture where Self: NSManagedObject {
    @discardableResult
    public static func make(_ template: Template = [:], client: PersistenceClient = singleSharedTestDatabase.mainClient) -> Self {
        var t = self.template
        for (key, _) in template {
            t[key] = template[key]
        }
        let fixture: Self = client.insert()
        for (key, value) in t {
            fixture.setValue(value, forKey: key)
        }
        try! client.save()
        return fixture
    }
}

extension PersistenceClient {
    @discardableResult
    public func make<T>(_ template: Template = [:]) -> T where T: Fixture, T: NSManagedObject {
        let fixture: T = T.make(template)
        return fixture
    }
}
