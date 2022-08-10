//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

/**
 This class fetches the current user's enrollments and based on the extracted section info can return if the current user's
 sections are expired or not in a given course.
 */
class CourseSectionStatus {
    public var isUpdatePending: Bool { initialUpdatePending || enrollmentsRequest != nil }

    private var enrollmentsRequest: APITask?
    /** This dictionary contains the user's section IDs which have an active enrollment, grouped by course IDs. */
    private var sectionIDsByCourseIDs: [String: [String]] = [:]
    /** Contains course ids for which we've found an active enrollment. */
    private var activeEnrollmentCourseIDs = Set<String>()
    private var initialUpdatePending = true

    public func isAllSectionsExpired(for card: DashboardCard, in courses: [Course]) -> Bool {
        guard let course = courses.first(where: { $0.id == card.id }) else { return false }
        return isAllSectionsExpired(in: course)
    }

    /**
     - returns: False if there's a section whose end date is nil or not nil but doesn't elapsed. True if all sections the user is assigned to in this course having a non-nil end date are expired.
     */
    public func isAllSectionsExpired(in course: Course) -> Bool {
        guard let sectionIds = sectionIDsByCourseIDs[course.id] else { return false }

        let sections = course.sections.filter({ sectionIds.contains($0.id) })
        let sectionEndDates = sections.map { $0.endAt }

        // Check if there's an active section
        if sections.count == 0 || sectionEndDates.contains(where: { $0 == nil || ($0 != nil && Clock.now < $0!) }) {
            return false
        }

        let validsectionEndDates = sectionEndDates.compactMap { $0 }
        return validsectionEndDates.allSatisfy { Clock.now > $0 }
    }

    /**
     - returns: True if there are no enrollments for the given course with `active`  `enrollment_state`.
     */
    public func isNoActiveEnrollments(in course: Course) -> Bool {
        !activeEnrollmentCourseIDs.contains(course.id)
    }

    public func refresh(completion: @escaping () -> Void) {
        guard enrollmentsRequest == nil else { return }

        let request = GetEnrollmentsRequest(context: .currentUser, states: [.active])
        enrollmentsRequest = AppEnvironment.shared.api.makeRequest(request) { [weak self] enrollments, _, _ in
            DispatchQueue.main.async {
                self?.enrollmentsRequest = nil
                self?.extractSectionInfo(from: enrollments ?? [])
                self?.saveActiveEnrollmentIDs(from: enrollments ?? [])
                self?.initialUpdatePending = false
                completion()
            }
        }
    }

    private func extractSectionInfo(from enrollments: [APIEnrollment]) {
        sectionIDsByCourseIDs = enrollments.reduce(into: [:]) { dictionary, enrollment in
            guard let courseId = enrollment.course_id?.value, let sectionId = enrollment.course_section_id?.value else {
                return
            }

            var sectionIDs: [String] = dictionary[courseId] ?? []
            sectionIDs.append(sectionId)
            dictionary[courseId] = sectionIDs
        }
    }

    private func saveActiveEnrollmentIDs(from enrollments: [APIEnrollment]) {
        activeEnrollmentCourseIDs.removeAll()
        let courseIDs = enrollments.compactMap { $0.course_id?.value }
        activeEnrollmentCourseIDs.formUnion(courseIDs)
    }
}
