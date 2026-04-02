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
