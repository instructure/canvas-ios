//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import Combine
import XCTest
@testable import Student

final class HelloWidgetInteractorMock: HelloWidgetInteractor {
    var shortName: String?
    let shortNameExpectation: XCTestExpectation?

    init(
        shortName: String? = nil,
        shortNameExpectation: XCTestExpectation? = nil,
    ) {
        self.shortName = shortName
        self.shortNameExpectation = shortNameExpectation
    }

    func getShortName(ignoreCache: Bool = false) -> AnyPublisher<String?, Error> {
        Just(shortName)
            .setFailureType(to: Error.self)
            .handleEvents(receiveCompletion: { _ in self.shortNameExpectation?.fulfill() })
            .eraseToAnyPublisher()
    }
}
