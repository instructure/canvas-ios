//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import TestsFoundation
import PactConsumerSwift
@testable import Core

open class PactTestCase: XCTestCase {
    open var providerName: String { "Canvas LMS API" }

    let service = PactVerificationService(url: "http://localhost", port: 1234, allowInsecureCertificates: true)
    lazy var provider = CanvasMockService(provider: providerName, consumer: "canvas-ios", pactVerificationService: service)
    lazy var environment: TestEnvironment = {
        let environment = TestEnvironment()
        environment.api = provider.api
        return environment
    }()
}
