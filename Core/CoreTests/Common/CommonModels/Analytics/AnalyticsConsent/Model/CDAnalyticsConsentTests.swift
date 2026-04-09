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

import XCTest
@testable import Core
import TestsFoundation

final class CDAnalyticsConsentTests: CoreTestCase {

    // MARK: - save

    func test_save_whenDataHasConsentTrue_shouldSetConsentValueToTrue() {
        let item = APIAnalyticsConsent.make(data: .init(mobile_consent: true))

        let testee = CDAnalyticsConsent.save(item, in: databaseClient)

        XCTAssertEqual(testee.consentValue, true)
    }

    func test_save_whenDataHasConsentFalse_shouldSetConsentValueToFalse() {
        let item = APIAnalyticsConsent.make(data: .init(mobile_consent: false))

        let testee = CDAnalyticsConsent.save(item, in: databaseClient)

        XCTAssertEqual(testee.consentValue, false)
    }

    func test_save_whenDataHasConsentNil_shouldSetConsentValueToNil() {
        let item = APIAnalyticsConsent.make(data: .init(mobile_consent: nil))

        let testee = CDAnalyticsConsent.save(item, in: databaseClient)

        XCTAssertEqual(testee.consentValue, nil)
    }

    func test_save_whenMessageIsNoData_shouldSetConsentValueToNil() {
        let item = APIAnalyticsConsent.make(message: APIAnalyticsConsent.noDataMessage)

        let testee = CDAnalyticsConsent.save(item, in: databaseClient)

        XCTAssertEqual(testee.consentValue, nil)
    }

    func test_save_whenDataAndMessageAreNil_shouldSetConsentValueToNil() {
        let item = APIAnalyticsConsent.make()

        let testee = CDAnalyticsConsent.save(item, in: databaseClient)

        XCTAssertEqual(testee.consentValue, nil)
    }

    func test_save_shouldUpdateExistingEntityInsteadOfCreatingNew() {
        CDAnalyticsConsent.save(.make(data: .init(mobile_consent: true)), in: databaseClient)

        CDAnalyticsConsent.save(.make(data: .init(mobile_consent: false)), in: databaseClient)

        let all: [CDAnalyticsConsent] = databaseClient.fetch()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.consentValue, false)
    }
}
