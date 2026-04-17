# Snapshots

This package provides macros for converting Core Data objects to Sendable structures called Snapshots.
These Snapshots can be used for safely sharing data across threads, especially when using Structured Concurrency.

## Usage
Mark a Core Data object with the `@Detachable` macro to generate a corresponding Snapshot structure.
The Snapshot can be fine-tuned with the below macros:
- `@Raw`: Exclude a raw, Core Data compatible storage property from the Snapshot. The computed counterpart (without the "Raw" suffix) will be included instead. If a property name ends with "Raw" but is not marked with `@Raw`, `@Detachable` will emit a warning with a fix-it.
- `@Relation`: Exclude a Core Data relationship property from the Snapshot. Relationships must be handled manually via a `CustomSnapshot` (see below). If you forget to mark a relationship with `@Relation`, the `NSManagedObject` property will be included in the generated Snapshot. Since `NSManagedObject` is not `Sendable`, this will break the Snapshot's `Sendable` conformance — a compiler error in Swift 6 strict concurrency mode, or a warning in earlier language modes — serving as a built-in safety net for unannotated relationships.

## Example

```swift
@Detachable
final class Assignment: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var name: String
    @Raw @NSManaged var statusRaw: Int
    var status: Status {
        get { Status(rawValue: statusRaw) ?? .unknown }
        set { statusRaw = newValue.rawValue }
    }
    @Relation @NSManaged var course: Course
}
```

This generates:

```swift
extension Assignment: Detachable {
    public struct Snapshot: Snapshots.Snapshot {
        let id: String
        let name: String
        let status: Status

        public init(model: Assignment) {
            self.id = model.id
            self.name = model.name
            self.status = model.status
        }
    }
}
```

Access the snapshot via the auto-generated `.snapshot` property:

```swift
let snapshot = assignment.snapshot // Assignment.Snapshot
```

## Custom Snapshots

When you need to include relationships or add extra logic, conform to `CustomSnapshot`:

```swift
struct AssignmentSnapshot: CustomSnapshot {
    let attributes: Assignment.Snapshot
    let course: Course.Snapshot

    init(model: Assignment) {
        attributes = model.snapshot
        course = model.course.snapshot
    }
}
```

`CustomSnapshot` uses `@dynamicMemberLookup` so attribute properties are accessible directly:

```swift
let snapshot = AssignmentSnapshot(model: assignment)
snapshot.id    // forwarded from attributes
snapshot.name  // forwarded from attributes
snapshot.course // the relationship snapshot
```

## Collection Helpers

`Array` and `Set` of `Detachable` elements provide a `.snapshots()` convenience:

```swift
let assignments: [Assignment] = fetchResults()
let snapshots = assignments.snapshots() // [Assignment.Snapshot]
```
