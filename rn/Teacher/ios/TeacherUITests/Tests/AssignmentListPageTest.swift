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

class AssignmentListPageTest: TeacherTest {

    //TestRail ID = C3109578
    func testAssignmentListPage_displaysPageObjects() {
        let course = openAssignmentListPage(self)
        assignmentListPage.assertPageObjects(course)
    }

/*
    //TestRail ID = C3134487
    func testAssignmentListPage_displaysNoAssignmentsView() {
        // not implemented on iOS yet.
    }
 */

    //TestRail ID = C3109578
    func testAssignmentListPage_displaysAssignment() {
        openAssignmentListPage(self)
        let assignment = Data.getNextAssignment(self)
        assignmentListPage.assertHasAssignment(assignment)
    }

    //TestRail ID = C3134488
    func testAssignmentListPage_displaysGradingPeriods() {
        openAssignmentListPage(self)
        let assignment = Data.getNextAssignment(self)
        assignmentListPage.assertHasGradingPeriods(assignment)
        
    }
}
