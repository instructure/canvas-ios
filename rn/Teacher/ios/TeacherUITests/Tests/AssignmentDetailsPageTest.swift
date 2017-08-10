//
// Copyright (C) 2017-present Instructure, Inc.
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

//    //TestRail ID = C3109579
//    func testAssignmentDetailsPage_displaysPageObjects() {
//        openAssignmentDetailsPage(self)
//        assignmentDetailsPage.assertPageObjects()
//    }

    //TestRail ID = C3109579
    func testAssignmentDetailsPage_displaysInstructions() {
        openAssignmentDetailsPage(self)
        assignmentDetailsPage.assertDisplaysInstructions()
    }

    //TestRail ID = C3109579
    func testAssignmentDetailsPage_displaysCorrectDetails() {
        let (_, assignment) = openAssignmentDetailsPage(self)
        assignmentDetailsPage.assertAssignmentDetails(
            assignment.name,
            publishStatusFormattedString(assignment.published))
    }

    //TestRail ID = C3134480
    func testAssignmentDetailsPage_displaysNoInstructionsMessage() {
        openAssignmentDetailsPage(self)
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
        let (_, assignment) = openAssignmentDetailsPage(self)
        assignmentDetailsPage.assertSubmissionTypes(
            submissionTypesFormattedString(assignment.submissionTypes))
    }

    //TestRail ID = C3165154
    func testAssignmentDetailsPage_displaysSubmissionTypeOnPaper() {
        let (_, assignment) = openAssignmentDetailsPage(self)
        assignmentDetailsPage.assertSubmissionTypes(
            submissionTypesFormattedString(assignment.submissionTypes))
    }

    //TestRail ID = C3165154
    func testAssignmentDetailsPage_displaysSubmissionTypeOnlineTextEntry() {
        let (_, assignment) = openAssignmentDetailsPage(self)
        assignmentDetailsPage.assertSubmissionTypes(
            submissionTypesFormattedString(assignment.submissionTypes))
    }

    //TestRail ID = C3165154
    func testAssignmentDetailsPage_displaysSubmissionTypeOnlineUrl() {
        let (_, assignment) = openAssignmentDetailsPage(self)
        assignmentDetailsPage.assertSubmissionTypes(
            submissionTypesFormattedString(assignment.submissionTypes))
    }

    //TestRail ID = C3165154
    func testAssignmentDetailsPage_displaysSubmissionTypeOnlineUpload() {
        let (_, assignment) = openAssignmentDetailsPage(self)
        assignmentDetailsPage.assertSubmissionTypes(
            submissionTypesFormattedString(assignment.submissionTypes))
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
}
