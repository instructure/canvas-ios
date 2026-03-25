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

@testable import Horizon
@testable import Core
import XCTest
import Combine

final class LearningLibraryRecommendationUseCaseTests: HorizonTestCase {

    private var testee: LearningLibraryRecommendationUseCase!

    override func setUpWithError() throws {
        testee = LearningLibraryRecommendationUseCase()
    }

    override func tearDownWithError() throws {
        testee = nil
    }

    func testCacheKey() {
        XCTAssertEqual(testee.cacheKey, "Learning-Library-Recommendation")
    }

    func testRequest() {
        let request = testee.request
        XCTAssertNotNil(request)
    }

    func testScope() {
        let scope = testee.scope
        XCTAssertNotNil(scope.predicate)
        XCTAssertEqual(scope.order, [NSSortDescriptor(key: #keyPath(CDHLearningLibraryCollectionItem.displayOrder), ascending: true)])
    }

    func testMakeRequestSuccess() {
        testee = LearningLibraryRecommendationUseCase(
            journey: DomainServiceMock(result: .success(api))
        )
        let expectation = expectation(description: "Wait for completion")
        api.mock(
            DomainJWTService.JWTTokenRequest(),
            value: DomainJWTService.JWTTokenRequest.Result(token: "test-token")
        )
        let recommendationJSON = """
        {
            "data": {
                "learningRecommendations": {
                    "recommendations": [
                        {
                            "courseId": "course-123",
                            "primaryReason": "Based on your skills",
                            "popularityCount": 150,
                            "sourceContext": {
                                "sourceCourseId": "source-course-1",
                                "sourceCourseName": "Introduction to Programming",
                                "sourceSkillName": "Swift"
                            },
                            "membership": {
                                "id": "rec-item-1",
                                "libraryId": "library-1",
                                "itemType": "COURSE",
                                "displayOrder": 1,
                                "isBookmarked": false,
                                "completionPercentage": 0,
                                "isEnrolledInCanvas": false,
                                "createdAt": "2026-01-01T00:00:00Z",
                                "updatedAt": "2026-02-01T00:00:00Z",
                                "canvasCourse": {
                                    "courseId": "course-123",
                                    "courseName": "Recommended Swift Course",
                                    "canvasUrl": "https://canvas.example.com/courses/123",
                                    "courseImageUrl": "https://canvas.example.com/images/course1.jpg",
                                    "moduleCount": 5,
                                    "moduleItemCount": 20,
                                    "estimatedDurationMinutes": 180
                                }
                            }
                        }
                    ]
                }
            }
        }
        """
        let response = try! JSONDecoder().decode(LearningLibraryRecommendationResponse.self, from: recommendationJSON.data(using: .utf8)!)
        api.mock(
            testee.request,
            value: response
        )

        testee.makeRequest(environment: environment) { response, _, _ in
            expectation.fulfill()
            XCTAssertNotNil(response)
            XCTAssertEqual(response?.data.learningRecommendations.recommendations.count, 1)
            XCTAssertEqual(response?.data.learningRecommendations.recommendations.first?.courseID, "course-123")
            XCTAssertEqual(response?.data.learningRecommendations.recommendations.first?.primaryReason, "Based on your skills")
        }
        wait(for: [expectation], timeout: 0.2)
    }

    func testMakeRequestFail() {
        let domainService = DomainServiceMock(result: .failure(DomainJWTService.Issue.unableToGetToken))
        testee = LearningLibraryRecommendationUseCase(
            journey: domainService
        )
        let expectation = expectation(description: "Wait for completion")
        api.mock(
            DomainJWTService.JWTTokenRequest(),
            value: DomainJWTService.JWTTokenRequest.Result(token: "test-token"),
            error: DomainJWTService.Issue.unableToGetToken
        )

        testee.makeRequest(environment: environment) { response, _, error in
            expectation.fulfill()
            XCTAssertNil(response)
            XCTAssertEqual(error?.localizedDescription, DomainJWTService.Issue.unableToGetToken.localizedDescription)
        }
        wait(for: [expectation], timeout: 0.2)
    }

    func testWriteResponseSavesRecommendations() {
        let recommendationJSON = """
        {
            "data": {
                "learningRecommendations": {
                    "recommendations": [
                        {
                            "courseId": "course-123",
                            "primaryReason": "Based on your skills",
                            "popularityCount": 150,
                            "sourceContext": {
                                "sourceCourseId": "source-course-1",
                                "sourceCourseName": "Introduction to Programming",
                                "sourceSkillName": "Swift"
                            },
                            "membership": {
                                "id": "rec-item-1",
                                "libraryId": "library-1",
                                "itemType": "COURSE",
                                "displayOrder": 1,
                                "isBookmarked": false,
                                "completionPercentage": 0,
                                "isEnrolledInCanvas": false,
                                "createdAt": "2026-01-01T00:00:00Z",
                                "updatedAt": "2026-02-01T00:00:00Z",
                                "canvasCourse": {
                                    "courseId": "course-123",
                                    "courseName": "Recommended Swift Course",
                                    "canvasUrl": "https://canvas.example.com/courses/123",
                                    "courseImageUrl": "https://canvas.example.com/images/course1.jpg",
                                    "moduleCount": 5,
                                    "moduleItemCount": 20,
                                    "estimatedDurationMinutes": 180
                                }
                            }
                        },
                        {
                            "courseId": "course-456",
                            "primaryReason": "Popular among learners",
                            "popularityCount": 200,
                            "sourceContext": null,
                            "membership": {
                                "id": "rec-item-2",
                                "libraryId": "library-2",
                                "itemType": "COURSE",
                                "displayOrder": 2,
                                "isBookmarked": false,
                                "completionPercentage": 0,
                                "isEnrolledInCanvas": false,
                                "createdAt": "2026-01-15T00:00:00Z",
                                "updatedAt": "2026-02-15T00:00:00Z",
                                "canvasCourse": {
                                    "courseId": "course-456",
                                    "courseName": "Popular Python Course",
                                    "canvasUrl": "https://canvas.example.com/courses/456",
                                    "courseImageUrl": "https://canvas.example.com/images/course2.jpg",
                                    "moduleCount": 3,
                                    "moduleItemCount": 15,
                                    "estimatedDurationMinutes": 120
                                }
                            }
                        }
                    ]
                }
            }
        }
        """
        let response = try! JSONDecoder().decode(LearningLibraryRecommendationResponse.self, from: recommendationJSON.data(using: .utf8)!)

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let items: [CDHLearningLibraryCollectionItem] = databaseClient.fetch()
        XCTAssertEqual(items.count, 2)
    }

    func testWriteResponseWithEmptyRecommendations() {
        let recommendationJSON = """
        {
            "data": {
                "learningRecommendations": {
                    "recommendations": []
                }
            }
        }
        """
        let response = try! JSONDecoder().decode(LearningLibraryRecommendationResponse.self, from: recommendationJSON.data(using: .utf8)!)

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let items: [CDHLearningLibraryCollectionItem] = databaseClient.fetch()
        XCTAssertEqual(items.count, 0)
    }

    func testWriteResponseWithNilResponse() {
        testee.write(response: nil, urlResponse: nil, to: databaseClient)

        let items: [CDHLearningLibraryCollectionItem] = databaseClient.fetch()
        XCTAssertEqual(items.count, 0)
    }

    func testWriteResponseSavesSourceContext() {
        let recommendationJSON = """
        {
            "data": {
                "learningRecommendations": {
                    "recommendations": [
                        {
                            "courseId": "course-123",
                            "primaryReason": "Based on your skills",
                            "popularityCount": 150,
                            "sourceContext": {
                                "sourceCourseId": "source-course-1",
                                "sourceCourseName": "Introduction to Programming",
                                "sourceSkillName": "Swift"
                            },
                            "membership": {
                                "id": "rec-item-1",
                                "libraryId": "library-1",
                                "itemType": "COURSE",
                                "displayOrder": 1,
                                "isBookmarked": false,
                                "completionPercentage": 0,
                                "isEnrolledInCanvas": false,
                                "createdAt": "2026-01-01T00:00:00Z",
                                "updatedAt": "2026-02-01T00:00:00Z",
                                "canvasCourse": {
                                    "courseId": "course-123",
                                    "courseName": "Recommended Swift Course",
                                    "canvasUrl": "https://canvas.example.com/courses/123",
                                    "courseImageUrl": "https://canvas.example.com/images/course1.jpg",
                                    "moduleCount": 5,
                                    "moduleItemCount": 20,
                                    "estimatedDurationMinutes": 180
                                }
                            }
                        }
                    ]
                }
            }
        }
        """
        let response = try! JSONDecoder().decode(LearningLibraryRecommendationResponse.self, from: recommendationJSON.data(using: .utf8)!)

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let items: [CDHLearningLibraryCollectionItem] = databaseClient.fetch()
        XCTAssertEqual(items.count, 1)
    }
}
