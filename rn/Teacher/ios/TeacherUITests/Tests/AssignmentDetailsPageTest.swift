//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import SoSeedySwift

class AssignmentDetailsPageTest: TeacherTest {
    var assignment: Soseedy_Assignment!

    //TestRail ID = C3109579
    func testAssignmentDetailsPage_displaysInstructions() {
        getToAssignmentDetails(withDescription: true)
        assignmentDetailsPage.assertDisplaysInstructions()
    }

    //TestRail ID = C3109579
    func testAssignmentDetailsPage_displaysCorrectDetails() {
        getToAssignmentDetails()
        assignmentDetailsPage.assertAssignmentDetails(
            assignment.name,
            publishStatusFormattedString(assignment.published))
    }

    //TestRail ID = C3134480
    func testAssignmentDetailsPage_displaysNoInstructionsMessage() {
        getToAssignmentDetails(withDescription: false)
        assignmentDetailsPage.assertDisplaysNoInstructionsView()
    }

    //TestRail ID = C3165154
    func testAssignmentDetailsPage_displaysSubmissionTypeNone() {
        getToAssignmentDetails(submissionTypes: [.noType])
        assignmentDetailsPage.assertSubmissionTypes(
            submissionTypesFormattedString([.none]))
    }

    //TestRail ID = C3165154
    func testAssignmentDetailsPage_displaysSubmissionTypeOnPaper() {
        getToAssignmentDetails(submissionTypes: [.onPaper])
        assignmentDetailsPage.assertSubmissionTypes(
            submissionTypesFormattedString([.onPaper]))
    }

    //TestRail ID = C3165154
    func testAssignmentDetailsPage_displaysSubmissionTypeOnlineTextEntry() {
        getToAssignmentDetails(submissionTypes: [.onlineTextEntry])
        assignmentDetailsPage.assertSubmissionTypes(
            submissionTypesFormattedString([.onlineTextEntry]))
    }

    //TestRail ID = C3165154
    func testAssignmentDetailsPage_displaysSubmissionTypeOnlineUrl() {
        getToAssignmentDetails(submissionTypes: [.onlineURL])
        assignmentDetailsPage.assertSubmissionTypes(
            submissionTypesFormattedString([.onlineURL]))
    }

    //TestRail ID = C3165154
    func testAssignmentDetailsPage_displaysSubmissionTypeOnlineUpload() {
        getToAssignmentDetails(submissionTypes: [.onlineUpload])
        assignmentDetailsPage.assertSubmissionTypes(
            submissionTypesFormattedString([.onlineUpload]))
    }

    func getToAssignmentDetails(
        withDescription: Bool = false,
        submissionTypes: [Soseedy_SubmissionType] = []
    ) {
        let course = SoSeedySwift.createCourse()
        let user = SoSeedySwift.createTeacher(in: course)
        SoSeedySwift.favorite(course, as: user)
        assignment = SoSeedySwift.createAssignment(
            for: course,
            as: user,
            withDescription: withDescription,
            submissionTypes: submissionTypes
        )
        logIn2(user)
        coursesListPage.openCourseDetailsPage(course)
        courseBrowserPage.openAssignmentListPage()
        assignmentListPage.openAssignmentDetailsPage(assignment)
    }
}
