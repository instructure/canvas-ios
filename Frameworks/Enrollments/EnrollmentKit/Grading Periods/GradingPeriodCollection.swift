//
//  GradingPeriodCollection.swift
//  Assignments
//
//  Created by Nathan Armstrong on 5/2/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import SoPersistent

public enum GradingPeriodItem: Equatable {
    case All
    case Some(GradingPeriod)

    public var title: String {
        switch self {
        case .All:
            return NSLocalizedString("All Grading Periods", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.EnrollmentKit")!, value: "", comment: "option to view results for all grading periods")
        case .Some(let gp):
            return gp.title
        }
    }

    public var gradingPeriodID: String? {
        var gradingPeriodID: String?
        if case .Some(let gp) = self {
            gradingPeriodID = gp.id
        }
        return gradingPeriodID
    }
}

public func ==(lhs: GradingPeriodItem, rhs: GradingPeriodItem) -> Bool {
    switch (lhs, rhs) {
    case (.All, .All): return true
    case (.Some(let l), .Some(let r)):
        return l.id == r.id
    default: return false
    }
}

import ReactiveCocoa


/**
 A collection of GradingPeriodItems where the first row in the first section is 'All'.
 */
public class GradingPeriodCollection: Collection {
    public let selectedGradingPeriod: MutableProperty<GradingPeriodItem?> = MutableProperty(nil)

    public var collectionUpdated: [CollectionUpdate<GradingPeriodItem>]->() = { _ in print("no one is watching!") }

    private let gradingPeriods: FetchedCollection<GradingPeriod>
    private let allSection = 0

    public init(course: Course, gradingPeriods: FetchedCollection<GradingPeriod>) {
        self.gradingPeriods = gradingPeriods

        gradingPeriods.collectionUpdated = { [weak self] updates in
            guard let me = self else { return }
            me.collectionUpdated(updates.map(me.offsetUpdate))
            
            self?.selectInitialGradingPeriod(course)
        }
        selectInitialGradingPeriod(course)
    }
    
    private func selectInitialGradingPeriod(course: Course) {
        if selectedGradingPeriod.value != nil { return }
        
        selectedGradingPeriod.value = gradingPeriods.filter({ $0.id == course.currentGradingPeriodID }).first.map(GradingPeriodItem.Some) ?? .All
    }

    public func numberOfSections() -> Int {
        return gradingPeriods.numberOfSections() + 1
    }

    public func numberOfItemsInSection(section: Int) -> Int {
        if section == allSection {
            return 1
        }

        return gradingPeriods.numberOfItemsInSection(section - 1)
    }

    public func titleForSection(section: Int) -> String? {
        if section == allSection {
            return nil
        }
        return gradingPeriods.titleForSection(section - 1)
    }

    public subscript(indexPath: NSIndexPath) -> GradingPeriodItem {
        if indexPath.section == allSection {
            return .All
        }

        let gradingPeriod = gradingPeriods[indexPath.incrementSection(by: -1)]
        return .Some(gradingPeriod)
    }

    func offsetUpdate(update: CollectionUpdate<GradingPeriod>) -> CollectionUpdate<GradingPeriodItem> {
        switch update {
        case .Reload:
            return .Reload
        case .Inserted(let indexPath, let m):
            return .Inserted(indexPath.incrementSection(), .Some(m))
        case .Updated(let indexPath, let m):
            return .Updated(indexPath.incrementSection(), .Some(m))
        case .Moved(let to, let from, let m):
            return .Moved(to.incrementSection(), from.incrementSection(), .Some(m))
        case .Deleted(let indexPath, let m):
            return .Deleted(indexPath.incrementSection(), .Some(m))
        case .SectionInserted, .SectionDeleted: fatalError("there should _always_ be 2 sections")
        }
    }
}

extension NSIndexPath {
    func incrementSection(by n: Int = 1) -> NSIndexPath {
        return NSIndexPath(forRow: row, inSection: section + n)
    }
}
