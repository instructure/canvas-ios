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

import Combine
import Core
import Foundation
import Observation

@Observable
final class CourseInvitationsWidgetViewModel: DashboardWidgetViewModel {
    typealias ViewType = CourseInvitationsWidgetView

    let config: DashboardWidgetConfig
    var id: DashboardWidgetIdentifier { config.id }
    let isFullWidth = true
    let isEditable = false

    private(set) var invitations: [CourseInvitationCardViewModel] = [] {
        didSet { updateTitles() }
    }
    private(set) var state: InstUI.ScreenState = .loading
    private(set) var widgetTitle: String = ""
    private(set) var widgetAccessibilityTitle: String = ""

    var layoutIdentifier: AnyHashable {
        struct Identifier: Hashable {
            let state: InstUI.ScreenState
            let invitationCount: Int
        }
        return AnyHashable(Identifier(state: state, invitationCount: invitations.count))
    }

    private let interactor: CoursesInteractor
    private let snackBarViewModel: SnackBarViewModel
    private var subscriptions = Set<AnyCancellable>()

    init(
        config: DashboardWidgetConfig,
        interactor: CoursesInteractor,
        snackBarViewModel: SnackBarViewModel
    ) {
        self.config = config
        self.interactor = interactor
        self.snackBarViewModel = snackBarViewModel
        updateTitles()
    }

    func makeView() -> CourseInvitationsWidgetView {
        CourseInvitationsWidgetView(viewModel: self)
    }

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        interactor.getCourses(ignoreCache: ignoreCache)
            .map { [weak self, interactor, snackBarViewModel] result in
                guard let self else { return [] }
                return result.invitedCourses.compactMap { course in
                    guard let invitedEnrollment = course.enrollments?.first(where: { $0.state == .invited && $0.id != nil }),
                          let enrollmentID = invitedEnrollment.id else {
                        return nil
                    }
                    let sectionID = invitedEnrollment.courseSectionID
                    let section = course.sections.first { $0.id == sectionID }

                    return CourseInvitationCardViewModel(
                        id: enrollmentID,
                        courseId: course.id,
                        courseName: course.name ?? "",
                        sectionName: section?.name,
                        interactor: interactor,
                        snackBarViewModel: snackBarViewModel,
                        onDismiss: { [weak self] enrollmentId in
                            self?.removeInvitation(id: enrollmentId)
                        }
                    )
                }
            }
            .receive(on: DispatchQueue.main)
            .map { [weak self] (invitations: [CourseInvitationCardViewModel]) in
                self?.invitations = invitations
                self?.state = invitations.isEmpty ? .empty : .data
                return ()
            }
            .catch { [weak self] _ in
                self?.state = .error
                return Just(())
            }
            .eraseToAnyPublisher()
    }

    private func removeInvitation(id: String) {
        invitations.removeAll { $0.id == id }
        if invitations.isEmpty {
            state = .empty
        }
    }

    private func updateTitles() {
        let count = invitations.count
        widgetTitle = String(localized: "Course Invitations (\(count))", bundle: .student)
        widgetAccessibilityTitle = [
            String(localized: "Course Invitations", bundle: .student),
            String.format(numberOfItems: count)
        ].joined(separator: ", ")
    }
}
