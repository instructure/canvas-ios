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

class ProfileViewSnapshotTests: HorizonSnapshotTestCase {
    func testProfileViewDefault() {
        let viewModel = createMockProfileViewModel(
            name: "John Doe",
            displayName: "Johnny",
            email: "john.doe@example.com",
            canUpdateName: true
        )
        let view = ProfileView(viewModel: viewModel)

        assertSnapshot(
            of: view,
            named: "profile-default"
        )
    }

    func testProfileViewReadOnly() {
        let viewModel = createMockProfileViewModel(
            name: "Jane Smith",
            displayName: "Jane",
            email: "jane.smith@example.com",
            canUpdateName: false
        )
        let view = ProfileView(viewModel: viewModel)

        assertSnapshot(
            of: view,
            named: "profile-readonly"
        )
    }

    func testProfileViewWithErrors() {
        let viewModel = createMockProfileViewModel(
            name: "",
            displayName: "",
            email: "test@example.com",
            canUpdateName: true
        )
        let view = ProfileView(viewModel: viewModel)

        assertSnapshot(
            of: view,
            named: "profile-errors"
        )
    }

    private func createMockProfileViewModel(
        name: String,
        displayName: String,
        email: String,
        canUpdateName: Bool
    ) -> ProfileViewModel {
        let mockGetUserInteractor = MockGetUserInteractor(
            name: name,
            displayName: displayName,
            email: email,
            canUpdateName: canUpdateName,
            context: databaseClient
        )
        let mockUpdateInteractor = MockUpdateUserProfileInteractor(context: databaseClient)

        return ProfileViewModel(
            getUserInteractor: mockGetUserInteractor,
            updateUserProfileInteractor: mockUpdateInteractor
        )
    }
}

private class MockGetUserInteractor: GetUserInteractor {
    let name: String
    let displayName: String
    let email: String
    let canUpdate: Bool
    let context: NSManagedObjectContext

    init(name: String, displayName: String, email: String, canUpdateName: Bool, context: NSManagedObjectContext) {
        self.name = name
        self.displayName = displayName
        self.email = email
        canUpdate = canUpdateName
        self.context = context
    }

    func getUser() -> AnyPublisher<UserProfile, Error> {
        let user = UserProfile(context: context)
        user.id = "1"
        user.name = name
        user.shortName = displayName
        user.pronouns = nil
        user.avatarURL = URL(string: "https://example.com/avatar.jpg")
        user.email = email
        user.locale = "en"

        return Just(user)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func canUpdateName() -> AnyPublisher<Bool, Error> {
        Just(canUpdate)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

private class MockUpdateUserProfileInteractor: UpdateUserProfileInteractor {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func set(name: String, shortName: String) -> AnyPublisher<UserProfile, Error> {
        let user = UserProfile(context: context)
        user.id = "1"
        user.name = name
        user.shortName = shortName
        user.email = "test@example.com"

        return Just(user)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func set(timeZone: String) -> AnyPublisher<UserProfile, Error> {
        let user = UserProfile(context: context)
        user.id = "1"
        user.name = "Test User"
        user.defaultTimeZone = timeZone

        return Just(user)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
