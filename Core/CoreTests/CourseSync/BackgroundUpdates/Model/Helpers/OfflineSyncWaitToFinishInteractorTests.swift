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

@testable import Core
import Combine
import CombineExt
import XCTest

class OfflineSyncWaitToFinishInteractorTests: CoreTestCase {

    func testRecognizesSyncFinishEvent() {
        let valueExpectation = expectation(description: "Value was published")
        let finishExpectation = expectation(description: "Stream finished")
        let publisher = PassthroughRelay<Void>()
        let testee = publisher
            .flatMap { OfflineSyncWaitToFinishInteractor.wait() }
            .first()
            .sink { completion in
                switch completion {
                case .finished: finishExpectation.fulfill()
                case .failure: break
                }
            } receiveValue: { _ in
                valueExpectation.fulfill()
            }
        let downloadProgressEntity: CDCourseSyncDownloadProgress = AppEnvironment.shared.database.viewContext.insert()
        downloadProgressEntity.isFinished = false
        publisher.accept()

        // WHEN
        downloadProgressEntity.isFinished = true

        // THEN
        waitForExpectations(timeout: 1)
        testee.cancel()
    }
}
