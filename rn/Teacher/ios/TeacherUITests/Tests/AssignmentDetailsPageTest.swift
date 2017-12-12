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

class AssignmentDetailsPageTest: TeacherTest {
    var assignment: Soseedy_Assignment!

//    //TestRail ID = C3109579
//    func testAssignmentDetailsPage_displaysPageObjects() {
//        openAssignmentDetailsPage(self)
//        assignmentDetailsPage.assertPageObjects()
//    }

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

/*
    //TestRail ID = C3134481
    func testAssignmentDetailsPage_displaysClosedAvailability() {
        // not implemented on iOS yet.
    }
 */

//    //TestRail ID = C3134483
//    func testAssignmentDetailsPage_displaysNoToDate() {
//        openAssignmentDetailsPage(self)
//        assignmentDetailsPage.assertAvailableFromLabel(
//            emptyDateFormatttedString(for: dateTitleLabel.availableFrom), false)
//        assignmentDetailsPage.assertAvailableToLabel(
//            emptyDateFormatttedString(for: dateTitleLabel.availableTo), true)
//    }

//    //TestRail ID = C3134482
//    func testAssignmentDetailsPage_displaysNoFromDate() {
//        openAssignmentDetailsPage(self)
//        assignmentDetailsPage.assertAvailableFromLabel(
//            emptyDateFormatttedString(for: dateTitleLabel.availableFrom), true)
//        assignmentDetailsPage.assertAvailableToLabel(
//            emptyDateFormatttedString(for: dateTitleLabel.availableTo), false)
//    }

    //TestRail ID = C3165154
    func testAssignmentDetailsPage_displaysSubmissionTypeNone() {
        getToAssignmentDetails(submissionTypes: [.none])
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

//    //TestRail ID = C3109579
//    func testAssignmentDetailsPage_displaysSubmittedDonut() {
//        openAssignmentDetailsPage(self)
//        assignmentDetailsPage.assertUngradedSubmissionGraph(1)
//    }

//    //TestRail ID = C3109579
//    func testAssignmentDetailsPage_displaysNotSubmittedDonut() {
//        openAssignmentDetailsPage(self)
//        assignmentDetailsPage.assertNotSubmittedSubmissionGraph(1)
//    }

    func getToAssignmentDetails(
        withDescription: Bool = false,
        submissionTypes: [SubmissionType] = []
    ) {
        let course = createCourse()
        let user = createTeacher(in: course)
        favorite(course, as: user)
        assignment = createAssignment(
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
