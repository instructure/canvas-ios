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
import CombineSchedulers
import Core
import SwiftUI

class StudentHeaderViewModel: ObservableObject {
    // MARK: - Outputs
    enum IconState: Hashable {
        case addStudent
        case student(name: String, avatarURL: URL?)
    }
    @Published private(set) var state: IconState = .addStudent
    @Published private(set) var backgroundColor: Color = ColorScheme.observeeBlue.color.asColor
    @Published private(set) var badgeCount: Int = 0
    @Published private(set) var menuAccessibilityHint = ""
    @Published private(set) var isDropdownClosed = true
    @Published private(set) var accessibilityLabel = ""
    @Published private(set) var accessibilityHint = ""
    @Published private(set) var accessibilityValue = ""

    // MARK: - Inputs
    let didTapStudentView = PassthroughSubject<Void, Never>()
    let didTapMenuButton = PassthroughSubject<UIViewController, Never>()
    let didSelectStudent = PassthroughSubject<User?, Never>()
    let didUpdateBadgeCount = PassthroughSubject<Int, Never>()

    // MARK: - Private
    private let router: Router
    private var subscriptions = Set<AnyCancellable>()
    private var mainScheduler: AnySchedulerOf<DispatchQueue>

    init(
        router: Router = AppEnvironment.shared.router,
        mainScheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.router = router
        self.mainScheduler = mainScheduler

        toggleDropdownStateOnTap()
        updateStudentPropertiesOnStudentSelection()
        showAddStudentStateWhenStudentIsCleared()
        routeToMenuWhenMenuTapped()
        updateBadgeProperties()
    }

    private func toggleDropdownStateOnTap() {
        didTapStudentView
            .sink { [unowned self] in
                toggleDropdownState(isClosed: !isDropdownClosed)
            }
            .store(in: &subscriptions)
    }

    private func toggleDropdownState(isClosed: Bool) {
        isDropdownClosed = isClosed
        accessibilityValue = isClosed ? String(localized: "Collapsed", bundle: .core)
                                      : String(localized: "Expanded", bundle: .core)
    }

    private func updateStudentPropertiesOnStudentSelection() {
        didSelectStudent
            .compactMap { $0 }
            .sink { [unowned self] student in
                state = .student(
                    name: Core.User.displayName(student.shortName, pronouns: student.pronouns),
                    avatarURL: student.avatarURL
                )
                backgroundColor = ColorScheme.observee(student.id).color.asColor
                toggleDropdownState(isClosed: true)
                let displayName = Core.User.displayName(student.shortName, pronouns: student.pronouns)
                accessibilityLabel = String.localizedStringWithFormat(
                    String(localized: "Current student: %@", bundle: .parent),
                    displayName
                )
                accessibilityHint = String(localized: "Tap to switch students")
            }
            .store(in: &subscriptions)
    }

    private func showAddStudentStateWhenStudentIsCleared() {
        didSelectStudent
            .filter { $0 == nil }
            .sink { [unowned self] _ in
                state = .addStudent
                backgroundColor = ColorScheme.observeeBlue.color.asColor
                accessibilityLabel = String(localized: "Add Student", bundle: .parent)
                accessibilityHint = ""
            }
            .store(in: &subscriptions)
    }

    private func routeToMenuWhenMenuTapped() {
        didTapMenuButton
            .sink { [router] viewController in
                router.route(to: "/profile", from: viewController, options: .modal())
            }
            .store(in: &subscriptions)
    }

    private func updateBadgeProperties() {
        didUpdateBadgeCount
            .receive(on: mainScheduler)
            .sink { [unowned self] count in
                badgeCount = count
                menuAccessibilityHint = {
                    if badgeCount == 0 {
                        return ""
                    }
                    return String.localizedStringWithFormat(
                        String(localized: "conversation_unread_messages", bundle: .core),
                        badgeCount
                    )
                }()
            }
            .store(in: &subscriptions)
    }
}
