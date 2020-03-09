//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import Foundation
import CoreData

private let UnknownGradingPeriodID = "unknown"

public class Grades {
    let courseID: String
    let userID: String?
    var env: AppEnvironment {
        return .shared
    }
    var gradingPeriodID: String? = UnknownGradingPeriodID {
        didSet {
            performUIUpdate { self.reload() }
        }
    }
    var callback: (() -> Void)?
    var error: Error?
    private var pending = 0 {
        didSet {
            if oldValue <= 0 && pending > 0 {
                notify()
            } else if oldValue > 0 && pending <= 0 {
                notify()
            }
        }
    }
    var isPending: Bool { pending > 0 }

    var assignments: Store<LocalUseCase<Assignment>>!
    var gradingPeriods: Store<LocalUseCase<GradingPeriod>>!
    var enrollments: Store<LocalUseCase<Enrollment>>!
    private lazy var courses: Store<LocalUseCase<Course>> = env.subscribe(scope: .where(#keyPath(Course.id), equals: courseID)) { [weak self] in
        self?.notify()
    }
    var course: Course? { courses.first }
    var enrollment: Enrollment? { enrollments.first }

    var gradingPeriod: GradingPeriod? {
        gradingPeriods.first { $0.id == gradingPeriodID }
    }

    init(courseID: String, userID: String? = nil) {
        self.courseID = courseID
        self.userID = userID ?? AppEnvironment.shared.currentSession?.userID
        assignments = env.subscribe(scope: .grades(courseID: courseID)) { [weak self] in
            self?.notify()
        }
        enrollments = env.subscribe(scope: .activeStudentEnrollment(courseID: courseID, userID: userID)) { [weak self] in
            self?.notify()
        }
        gradingPeriods = env.subscribe(scope: .gradingPeriods(courseID: courseID)) { [weak self] in
            self?.notify()
        }
    }

    func notify() {
        performUIUpdate {
            self.callback?()
        }
    }

    func subscribe(callback: @escaping () -> Void) {
        self.callback = callback
    }

    func refresh() {
        pending = 0
        if gradingPeriodID == UnknownGradingPeriodID {
            getCurrentGrades()
        } else {
            getGrades(gradingPeriodID: gradingPeriodID)
        }
        getGradingPeriods()
    }

    func getCurrentGrades() {
        self.pending += 1
        let request = GetCourseRequest(courseID: courseID)
        env.api.makeRequest(request) { [weak self] response, _, error in
            guard let self = self else {
                return
            }
            self.env.database.performBackgroundTask { context in
                defer { self.pending -= 1 }
                guard let response = response else {
                    self.error = error ?? NSError.internalError()
                    return
                }
                guard let enrollment = response.enrollments?.first(where: { $0.user_id == self.userID && $0.type.lowercased().contains("student") && $0.enrollment_state == .active }) else {
                    self.error = NSError.instructureError(NSLocalizedString("Enrollment not found.", bundle: .core, comment: ""))
                    return
                }
                do {
                    Course.save(response, in: context)
                    try context.save()
                    self.gradingPeriodID = enrollment.current_grading_period_id
                } catch {
                    self.error = error
                }
            }
        }
    }

    func getGrades(gradingPeriodID: String?) {
        getEnrollments(gradingPeriodID: gradingPeriodID)
        let request = GetAssignmentGroupsRequest(courseID: self.courseID, gradingPeriodID: gradingPeriodID, include: [.assignments])
        getAssignmentGroups(gradingPeriodID: gradingPeriodID, request: request, isFirstPage: true)
    }

    func getGradingPeriods() {
        self.pending += 1
        let request = GetGradingPeriodsRequest(courseID: courseID)
        env.api.exhaust(request) { [weak self] response, _, error in
            guard let self = self else { return }
            self.env.database.performBackgroundTask { context in
                defer { self.pending -= 1 }
                guard let response = response else {
                    self.error = error ?? NSError.internalError()
                    return
                }
                for apiGradingPeriod in response {
                    GradingPeriod.save(apiGradingPeriod, courseID: self.courseID, in: context)
                }
                do {
                    try context.save()
                } catch {
                    self.error = error
                }
            }
        }
    }

    private func getEnrollments(gradingPeriodID: String?) {
        pending += 1
        let request = GetEnrollmentsRequest(context: ContextModel(.course, id: courseID), userID: userID, gradingPeriodID: gradingPeriodID)
        env.api.exhaust(request) { [weak self] response, _, error in
            guard let self = self else { return }
            self.env.database.performBackgroundTask { context in
                defer { self.pending -= 1 }
                guard let response = response else {
                    self.error = error ?? NSError.internalError()
                    return
                }
                for item in response {
                    // Need to match this enrollment with an enrollment from the course endpoint.
                    // Course endpoint enrollments don't include the enrollment ID so match against everything else.
                    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                        NSPredicate(format: "%K == %@", #keyPath(Enrollment.stateRaw), item.enrollment_state.rawValue),
                        NSPredicate(format: "%K == %@", #keyPath(Enrollment.userID), item.user_id),
                        NSPredicate(format: "%K == %@", #keyPath(Enrollment.roleID), item.role_id),
                        NSPredicate(format: "%K == %@", #keyPath(Enrollment.role), item.role),
                        NSPredicate(format: "%K == %@", #keyPath(Enrollment.course.id), self.courseID),
                    ])
                    let enrollment: Enrollment = context.fetch(predicate).first ?? context.insert()
                    let course = (context.all(where: #keyPath(Course.id), equals: self.courseID) as [Course]).first
                    enrollment.update(fromApiModel: item, course: course, gradingPeriodID: gradingPeriodID, in: context)
                }
                do {
                    try context.save()
                } catch {
                    self.error = error
                }
            }
        }
    }

    private func getAssignmentGroups<R>(gradingPeriodID: String?, request: R, isFirstPage: Bool, assignmentIDs: [String] = []) where R: APIRequestable, R.Response == [APIAssignmentGroup] {
        pending += 1
        env.api.makeRequest(request) { [weak self] response, urlResponse, error in
            guard let self = self else { return }
            self.env.database.performBackgroundTask { context in
                defer { self.pending -= 1 }
                guard let response = response else {
                    self.error = error ?? NSError.internalError()
                    return
                }
                if isFirstPage {
                    let assignmentGroups: [AssignmentGroup] = context.all(where: #keyPath(AssignmentGroup.courseID), equals: self.courseID)
                    context.delete(assignmentGroups)
                }
                for apiAssignmentGroup in response {
                    AssignmentGroup.save(apiAssignmentGroup, courseID: self.courseID, in: context)
                }
                do {
                    try context.save()
                    let assignmentIDs = assignmentIDs + response.flatMap { $0.assignments?.map { $0.id.value } ?? [] }
                    if let next = urlResponse.flatMap({ request.getNext(from: $0) }) {
                        self.getAssignmentGroups(gradingPeriodID: gradingPeriodID, request: next, isFirstPage: false, assignmentIDs: assignmentIDs)
                    } else {
                        self.getAssignments(assignmentIDs, gradingPeriodID: gradingPeriodID, isFirstPage: true)
                    }
                } catch {
                    self.error = error
                }
            }
        }
    }

    private func getAssignments(_ assignmentIDs: [String], gradingPeriodID: String?, isFirstPage: Bool) {
        pending += 1
        let request = GetAssignmentsRequest(
            courseID: self.courseID,
            orderBy: .position,
            include: [.observed_users, .submission],
            perPage: 99 // TODO: paginate after LA-279
        )
        env.api.makeRequest(request) { [weak self] response, _, error in
            guard let self = self else { return }
            self.env.database.performBackgroundTask { context in
                defer { self.pending -= 1 }
                guard let response = response else {
                    self.error = error ?? NSError.internalError()
                    return
                }
                let gradingPeriod: GradingPeriod = context.first(where: #keyPath(GradingPeriod.id), equals: gradingPeriodID) ?? context.insert()
                gradingPeriod.id = gradingPeriodID
                gradingPeriod.courseID = self.courseID
                if isFirstPage {
                    gradingPeriod.assignments = []
                }
                for apiAssignment in response where assignmentIDs.contains(apiAssignment.id.value) {
                    let assignment = Assignment.save(apiAssignment, in: context, updateSubmission: true)
                    assignment.gradingPeriod = gradingPeriod
                }
                do {
                    try context.save()
                } catch {
                    self.error = error
                }
            }
        }
    }

    private func reload() {
        assignments = env.subscribe(scope: .grades(courseID: courseID, gradingPeriodID: gradingPeriodID)) { [weak self] in
            self?.notify()
        }
        getGrades(gradingPeriodID: gradingPeriodID)
    }
}

extension Scope {
    static func grades(courseID: String, gradingPeriodID: String? = nil) -> Scope {
        let course = NSPredicate(key: #keyPath(Assignment.courseID), equals: courseID)
        let gradingPeriod = NSPredicate(key: #keyPath(Assignment.gradingPeriod.id), equals: gradingPeriodID)
        return Scope(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [course, gradingPeriod]),
            order: [
                NSSortDescriptor(key: #keyPath(Assignment.assignmentGroup.position), ascending: true),
                NSSortDescriptor(key: #keyPath(Assignment.position), ascending: true),
            ],
            sectionNameKeyPath: #keyPath(Assignment.assignmentGroup.position)
        )
    }

    static func activeStudentEnrollment(courseID: String, userID: String?) -> Scope {
        var predicates = [
            NSPredicate(format: "%K == %@", #keyPath(Enrollment.course.id), courseID),
            NSPredicate(format: "%K CONTAINS[c] %@", #keyPath(Enrollment.type), "student"),
            NSPredicate(format: "%K == %@", #keyPath(Enrollment.stateRaw), EnrollmentState.active.rawValue),
        ]
        if let userID = userID {
            predicates.append(NSPredicate(format: "%K == %@", #keyPath(Enrollment.userID), userID))
        }
        return Scope(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates),
            order: [NSSortDescriptor(key: #keyPath(Enrollment.id), ascending: true)]
        )
    }

    static func gradingPeriods(courseID: String) -> Scope {
        return .where(#keyPath(GradingPeriod.courseID), equals: courseID, orderBy: #keyPath(GradingPeriod.title), naturally: true)
    }
}
