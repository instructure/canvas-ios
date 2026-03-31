import CoreData

public protocol Snapshot where Model: NSManagedObject {
    associatedtype Model

    init(model: Model)
}

public protocol Detachable {
    associatedtype Snapshot: Snapshots.Snapshot
}

@attached(extension, names: named(Snapshot), conformances: Detachable)
public macro Detachable() = #externalMacro(module: "SnapshotsMacros", type: "DetachableMacro")

@attached(peer)
public macro Relation() = #externalMacro(module: "SnapshotsMacros", type: "RelationMacro")

@attached(peer)
public macro Raw() = #externalMacro(module: "SnapshotsMacros", type: "RawMacro")
