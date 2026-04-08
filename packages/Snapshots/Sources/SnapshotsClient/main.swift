import Snapshots
import CoreData

@Detachable
final class TestModel: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var name: String

    @Raw
    @NSManaged var valueRaw: Int
    @NSManaged var value: Int

}

let model = TestModel()

let snapshot = model.snapshot

let models: Set = [TestModel(), TestModel()]

let snapshots = models.snapshots()

struct TestSnapshot: CustomSnapshot {
    let attributes: TestModel.Snapshot

    public init(model: TestModel) {
        self.attributes = model.snapshot
    }
}

let s = TestSnapshot(model: model)
let x = s.name
