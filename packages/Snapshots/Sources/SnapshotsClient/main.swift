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
