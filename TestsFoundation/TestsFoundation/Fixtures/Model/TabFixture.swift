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

import CoreData
import Foundation
@testable import Core

extension Tab {
    @discardableResult
    public static func make(
        from api: APITab = .make(),
        context: Context = ContextModel(.group, id: "1"),
        in db: NSManagedObjectContext = singleSharedTestDatabase.viewContext
    ) -> Tab {
        let model: Tab = db.insert()
        model.save(api, in: db, context: context)
        try! db.save()
        return model
    }
}
