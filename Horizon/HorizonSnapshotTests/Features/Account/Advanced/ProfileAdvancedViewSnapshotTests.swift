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

class ProfileAdvancedViewSnapshotTests: HorizonSnapshotTestCase {
    func testProfileAdvancedViewDefault() {
        let viewModel = createMockProfileAdvancedViewModel(timeZone: "America/Denver")
        let view = ProfileAdvancedView(viewModel: viewModel)

        assertSnapshot(
            of: view,
            named: "profile-advanced-default"
        )
    }

    func testProfileAdvancedViewLoading() {
        let viewModel = createMockProfileAdvancedViewModel(timeZone: "America/Denver")
        viewModel.isLoading = true
        let view = ProfileAdvancedView(viewModel: viewModel)

        assertSnapshot(
            of: view,
            named: "profile-advanced-loading"
        )
    }

    private func createMockProfileAdvancedViewModel(timeZone: String) -> ProfileAdvancedViewModel {
        let mockGetUserInteractor = MockAdvancedGetUserInteractor(timeZone: timeZone, context: databaseClient)
        let mockUpdateInteractor = MockAdvancedUpdateUserProfileInteractor(context: databaseClient)

        return ProfileAdvancedViewModel(
            getUserInteractor: mockGetUserInteractor,
            updateUserProfileInteractor: mockUpdateInteractor
        )
    }
}

private class MockAdvancedGetUserInteractor: GetUserInteractor {
    let timeZone: String
    let context: NSManagedObjectContext

    init(timeZone: String, context: NSManagedObjectContext) {
        self.timeZone = timeZone
        self.context = context
    }

    func getUser() -> AnyPublisher<UserProfile, Error> {
        let user = UserProfile(context: context)
        user.id = "1"
        user.name = "Test User"
        user.shortName = "Test"
        user.email = "test@example.com"
        user.defaultTimeZone = timeZone

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

private class MockAdvancedUpdateUserProfileInteractor: UpdateUserProfileInteractor {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func set(name _: String, shortName _: String) -> AnyPublisher<UserProfile, Error> {
        fatalError("Not implemented")
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
