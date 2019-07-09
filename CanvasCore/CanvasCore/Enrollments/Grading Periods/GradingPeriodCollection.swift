//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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
    public let selectedGradingPeriod: Property<GradingPeriodItem>

    public let collectionUpdates: Signal<[CollectionUpdate<GradingPeriodItem>], NoError>
    let updatesObserver: Signal<[CollectionUpdate<GradingPeriodItem>], NoError>.Observer

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
