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

@testable import Core
import XCTest

class APIExperienceSummaryTests: XCTestCase {
    func testCodable() throws {
        let json = """
        {
            "current_app": "academic",
            "available_apps": ["academic", "career_learner"]
        }
        """
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let response = try decoder.decode(APIExperienceSummary.self, from: data)

        XCTAssertEqual(response.current_app, .academic)
        XCTAssertEqual(response.available_apps, [.academic, .careerLearner])
    }

    func testEquality() {
        let response1 = APIExperienceSummary(current_app: .academic, available_apps: [.academic])
        let response2 = APIExperienceSummary(current_app: .academic, available_apps: [.academic])
        let response3 = APIExperienceSummary(current_app: .careerLearner, available_apps: [.academic])

        XCTAssertEqual(response1, response2)
        XCTAssertNotEqual(response1, response3)
    }
}

class ExperienceTests: XCTestCase {
    func testRawValues() {
        XCTAssertEqual(Experience.academic.rawValue, "academic")
        XCTAssertEqual(Experience.careerLearner.rawValue, "career_learner")
        XCTAssertEqual(Experience.careerLearningProvider.rawValue, "career_learning_provider")
    }

    func testCategory() {
        XCTAssertEqual(Experience.academic.category, "academic")
        XCTAssertEqual(Experience.careerLearner.category, "career")
        XCTAssertEqual(Experience.careerLearningProvider.category, "career")
    }

    func testCodable() throws {
        let experiences: [Experience] = [.academic, .careerLearner, .careerLearningProvider]
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for experience in experiences {
            let data = try encoder.encode(experience)
            let decoded = try decoder.decode(Experience.self, from: data)
            XCTAssertEqual(experience, decoded)
        }
    }
}
