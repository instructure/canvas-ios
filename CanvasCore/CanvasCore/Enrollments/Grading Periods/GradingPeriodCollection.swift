//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    



public enum GradingPeriodItem: Equatable {
    case all
    case some(GradingPeriod)

    public var title: String {
        switch self {
        case .all:
            return NSLocalizedString("All Grading Periods", tableName: "Localizable", bundle: .core, value: "", comment: "option to view results for all grading periods")
        case .some(let gp):
            return gp.title
        }
    }

    public var gradingPeriodID: String? {
        var gradingPeriodID: String?
        if case .some(let gp) = self {
            gradingPeriodID = gp.id
        }
        return gradingPeriodID
    }
}

public func ==(lhs: GradingPeriodItem, rhs: GradingPeriodItem) -> Bool {
    switch (lhs, rhs) {
    case (.all, .all): return true
    case (.some(let l), .some(let r)):
        return l.id == r.id
    default: return false
    }
}

import ReactiveSwift
import Result

/**
 A collection of GradingPeriodItems where the first row in the first section is 'All'.
 */
open class GradingPeriodCollection: CanvasCore.Collection {
    open let selectedGradingPeriod: Property<GradingPeriodItem>

    open let collectionUpdates: Signal<[CollectionUpdate<GradingPeriodItem>], NoError>
    let updatesObserver: Observer<[CollectionUpdate<GradingPeriodItem>], NoError>

    fileprivate let gradingPeriods: FetchedCollection<GradingPeriod>
    fileprivate let allSection = 0
    fileprivate var disposable: Disposable?

    public init(course: Course, gradingPeriods: FetchedCollection<GradingPeriod>) {
        self.gradingPeriods = gradingPeriods
        (collectionUpdates, updatesObserver) = Signal.pipe()
        let currentGradingPeriod = { () -> GradingPeriodItem in
            return gradingPeriods.filter({ $0.id == course.currentGradingPeriodID }).first.map(GradingPeriodItem.some) ?? .all
        }

        let selectedGradingPeriod = gradingPeriods.collectionUpdates
            .map { _ in currentGradingPeriod() }
            .take(untilReplacement: _selectGradingPeriodProperty.signal.skipNil())
        self.selectedGradingPeriod = Property(initial: currentGradingPeriod(), then: selectedGradingPeriod)

        disposable = gradingPeriods.collectionUpdates
            .observe(on: UIScheduler())
            .observeValues { [weak self] updates in
                guard let me = self else { return }
                me.updatesObserver.send(value: updates.map(me.offsetUpdate))
        }.map(ScopedDisposable.init)
    }

    open func numberOfSections() -> Int {
        return gradingPeriods.numberOfSections() + 1
    }

    open func numberOfItemsInSection(_ section: Int) -> Int {
        if section == allSection {
            return 1
        }

        return gradingPeriods.numberOfItemsInSection(section - 1)
    }

    open func titleForSection(_ section: Int) -> String? {
        if section == allSection {
            return nil
        }
        return gradingPeriods.titleForSection(section - 1)
    }

    open subscript(indexPath: IndexPath) -> GradingPeriodItem {
        if indexPath.section == allSection {
            return .all
        }

        let gradingPeriod = gradingPeriods[indexPath.incrementSection(by: -1)]
        return .some(gradingPeriod)
    }

    func offsetUpdate(_ update: CollectionUpdate<GradingPeriod>) -> CollectionUpdate<GradingPeriodItem> {
        switch update {
        case .reload:
            return .reload
        case .inserted(let indexPath, let m, let animated):
            return .inserted(indexPath.incrementSection(), .some(m), animated: animated)
        case .updated(let indexPath, let m, let animated):
            return .updated(indexPath.incrementSection(), .some(m), animated: animated)
        case .moved(let from, let to, let m, let animated):
            return .moved(from.incrementSection(), to.incrementSection(), .some(m), animated: animated)
        case .deleted(let indexPath, let m, let animated):
            return .deleted(indexPath.incrementSection(), .some(m), animated: animated)
        case .sectionInserted, .sectionDeleted: fatalError("there should _always_ be 2 sections")
        }
    }

    fileprivate let _selectGradingPeriodProperty: MutableProperty<GradingPeriodItem?> = MutableProperty(nil)
    open func selectGradingPeriod(gradingPeriod: GradingPeriodItem) {
        _selectGradingPeriodProperty.value = gradingPeriod
    }
}

extension IndexPath {
    func incrementSection(by n: Int = 1) -> IndexPath {
        return IndexPath(row: row, section: section + n)
    }
}
