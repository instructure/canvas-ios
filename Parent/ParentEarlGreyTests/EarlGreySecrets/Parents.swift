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

//
// This is an auto-generated file.
//

// swiftlint:disable type_body_length
// swiftlint:disable file_length
class Parents {
    static var testCreateAccountPage: Parent {
    return Parent(parentId:   "df33cec5-87c1-4a74-89fa-540a91d0573e",
                  username:   "1487711568@ecdeb345-c92f-4340-b697-6e1e247a1b56.com",
                  password:   "a48d90c0c7b326d5",
                  firstName:  "Seamus",
                  lastName:   "Bayer",
                  students:   [],
                  thresholds: [],
                  alerts:     [])
    }

    static var testDashboardPage: Parent {
    return Parent(parentId:   "f8e98bfa-b13e-4f7e-a2b1-ccad54408f89",
                  username:   "1487711569@6452507a-67d9-4e00-8e67-f1a893491113.com",
                  password:   "929f8a3d7682b64d",
                  firstName:  "Casimer",
                  lastName:   "Champlin",
                  students:   [Students.testDashboardPage],
                  thresholds: [],
                  alerts:     [])
    }

    static var testForgotPasswordPage: Parent {
    return Parent(parentId:   "658dce06-9b59-472d-b7c9-0f69608a77e6",
                  username:   "1487711572@02539fde-a48b-4e9e-903d-76dd9237b2a4.com",
                  password:   "a413b415339a71e1",
                  firstName:  "Jordon",
                  lastName:   "Moore",
                  students:   [],
                  thresholds: [],
                  alerts:     [])
    }

    static var testHelpPage: Parent {
    return Parent(parentId:   "756ebfb8-1de6-4571-a588-260fae6299d7",
                  username:   "1487711572@6688fe8b-e8b9-465e-8358-d01a0b3b9196.com",
                  password:   "bf8d5c86d7d2dd17",
                  firstName:  "Guiseppe",
                  lastName:   "Trantow",
                  students:   [Students.testHelpPage],
                  thresholds: [],
                  alerts:     [])
    }

    static var testParentLoginPage: Parent {
    return Parent(parentId:   "008d31f8-d2f6-4134-a2c7-8e0b509bbd3f",
                  username:   "1487711574@bbd0b60c-748a-4c8b-8345-4c727bbde03b.com",
                  password:   "597f6a782fce6863",
                  firstName:  "Timothy",
                  lastName:   "Ebert",
                  students:   [],
                  thresholds: [],
                  alerts:     [])
    }

    static var testParentLoginPageWithoutStudents: Parent {
    return Parent(parentId:   "131dc66b-b612-49b4-8a41-9f7035d7b588",
                  username:   "1487711575@83960f73-c236-41fb-afce-4115c9fdd7c4.com",
                  password:   "495009eb972eb133",
                  firstName:  "Sterling",
                  lastName:   "Kautzer",
                  students:   [],
                  thresholds: [],
                  alerts:     [])
    }

    static var testParentLoginPageWithStudents: Parent {
    return Parent(parentId:   "d8bde6ee-3d72-4ae6-976b-604753aeaec4",
                  username:   "1487711575@1ab5cfe8-cd5d-449f-a9be-022a33952a5e.com",
                  password:   "d2d6f274f67fb5c3",
                  firstName:  "Haven",
                  lastName:   "Emard",
                  students:   [Students.testParentLoginPage],
                  thresholds: [],
                  alerts:     [])
    }

    static var testSettingsPage: Parent {
    return Parent(parentId:   "7d4a735c-720a-4229-b5c1-361f347fc4da",
                  username:   "1487711578@f750d68b-bf0e-4f8e-8398-79c6a7a5e8b9.com",
                  password:   "69c9227cc7b41d62",
                  firstName:  "Winnifred",
                  lastName:   "Rice",
                  students:   [Students.testSettingsPage],
                  thresholds: [],
                  alerts:     [])
    }

    static var testSettingsPageAddStudent: Parent {
    return Parent(parentId:   "4ba5599b-24c0-4510-9e79-a127461e8a40",
                  username:   "1487711581@f4852493-a18c-443d-a60e-bd4af79194d2.com",
                  password:   "1ed0dd86ce08abe1",
                  firstName:  "Celia",
                  lastName:   "Wilderman",
                  students:   [Students.testSettingsPageAddStudent],
                  thresholds: [],
                  alerts:     [])
    }

    static var testThresholdsPage: Parent {
    return Parent(parentId:   "c4222b09-4618-4e55-890e-d744701e0c74",
                  username:   "1487711583@8522f3c2-ee08-482e-bdb5-98bf2226e72f.com",
                  password:   "bfea0b9da09e9bb3",
                  firstName:  "Juston",
                  lastName:   "Leffler",
                  students:   [Students.testThresholdsPage],
                  thresholds: [],
                  alerts:     [])
    }

    static var testThresholdsPageSavesValues: Parent {
    return Parent(parentId:   "4ddaa032-e87a-4bfc-b105-d3ef3b03121b",
                  username:   "1487711585@872fd282-0ea0-4d05-a1fa-856088da2a06.com",
                  password:   "686ac954cf410bd4",
                  firstName:  "Sarah",
                  lastName:   "Blick",
                  students:   [Students.testThresholdsPageSavesValues],
                  thresholds: [],
                  alerts:     [])
    }

    static var testThresholdsPageLoadsValues: Parent {
        let thresholds: [AlertThreshold] = [AlertThreshold(student: Students.testThresholdsPageLoadsValues,
                                                           alertType: "assignment_grade_high",
                                                           threshold: "97"),
                                            AlertThreshold(student: Students.testThresholdsPageLoadsValues,
                                                           alertType: "assignment_grade_low",
                                                           threshold: "26"),
                                            AlertThreshold(student: Students.testThresholdsPageLoadsValues,
                                                           alertType: "assignment_missing",
                                                           threshold: ""),
                                            AlertThreshold(student: Students.testThresholdsPageLoadsValues,
                                                           alertType: "course_announcement",
                                                           threshold: ""),
                                            AlertThreshold(student: Students.testThresholdsPageLoadsValues,
                                                           alertType: "course_grade_high",
                                                           threshold: "70"),
                                            AlertThreshold(student: Students.testThresholdsPageLoadsValues,
                                                           alertType: "course_grade_low",
                                                           threshold: "40"),
                                            AlertThreshold(student: Students.testThresholdsPageLoadsValues,
                                                           alertType: "institution_announcement",
                                                           threshold: "")]
    return Parent(parentId:   "1d8259c5-c838-4d03-8f5f-984acd199e06",
                  username:   "1487711587@4e623a8d-55fd-4a0d-b5d9-a215e20b167d.com",
                  password:   "ea2f5861438ccb88",
                  firstName:  "Casandra",
                  lastName:   "Welch",
                  students:   [Students.testThresholdsPageLoadsValues],
                  thresholds: thresholds,
                  alerts:     [])
    }

    static var testThresholdsPageRemoveOnlyStudent: Parent {
    return Parent(parentId:   "84e2894c-2252-4191-9bbb-1b3ab006ffa0",
                  username:   "1487711591@4ef9c17c-277a-4332-a410-42b088e76b7c.com",
                  password:   "840a307ef1df8487",
                  firstName:  "Sherman",
                  lastName:   "Reilly",
                  students:   [Students.testThresholdsPageRemoveOnlyStudent],
                  thresholds: [],
                  alerts:     [])
    }

    static var testThresholdsPageRemoveOneStudent: Parent {
    return Parent(parentId:   "ed0fd3d5-cd8d-4f22-89a3-5a00ede0ab7c",
                  username:   "1487711592@75f87483-5441-47c1-876c-74b97bba3204.com",
                  password:   "c3421c5c010dce85",
                  firstName:  "Nakia",
                  lastName:   "Hahn",
                  students:   [Students.testThresholdsPageRemoveOneStudent1,
                               Students.testThresholdsPageRemoveOneStudent2],
                  thresholds: [],
                  alerts:     [])
    }

    static var testThresholdsPageBelowConstraints: Parent {
    return Parent(parentId:   "23ec10ec-5e39-4683-b1f9-313a24bf74ed",
                  username:   "1487711598@b5ed33a4-4ec8-4cef-ab15-924b52a4b185.com",
                  password:   "f6d1451ac83765e2",
                  firstName:  "Milton",
                  lastName:   "Veum",
                  students:   [Students.testThresholdsPageBelowConstraints],
                  thresholds: [],
                  alerts:     [])
    }

    static var testThresholdsPageAboveConstraints: Parent {
    return Parent(parentId:   "125468f1-61c3-4392-88a0-c5bff4d57018",
                  username:   "1487711600@a832bfc7-f654-4a16-a94f-d1952148e1a2.com",
                  password:   "0e871bf3aed57df2",
                  firstName:  "Braeden",
                  lastName:   "Kuhn",
                  students:   [Students.testThresholdsPageAboveConstraints],
                  thresholds: [],
                  alerts:     [])
    }

}
