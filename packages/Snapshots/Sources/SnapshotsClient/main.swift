//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Snapshots
import CoreData

@Detachable
final class TestModel: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var name: String
    @Raw @NSManaged var valueRaw: Int
    @NSManaged var value: Int

    @Relation @NSManaged var relation: TestRelationModel
}

@Detachable
final class TestRelationModel: NSManagedObject {
    @NSManaged var id: Int
}

struct TestSnapshot: CustomSnapshot {
    let attributes: TestModel.Snapshot

    let relation: TestRelationModel.Snapshot

    init(model: TestModel) {
        attributes = model.snapshot
        relation = model.relation.snapshot
    }
}

let model = TestModel()

// macro-generated snapshot
let macroGeneratedSnapshot = model.snapshot
let idFromMacroGeneratedSnapshot = macroGeneratedSnapshot.id

// custom snapshot
let customSnapshot = TestSnapshot(model: model)
// attribute's properties are exposed on the custom snapshot via dynamic member lookup
let idFromCustomSnapshot = customSnapshot.id

// relation
let relationFromCustomSnapshot = customSnapshot.relation
let idFromRelationSnapshot = customSnapshot.relation.id
