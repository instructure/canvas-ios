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
@testable import Horizon
import XCTest

final class CourseListWidgetModelTests: HorizonTestCase {

    private static let testData = (
        courseId: "course-id-1",
        enrollmentId: "enrollment-id-1",
        courseName: "some course name",
        imageUrl: "https://example.com/image.jpg",
        moduleTitle: "some module title",
        learningObjectName: "some learning object name",
        learningObjectId: "learning-object-id-1",
        dueDate: "2025/12/31",
        estimatedTime: "42 mins",
        programId1: "program-id-1",
        programName1: "some program name 1",
        programId2: "program-id-2",
        programName2: "some program name 2"
    )
    private lazy var testData = Self.testData

    // MARK: - Initialization from HCourse

    func test_init_shouldSetBasicProperties() {
        // Given
        let hCourse = makeHCourse(
            id: testData.courseId,
            name: testData.courseName,
            enrollmentID: testData.enrollmentId,
            imageUrl: testData.imageUrl,
            progress: 42.7
        )

        // When
        let testee = CourseListWidgetModel(from: hCourse)

        // Then
        XCTAssertEqual(testee.id, testData.courseId)
        XCTAssertEqual(testee.name, testData.courseName)
        XCTAssertEqual(testee.enrollmentID, testData.enrollmentId)
        XCTAssertEqual(testee.imageURL?.absoluteString, testData.imageUrl)
        XCTAssertEqual(testee.progress, 42.7)
    }

    func test_init_withNilImageUrl_shouldSetImageURLToNil() {
        // Given
        let hCourse = makeHCourse(imageUrl: nil)

        // When
        let testee = CourseListWidgetModel(from: hCourse)

        // Then
        XCTAssertEqual(testee.imageURL, nil)
    }

    func test_init_withPrograms_shouldMapProgramsCorrectly() {
        // Given
        let program1 = makeProgram(id: testData.programId1, name: testData.programName1)
        let program2 = makeProgram(id: testData.programId2, name: testData.programName2)
        let hCourse = makeHCourse(programs: [program1, program2])

        // When
        let testee = CourseListWidgetModel(from: hCourse)

        // Then
        XCTAssertEqual(testee.programs.count, 2)
        XCTAssertEqual(testee.programs[0].id, testData.programId1)
        XCTAssertEqual(testee.programs[0].name, testData.programName1)
        XCTAssertEqual(testee.programs[1].id, testData.programId2)
        XCTAssertEqual(testee.programs[1].name, testData.programName2)
    }

    func test_init_withCurrentLearningObject_shouldMapLearningObjectCorrectly() {
        let learningObject = HCourse.LearningObjectCard(
            moduleTitle: testData.moduleTitle,
            learningObjectName: testData.learningObjectName,
            learningObjectID: testData.learningObjectId,
            type: .assignment,
            dueDate: testData.dueDate,
            url: URL(string: "https://example.com/learning-object"),
            estimatedTime: testData.estimatedTime,
            isNewQuiz: false
        )
        let hCourse = makeHCourse(currentLearningObject: learningObject)

        let testee = CourseListWidgetModel(from: hCourse)

        XCTAssertEqual(testee.currentLearningObject?.name, testData.learningObjectName)
        XCTAssertEqual(testee.currentLearningObject?.id, testData.learningObjectId)
        XCTAssertEqual(testee.currentLearningObject?.moduleTitle, testData.moduleTitle)
        XCTAssertEqual(testee.currentLearningObject?.type, .assignment)
        XCTAssertEqual(testee.currentLearningObject?.dueDate, testData.dueDate)
        XCTAssertEqual(testee.currentLearningObject?.estimatedDuration, testData.estimatedTime)
        XCTAssertEqual(testee.currentLearningObject?.url?.absoluteString, "https://example.com/learning-object")
    }

    func test_init_withNilCurrentLearningObject_shouldSetCurrentLearningObjectToNil() {
        let hCourse = makeHCourse(currentLearningObject: nil)

        let testee = CourseListWidgetModel(from: hCourse)

        XCTAssertEqual(testee.currentLearningObject, nil)
    }

    func test_init_shouldSetLastActivityAtToNil() {
        let hCourse = makeHCourse()

        let testee = CourseListWidgetModel(from: hCourse)

        XCTAssertEqual(testee.lastActivityAt, nil)
    }

    // MARK: - progressPercentage

    func test_progressPercentage_shouldFormatProgressAsPercentage() {
        var testee = CourseListWidgetModel(from: makeHCourse(progress: 0))
        XCTAssertEqual(testee.progressPercentage, "0%")

        testee = CourseListWidgetModel(from: makeHCourse(progress: 42.3))
        XCTAssertEqual(testee.progressPercentage, "42%")

        testee = CourseListWidgetModel(from: makeHCourse(progress: 42.7))
        XCTAssertEqual(testee.progressPercentage, "43%")

        testee = CourseListWidgetModel(from: makeHCourse(progress: 100))
        XCTAssertEqual(testee.progressPercentage, "100%")
    }

    // MARK: - hasPrograms

    func test_hasPrograms_withEmptyPrograms_shouldBeFalse() {
        let testee = CourseListWidgetModel(from: makeHCourse(programs: []))

        XCTAssertEqual(testee.hasPrograms, false)
    }

    func test_hasPrograms_withPrograms_shouldBeTrue() {
        let program = makeProgram()
        let testee = CourseListWidgetModel(from: makeHCourse(programs: [program]))

        XCTAssertEqual(testee.hasPrograms, true)
    }

    // MARK: - primaryProgram

    func test_primaryProgram_withEmptyPrograms_shouldBeNil() {
        let testee = CourseListWidgetModel(from: makeHCourse(programs: []))

        XCTAssertEqual(testee.primaryProgram, nil)
    }

    func test_primaryProgram_withPrograms_shouldReturnFirstProgram() {
        let program1 = makeProgram(id: testData.programId1, name: testData.programName1)
        let program2 = makeProgram(id: testData.programId2, name: testData.programName2)
        let testee = CourseListWidgetModel(from: makeHCourse(programs: [program1, program2]))

        XCTAssertEqual(testee.primaryProgram?.id, testData.programId1)
        XCTAssertEqual(testee.primaryProgram?.name, testData.programName1)
    }

    // MARK: - hasCurrentLearningObject

    func test_hasCurrentLearningObject_withNilLearningObject_shouldBeFalse() {
        let testee = CourseListWidgetModel(from: makeHCourse(currentLearningObject: nil))

        XCTAssertEqual(testee.hasCurrentLearningObject, false)
    }

    func test_hasCurrentLearningObject_withLearningObject_shouldBeTrue() {
        let learningObject = makeLearningObject()
        let testee = CourseListWidgetModel(from: makeHCourse(currentLearningObject: learningObject))

        XCTAssertEqual(testee.hasCurrentLearningObject, true)
    }

    // MARK: - isCourseCompleted

    func test_isCourseCompleted_with100ProgressAndNoLearningObject_shouldBeTrue() {
        let testee = CourseListWidgetModel(from: makeHCourse(
            progress: 100,
            currentLearningObject: nil
        ))

        XCTAssertEqual(testee.isCourseCompleted, true)
    }

    func test_isCourseCompleted_with100ProgressAndLearningObject_shouldBeFalse() {
        let learningObject = makeLearningObject()
        let testee = CourseListWidgetModel(from: makeHCourse(
            progress: 100,
            currentLearningObject: learningObject
        ))

        XCTAssertEqual(testee.isCourseCompleted, false)
    }

    func test_isCourseCompleted_withPartialProgressAndNoLearningObject_shouldBeFalse() {
        let testee = CourseListWidgetModel(from: makeHCourse(
            progress: 50,
            currentLearningObject: nil
        ))

        XCTAssertEqual(testee.isCourseCompleted, false)
    }

    func test_isCourseCompleted_with99Point5Progress_shouldBeFalse() {
        let testee = CourseListWidgetModel(from: makeHCourse(
            progress: 99.5,
            currentLearningObject: nil
        ))

        XCTAssertEqual(testee.isCourseCompleted, true)
    }

    // MARK: - buttonCourseTitle

    func test_buttonCourseTitle() {
        var testee = CourseListWidgetModel(from: makeHCourse(progress: 0))
        XCTAssertEqual(testee.buttonCourseTitle, "Start learning")

        testee = CourseListWidgetModel(from: makeHCourse(progress: 50))
        XCTAssertEqual(testee.buttonCourseTitle, "Resume learning")

        testee = CourseListWidgetModel(from: makeHCourse(progress: 100))
        XCTAssertEqual(testee.buttonCourseTitle, "View course")
    }

    // MARK: - status

    func test_status_shouldReturnCorrectProgressStatus() {
        var testee = CourseListWidgetModel(from: makeHCourse(progress: 0))
        XCTAssertEqual(testee.status, .notStarted)

        testee = CourseListWidgetModel(from: makeHCourse(progress: 50))
        XCTAssertEqual(testee.status, .inProgress)

        testee = CourseListWidgetModel(from: makeHCourse(progress: 100))
        XCTAssertEqual(testee.status, .completed)
    }

    // MARK: - accessibilityDescription

    func test_accessibilityDescription_withMockCourseId_shouldReturnLoadingMessage() {
        let testee = CourseListWidgetModel(from: makeHCourse(id: "mock-course-id"))

        XCTAssertEqual(testee.accessibilityDescription, "Courses are loading")
    }

    func test_accessibilityDescription_withBasicCourse() {
        let testee = CourseListWidgetModel(from: makeHCourse(
            name: testData.courseName,
            progress: 42
        ))

        let expected = "Course: \(testData.courseName). Progress: 42 percent complete. "
        XCTAssertEqual(testee.accessibilityDescription, expected)
    }

    func test_accessibilityDescription_withPrograms() {
        let program1 = makeProgram(name: testData.programName1)
        let program2 = makeProgram(name: testData.programName2)
        let testee = CourseListWidgetModel(from: makeHCourse(
            name: testData.courseName,
            progress: 42,
            programs: [program1, program2]
        ))

        let expected = "Course: \(testData.courseName). Part of \(testData.programName1), \(testData.programName2). Progress: 42 percent complete. "
        XCTAssertEqual(testee.accessibilityDescription, expected)
    }

    func test_accessibilityDescription_withCurrentLearningObjectWithoutType() {
        let learningObject = HCourse.LearningObjectCard(
            moduleTitle: testData.moduleTitle,
            learningObjectName: testData.learningObjectName,
            learningObjectID: testData.learningObjectId,
            type: nil,
            dueDate: testData.dueDate,
            url: URL(string: "https://example.com"),
            estimatedTime: testData.estimatedTime,
            isNewQuiz: false
        )
        let testee = CourseListWidgetModel(from: makeHCourse(
            name: testData.courseName,
            progress: 42,
            currentLearningObject: learningObject
        ))

        let expected =
            "Course: \(testData.courseName). " +
            "Progress: 42 percent complete. " +
            "Current learning object: \(testData.learningObjectName). " +
            "Due at \(testData.dueDate). " +
            "Estimated duration: \(testData.estimatedTime)."
        XCTAssertEqual(
            testee.accessibilityDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            expected
        )
    }

    // MARK: - accessiblityHintString

    func test_accessiblityHintString_withCurrentLearningObject_shouldReturnOpenLearningObject() {
        let learningObject = makeLearningObject()
        let testee = CourseListWidgetModel(from: makeHCourse(currentLearningObject: learningObject))

        XCTAssertEqual(testee.accessibilityHintString, "Double tap to open learning object")
    }

    func test_accessiblityHintString_withoutCurrentLearningObject_shouldReturnOpenCourse() {
        let testee = CourseListWidgetModel(from: makeHCourse(currentLearningObject: nil))

        XCTAssertEqual(testee.accessibilityHintString, "Double tap to open course")
    }
    func test_accessiblityLearnDescription() {
        let testee = CourseListWidgetModel(from: makeHCourse(
            name: testData.courseName,
            progress: 42
        ))
        let expected = "Course: \(testData.courseName). Progress: 42 percent complete. "
        XCTAssertEqual(testee.accessibilityLearnDescription, expected)
    }

    // MARK: - viewProgramAccessibilityString

    func test_viewProgramAccessibilityString() {
        let testee = CourseListWidgetModel(from: makeHCourse())

        let result = testee.viewProgramAccessibilityString(testData.programName1)

        XCTAssertEqual(result, "Open \(testData.programName1)")
    }

    // MARK: - Private helpers

    private func makeHCourse(
        id: String = "course-id-1",
        name: String = "some course name",
        enrollmentID: String = "enrollment-id-1",
        imageUrl: String? = nil,
        progress: Double = 0,
        currentLearningObject: HCourse.LearningObjectCard? = nil,
        programs: [Program] = []
    ) -> HCourse {
        HCourse(
            id: id,
            name: name,
            institutionName: "some institution",
            state: "active",
            enrollmentID: enrollmentID,
            enrollments: [],
            modules: [],
            progress: progress,
            overviewDescription: "some description",
            imageUrl: imageUrl,
            currentLearningObject: currentLearningObject,
            programs: programs
        )
    }

    private func makeProgram(
        id: String = "program-id-1",
        name: String = "some program name"
    ) -> Program {
        Program(
            id: id,
            name: name,
            variant: "some variant",
            description: "some description",
            date: "2025/01/01",
            courseCompletionCount: 0,
            courses: []
        )
    }

    private func makeLearningObject() -> HCourse.LearningObjectCard {
        HCourse.LearningObjectCard(
            moduleTitle: testData.moduleTitle,
            learningObjectName: testData.learningObjectName,
            learningObjectID: testData.learningObjectId,
            type: .assignment,
            dueDate: testData.dueDate,
            url: URL(string: "https://example.com"),
            estimatedTime: testData.estimatedTime,
            isNewQuiz: false
        )
    }
}
