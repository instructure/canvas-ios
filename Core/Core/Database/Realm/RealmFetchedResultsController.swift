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

    typealias RealmFRCSections =  [AnyHashable: [RealmSwift.Object]]

    private weak var persistence: RealmPersistence?
    private var objs: [ResultType]?
    private let predicate: NSPredicate?
    private let sortDescriptors: [SortDescriptor]?
    private let sectionNameKeyPath: String?
    private var backingSections: RealmFRCSections?
    private var sectionInfo: [FetchedSection]?

    init(persistence: RealmPersistence = RealmPersistence(), predicate: NSPredicate? = nil, sortDescriptors: [SortDescriptor]? = nil, sectionNameKeyPath: String? = nil) {
        self.persistence = persistence
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        self.sectionNameKeyPath = sectionNameKeyPath
    }

    public override var sections: [FetchedSection]? {
        return sectionInfo
    }

    public override var fetchedObjects: [ResultType]? {
        return objs
    }

    public override func performFetch() throws {
        objs = persistence?.fetch(predicate: predicate, sortDescriptors: sortDescriptors) as [ResultType]?

        sortIntoSections()
        sectionInfo = computeSectionInfos()
    }

    public override func object(at indexPath: IndexPath) -> ResultType? {
        var values: [Object]?
        if let backingSections = backingSections {
            let sectionCount = backingSections.keys.count
            if indexPath.section >= sectionCount {
                return nil
            }
            let key = Array(backingSections.keys)[indexPath.section]
            values = backingSections[key]
        } else {
            values = objs as? [Object]
        }

        if indexPath.row >= values?.count ?? 0 { return nil }

        return values?[indexPath.row] as? ResultType
    }

    private func sortIntoSections() {
        guard let objs = objs, let sectionNameKeyPath = sectionNameKeyPath else {
            return
        }
        backingSections = RealmFRCSections()
        sectionInfo = []
        objs.lazy.forEach { (obj) in
            if let o = obj as? Object {
                if let key = o.value(forKey: sectionNameKeyPath) as? AnyHashable {
                    setValueInSection(key: key, value: o)
                } else {
                    //  collect nil keys into an empty string group
                    setValueInSection(key: "", value: o)
                }
            }
        }
    }

    private func setValueInSection(key: AnyHashable, value: RealmSwift.Object) {
        if var arr = backingSections?[key] {
            arr.append(value)
            backingSections?[key] = arr
        } else if backingSections?[key] == nil {
            backingSections?[key] = [value]
        }
    }

    private func computeSectionInfos() -> [FetchedSection] {
        guard let backingSections = backingSections else { return [] }
        return backingSections.keys.map { FetchedSection(name: $0.description, numberOfObjects: backingSections[$0]?.count ?? 0) }
    }
}
