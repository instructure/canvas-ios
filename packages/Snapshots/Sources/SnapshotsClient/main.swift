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
