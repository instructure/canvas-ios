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
 section is expired or not in a given course. If the network request fails or the lookup fails because some data is missing
 this class will report that the section is active.
 */
class CourseSectionStatus {
    public var isUpdatePending: Bool { initialUpdatePending || enrollmentsRequest != nil }

    private var enrollmentsRequest: APITask?
    /** This dictionary contains the user's section IDs within courses referenced by their IDs. */
    private var sectionIDsByCourseIDs: [String: String] = [:]
    private var initialUpdatePending = true

    public func isSectionExpired(for card: DashboardCard, in courses: [Course]) -> Bool {
        guard let course = courses.first(where: { $0.id == card.id }) else { return false }
        return isSectionExpired(in: course)
    }

    public func isSectionExpired(in course: Course) -> Bool {
        guard let sectionId = sectionIDsByCourseIDs[course.id],
              let section = course.sections.first(where: { $0.id == sectionId }),
              let sectionEndDate = section.endAt
        else { return false }

        return Clock.now > sectionEndDate
    }

    public func refresh(completion: @escaping () -> Void) {
        guard enrollmentsRequest == nil else { return }

        let request = GetEnrollmentsRequest(context: .currentUser, types: [Role.student.rawValue], states: [.active])
        enrollmentsRequest = AppEnvironment.shared.api.makeRequest(request) { [weak self] enrollments, _, _ in
            DispatchQueue.main.async {
                self?.enrollmentsRequest = nil
                self?.extractSectionInfo(from: enrollments ?? [])
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
            dictionary[courseId] = sectionId
        }
    }
}
