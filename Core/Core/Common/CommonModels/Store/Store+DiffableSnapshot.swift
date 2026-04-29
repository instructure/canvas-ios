//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import UIKit

public extension Store {

    /// Objects that had a Core Data update event since the last notification cycle.
    /// Useful for identifying which items need cell reconfiguration in a diffable data source.
    var updatedObjects: [U.Model] {
        changes.compactMap { change -> U.Model? in
            guard case .updateRow(let indexPath) = change else { return nil }
            return self[indexPath]
        }
    }

    /// Builds a single-section diffable snapshot from the store's current objects.
    /// Items with Core Data update events are automatically marked for reconfiguration.
    func makeSnapshot<SectionID: Hashable, ItemID: Hashable>(
        sectionID: SectionID,
        itemID: (U.Model) -> ItemID
    ) -> NSDiffableDataSourceSnapshot<SectionID, ItemID> {
        var snapshot = NSDiffableDataSourceSnapshot<SectionID, ItemID>()
        snapshot.appendSections([sectionID])
        snapshot.appendItems(all.map(itemID), toSection: sectionID)

        let updatedIDs = updatedObjects.map(itemID)
        if updatedIDs.isNotEmpty {
            snapshot.reconfigureItems(updatedIDs)
        }

        return snapshot
    }

    /// Builds a multi-section diffable snapshot where each store object is a section.
    /// Items per section are derived by the `items` closure.
    /// Sections with Core Data update events have all their items marked for reconfiguration.
    func makeSnapshot<SectionID: Hashable, ItemID: Hashable>(
        sectionID: (U.Model) -> SectionID,
        items: (U.Model) -> [ItemID]
    ) -> NSDiffableDataSourceSnapshot<SectionID, ItemID> {
        var snapshot = NSDiffableDataSourceSnapshot<SectionID, ItemID>()

        for object in all {
            let section = sectionID(object)
            snapshot.appendSections([section])
            let sectionItems = items(object)
            if sectionItems.isNotEmpty {
                snapshot.appendItems(sectionItems, toSection: section)
            }
        }

        let updatedSectionIDs = Set(updatedObjects.map(sectionID))
        for section in updatedSectionIDs {
            guard snapshot.sectionIdentifiers.contains(section) else { continue }
            let sectionItems = snapshot.itemIdentifiers(inSection: section)
            if sectionItems.isNotEmpty {
                snapshot.reconfigureItems(sectionItems)
            }
        }

        return snapshot
    }

    /// Builds a multi-section diffable snapshot using Core Data sections (from sectionNameKeyPath).
    /// Each Core Data section becomes a snapshot section, with items derived by the `itemID` closure.
    /// Objects with Core Data update events are automatically marked for reconfiguration.
    func makeSnapshot<SectionID: Hashable, ItemID: Hashable>(
        coreSectionID: (String) -> SectionID,
        itemID: (U.Model) -> ItemID
    ) -> NSDiffableDataSourceSnapshot<SectionID, ItemID> {
        var snapshot = NSDiffableDataSourceSnapshot<SectionID, ItemID>()

        for sectionIndex in 0..<numberOfSections {
            guard let section = sections?[sectionIndex] else { continue }
            let sectionID = coreSectionID(section.name)
            snapshot.appendSections([sectionID])

            let items = (0..<section.numberOfObjects).compactMap { row -> ItemID? in
                guard let object = self[IndexPath(row: row, section: sectionIndex)] else { return nil }
                return itemID(object)
            }
            snapshot.appendItems(items, toSection: sectionID)
        }

        let updatedIDs = updatedObjects.map(itemID)
        if updatedIDs.isNotEmpty {
            snapshot.reconfigureItems(updatedIDs)
        }

        return snapshot
    }
}

public extension UITableViewDiffableDataSource {
    /// Applies a snapshot with automatic animation logic.
    /// Only animates if the previous snapshot was not empty, preventing initial load animation.
    func applySnapshot(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>) {
        let shouldAnimate = self.snapshot().itemIdentifiers.isNotEmpty
        apply(snapshot, animatingDifferences: shouldAnimate)
    }

    /// Applies a snapshot with automatic animation logic and completion handler.
    /// Only animates if the previous snapshot was not empty, preventing initial load animation.
    func applySnapshot(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>, completion: @escaping () -> Void) {
        let shouldAnimate = self.snapshot().itemIdentifiers.isNotEmpty
        apply(snapshot, animatingDifferences: shouldAnimate, completion: completion)
    }
}
