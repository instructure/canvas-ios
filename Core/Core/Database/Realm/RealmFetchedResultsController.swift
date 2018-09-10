//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import RealmSwift

public class RealmFetchedResultsController<ResultType>: FetchedResultsController<ResultType> {

    typealias RealmSections =  [AnyHashable: [ResultType]]

    private weak var persistence: RealmPersistence?
    private let predicate: NSPredicate?
    private let sortDescriptors: [SortDescriptor]?
    private let sectionNameKeyPath: String?
    private var backingSections: RealmSections?
    private var sectionInfo: [FetchedSection]?
    private var sortedSectionKeys: [AnyHashable]?
    private var valuesSortedByKey: [[ResultType]]?
    private var observationToken: NotificationToken?

    init(persistence: RealmPersistence = RealmPersistence(), predicate: NSPredicate? = nil, sortDescriptors: [SortDescriptor]? = nil, sectionNameKeyPath: String? = nil) {
        self.persistence = persistence
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        self.sectionNameKeyPath = sectionNameKeyPath
    }

    deinit {
        observationToken?.invalidate()
    }

    public override var sections: [FetchedSection]? {
        return sectionInfo
    }

    public override var fetchedObjects: [ResultType]? {
        return valuesSortedByKey?.first
    }

    public override func performFetch() throws {
        guard let entityToFetch = ResultType.self as? Object.Type else {
            fatalError("\(#function), \(PersistenceError.wrongEntityType)")
        }

        let realmObjs = persistence?.fetchRealmObjects(type: entityToFetch, predicate: predicate, sortDescriptors: sortDescriptors)

        observeChanges(realmObjs)
        try sortIntoSections(realmObjs)
        sectionInfo = computeSectionInfos()
    }

    public override func object(at indexPath: IndexPath) -> ResultType? {
        var values: [ResultType]?
        if let valuesSortedByKey = valuesSortedByKey {
            if indexPath.section >= valuesSortedByKey.count {
                return nil
            }
            values = valuesSortedByKey[indexPath.section]
        }

        if indexPath.row >= values?.count ?? 0 { return nil }

        return values?[indexPath.row]
    }

    private func notifyOfUpdates() {
        do {
            try performFetch()
        } catch {
            assertionFailure("Error occurred refreshing data after update \(error.localizedDescription)")
        }
        self.delegate?.controllerDidChangeContent(self)
    }

    private func observeChanges(_ realmObjects: Results<Object>?) {
        observationToken?.invalidate()
        observationToken = realmObjects?.observe({ [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial: break
            case .update:
                self?.notifyOfUpdates()
            case .error(let error):
                assertionFailure("\(#function) \(error.localizedDescription)")
            }
        })
    }

    private func sortIntoSections(_ realmObjs: Results<Object>?) throws {
        guard let objs = realmObjs else { return }
        let sectionName = sectionNameKeyPath ?? ""
        backingSections = RealmSections()
        try objs.lazy.forEach { (obj) in
            if let o = obj as? ResultType {
                var key: AnyHashable = ""
                if obj.responds(to: Selector(sectionName)), let hashableKey = obj.value(forKey: sectionName) as? AnyHashable {
                    key = hashableKey
                } else if let name = sectionNameKeyPath, !name.isEmpty {
                    //  only throw this assertion if a sectionNameKeyPath was passed in
                    throw PersistenceError.invalidSectionNameKeyPath
                }
                setValueInSection(key: key, value: o)
            }
        }

        valuesSortedByKey = backingSections?.lazy.sorted { frcSorter($0.key.description, $1.key.description) }.map { $0.value }
    }

    private func setValueInSection(key: AnyHashable, value: ResultType) {
        if var arr = backingSections?[key] {
            arr.append(value)
            backingSections?[key] = arr
        } else if backingSections?[key] == nil {
            backingSections?[key] = [value]
        }
    }

    private func computeSectionInfos() -> [FetchedSection] {
        guard let backingSections = backingSections else { return [] }
        let sections = backingSections.keys.map { FetchedSection(name: $0.description, numberOfObjects: backingSections[$0]?.count ?? 0) }
        return sections.sorted { frcSorter($0.name, $1.name) }
    }

    private func frcSorter(_ a: String, _ b: String) -> Bool {
        //  sorting in this manner puts the empty string sections at the bottom instead of the top
        if a.isEmpty { return false }
        if b.isEmpty { return true }
        return a < b
    }
}
