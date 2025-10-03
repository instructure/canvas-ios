//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import CoreData
@testable import Horizon
import HorizonUI
import SnapshotTesting
import SwiftUI
import TestsFoundation
import XCTest

class AccountViewSnapshotTests: HorizonSnapshotTestCase {
    func testAccountViewDefault() {
        let viewModel = createMockAccountViewModel(
            userName: "John Doe",
            isExperienceSwitchAvailable: true,
            isLoading: false
        )
        let view = AccountView(viewModel: viewModel)

        assertSnapshot(
            of: view,
            named: "account-default"
        )
    }

    func testAccountViewLoading() {
        let viewModel = createMockAccountViewModel(
            userName: "John Doe",
            isExperienceSwitchAvailable: true,
            isLoading: true
        )
        let view = AccountView(viewModel: viewModel)

        assertSnapshot(
            of: view,
            named: "account-loading"
        )
    }

    func testAccountViewNoExperienceSwitch() {
        let viewModel = createMockAccountViewModel(
            userName: "Jane Smith",
            isExperienceSwitchAvailable: false,
            isLoading: false
        )
        let view = AccountView(viewModel: viewModel)

        assertSnapshot(
            of: view,
            named: "account-no-experience-switch"
        )
    }

    func testAccountViewAccessibility() {
        let viewModel = createMockAccountViewModel(
            userName: "Very Long User Name That Should Wrap",
            isExperienceSwitchAvailable: true,
            isLoading: false
        )
        let view = AccountView(viewModel: viewModel)

        assertAccessibilitySnapshot(
            of: view,
            named: "account-accessibility"
        )
    }

    // MARK: - Helper Methods

    private func createMockAccountViewModel(
        userName: String,
        isExperienceSwitchAvailable: Bool,
        isLoading: Bool
    ) -> AccountViewModel {
        let mockUserInteractor = MockGetUserInteractor(userName: userName, context: databaseClient)
        let mockExperienceInteractor = MockExperienceSummaryInteractor(isAvailable: isExperienceSwitchAvailable)

        let viewModel = AccountViewModel(
            getUserInteractor: mockUserInteractor,
            appExperienceInteractor: mockExperienceInteractor
        )

        // Trigger data loading
        viewModel.getUserName()

        // Override loading state after initial setup
        viewModel.isLoading = isLoading

        return viewModel
    }
}

// MARK: - Mock Interactors

private class MockGetUserInteractor: GetUserInteractor {
    let userName: String
    let context: NSManagedObjectContext

    init(userName: String, context: NSManagedObjectContext) {
        self.userName = userName
        self.context = context
    }

    func getUser() -> AnyPublisher<UserProfile, Error> {
        let user = UserProfile(context: context)
        user.id = "1"
        user.name = userName
        user.shortName = userName
        user.pronouns = nil
        user.avatarURL = URL(string: "https://example.com/avatar.jpg")
        user.email = "user@example.com"
        user.locale = "en"

        return Just(user)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func canUpdateName() -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

private class MockExperienceSummaryInteractor: ExperienceSummaryInteractor {
    let isAvailable: Bool

    init(isAvailable: Bool) {
        self.isAvailable = isAvailable
    }

    func getExperienceSummary() -> AnyPublisher<Experience, Error> {
        Just(.careerLearner)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func isExperienceSwitchAvailable() -> AnyPublisher<Bool, Never> {
        Just(isAvailable).eraseToAnyPublisher()
    }

    func isExperienceSwitchAvailableAsync() async -> Bool {
        isAvailable
    }

    func switchExperience(to _: Experience) -> AnyPublisher<Void, Never> {
        Just(()).eraseToAnyPublisher()
    }
}
