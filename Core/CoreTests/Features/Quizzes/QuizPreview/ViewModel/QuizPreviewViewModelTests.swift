//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Core
import Combine
import XCTest

class QuizPreviewViewModelTests: XCTestCase {

    func testForwardsInteractorStateToPublishedProperty() {
        let mockInteractor = QuizPreviewInteractorMock()
        let testee = QuizPreviewViewModel(interactor: mockInteractor)

        XCTAssertEqual(testee.state, .loading)
        mockInteractor.state.send(.error)
        XCTAssertEqual(testee.state, .error)
        mockInteractor.state.send(.data(launchURL: URL(string: "/test")!))
        XCTAssertEqual(testee.state, .data(launchURL: URL(string: "/test")!))
    }
}

private class QuizPreviewInteractorMock: QuizPreviewInteractor {
    var state = CurrentValueSubject<QuizPreviewInteractorState, Never>(.loading)
}
