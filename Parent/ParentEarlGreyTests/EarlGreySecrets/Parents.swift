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
    static var withNoStudentsDomainPickerPage: Parent {
    return Parent(parentId:   "09aef9a6-1d20-4caf-a618-762544d77bca",
                  username:   "1485880616@98c80e2f-3825-48be-9443-be5e7c6b2d96.com",
                  password:   "13290e46f2d1fdb8",
                  firstName:  "Morton",
                  lastName:   "Prosacco",
                  students:   [],
                  thresholds: [],
                  alerts:     [])
    }

    static var whoForgotPasswordPage: Parent {
    return Parent(parentId:   "ae8ba2ef-2cc5-420a-b9a9-7faa0efae53a",
                  username:   "1485880616@5b288681-3639-4145-a71a-a5a8f5492b42.com",
                  password:   "5739e9a5aa5e48c5",
                  firstName:  "Emmet",
                  lastName:   "Casper",
                  students:   [],
                  thresholds: [],
                  alerts:     [])
    }

    static var withNoStudentsGettingStartedPage: Parent {
    return Parent(parentId:   "7f93bd31-afa5-4098-b036-e47c97e12d2a",
                  username:   "1485880616@99f251b4-b1e7-469f-9dc1-05fe6735cb0e.com",
                  password:   "bc98fe13e0e86bbd",
                  firstName:  "Jaydon",
                  lastName:   "Bogisich",
                  students:   [],
                  thresholds: [],
                  alerts:     [])
    }

    static var withOneStudentSettingsPage: Parent {
    return Parent(parentId:   "65f02783-2640-42db-9f5f-c13dac16aba3",
                  username:   "1485880616@e49a0b28-bef6-4643-af0e-cbf5e5ec8970.com",
                  password:   "e76a545075b002c4",
                  firstName:  "Astrid",
                  lastName:   "Kohler",
                  students:   [Students.withNoCoursesSettingsPage],
                  thresholds: [],
                  alerts:     [])
    }

    static var withOneStudentDashboardPage: Parent {
    return Parent(parentId:   "f1c719b8-48c5-47c0-8157-63c87128ed7b",
                  username:   "1485880626@e81304c6-5935-4924-acda-9269dba6eac1.com",
                  password:   "4800a29477debc88",
                  firstName:  "Kasey",
                  lastName:   "Pollich",
                  students:   [Students.withNoCoursesDashboardPage],
                  thresholds: [],
                  alerts:     [])
    }

    static var withStudentWithNoCoursesCoursesTabPage: Parent {
    return Parent(parentId:   "4cf95f70-826b-44a2-8093-15e13a1a4748",
                  username:   "1485880696@9f91b69c-f64c-4fdf-8ae4-57b3ef92372e.com",
                  password:   "7db18ef96b515aa1",
                  firstName:  "Angelica",
                  lastName:   "Kassulke",
                  students:   [Students.withNoCoursesCoursesTabPage],
                  thresholds: [],
                  alerts:     [])
    }

    static var withStudentWithOneCourseCoursesTabPage: Parent {
    return Parent(parentId:   "9c1ebec1-d31c-4230-939c-e5004cdaa805",
                  username:   "1485880700@d53e1b1a-3dca-4b2d-860c-697418c640fd.com",
                  password:   "8956bf4aaa17525f",
                  firstName:  "Janiya",
                  lastName:   "O&#39;Conner",
                  students:   [Students.withOneCourseCoursesTabPage],
                  thresholds: [],
                  alerts:     [])
    }

    static var withStudentWithNoCoursesWeekTabPagee: Parent {
    return Parent(parentId:   "1e1058ad-ebbe-4a53-8532-fbab95abbdb0",
                  username:   "1485880704@e50aa881-85a3-4404-8a84-53071b63b2ba.com",
                  password:   "115583fdd9895745",
                  firstName:  "Sister",
                  lastName:   "Hessel",
                  students:   [Students.withNoCoursesWeekTabPage],
                  thresholds: [],
                  alerts:     [])
    }

    static var withStudentWithNoCoursesAlertsTabPage: Parent {
    return Parent(parentId:   "63d18fc0-5f18-45b0-89b2-fe0f8398e46d",
                  username:   "1485880705@1698cd14-8368-4009-a0e4-e2e4c57dba73.com",
                  password:   "d35985516f9e1bab",
                  firstName:  "Maxime",
                  lastName:   "Baumbach",
                  students:   [Students.withNoCoursesAlertsTabPage],
                  thresholds: [],
                  alerts:     [])
    }

    static var whoHasStudentToRemove: Parent {
    return Parent(parentId:   "49ca07f8-1bb8-456a-880a-ba28f254a8f1",
                  username:   "1485880707@e226236f-6416-469f-830c-1fe5fa20a325.com",
                  password:   "28600d99223b0e71",
                  firstName:  "Verdie",
                  lastName:   "Stokes",
                  students:   [Students.whenRemovedRoutesToAddStudentPage],
                  thresholds: [],
                  alerts:     [])
    }

    static var whoHasManyStudentsToRemove: Parent {
    return Parent(parentId:   "c253fe00-abc8-4f7f-950f-f6216ff08990",
                  username:   "1485880710@7b13d89a-92c0-44db-bf48-035c9747c935.com",
                  password:   "e74f6b5e50cd2e3d",
                  firstName:  "Orval",
                  lastName:   "Lakin",
                  students:   [Students.whoCanBeRemoved1,
                               Students.whoCanBeRemoved2],
                  thresholds: [],
                  alerts:     [])
    }

    static var whoHasStudentWithNoThresholds: Parent {
    return Parent(parentId:   "df92bf87-494f-4b87-8557-2d182406d8e2",
                  username:   "1485880713@bf3c550b-7cbe-47a6-a28e-2b2d98d063ed.com",
                  password:   "d3f419cdc8592fd1",
                  firstName:  "Larue",
                  lastName:   "Rowe",
                  students:   [Students.whoHasNoThresholds],
                  thresholds: [],
                  alerts:     [])
    }

    static var whoHasStudentWithThresholds: Parent {
        let thresholds: [AlertThreshold] = [AlertThreshold(student: Students.whoHasThresholds,
                                                           alertType: "assignment_grade_high",
                                                           threshold: "95"),
                                            AlertThreshold(student: Students.whoHasThresholds,
                                                           alertType: "assignment_grade_low",
                                                           threshold: "65"),
                                            AlertThreshold(student: Students.whoHasThresholds,
                                                           alertType: "assignment_missing",
                                                           threshold: ""),
                                            AlertThreshold(student: Students.whoHasThresholds,
                                                           alertType: "course_announcement",
                                                           threshold: ""),
                                            AlertThreshold(student: Students.whoHasThresholds,
                                                           alertType: "course_grade_high",
                                                           threshold: "90"),
                                            AlertThreshold(student: Students.whoHasThresholds,
                                                           alertType: "course_grade_low",
                                                           threshold: "75"),
                                            AlertThreshold(student: Students.whoHasThresholds,
                                                           alertType: "institution_announcement",
                                                           threshold: "")]
    return Parent(parentId:   "6d98469b-08b4-40c8-a665-ce88c624e748",
                  username:   "1485880715@d3bcb0b5-4a65-4b6f-b07c-06bd31115381.com",
                  password:   "0d746e481abc829a",
                  firstName:  "Sigmund",
                  lastName:   "Muller",
                  students:   [Students.whoHasThresholds],
                  thresholds: thresholds,
                  alerts:     [])
    }

    static var whoChecksThresholdsErrors: Parent {
    return Parent(parentId:   "c008fcf2-6414-4802-a742-9d8479cfefa2",
                  username:   "1485880719@4e5c771b-dba9-4696-bf1f-7eeec0dfc743.com",
                  password:   "396b42a427d33f8c",
                  firstName:  "Jessie",
                  lastName:   "Ortiz",
                  students:   [Students.whoChecksThresholdsErrors],
                  thresholds: [],
                  alerts:     [])
    }

    static var testCreateAccountPage: Parent {
    return Parent(parentId:   "ae771bbb-24a6-4e84-9575-e1aa9f9b40bb",
                  username:   "1485880721@cca05cca-0d10-4e08-b736-1c8601a1e351.com",
                  password:   "f2ee0ef15d4358bc",
                  firstName:  "Norris",
                  lastName:   "Schaden",
                  students:   [],
                  thresholds: [],
                  alerts:     [])
    }

    static var testDashboardPage: Parent {
    return Parent(parentId:   "a7c15e9e-4f9f-420d-b429-b501df6ce209",
                  username:   "1485880721@cf41a8ec-5e01-41bd-8623-01e0ebb59b71.com",
                  password:   "7a71ad9f0c1e4207",
                  firstName:  "Kattie",
                  lastName:   "Morissette",
                  students:   [],
                  thresholds: [],
                  alerts:     [])
    }

    static var testForgotPasswordPage: Parent {
    return Parent(parentId:   "d955dcc2-7dd0-4b67-b639-863929a73e1f",
                  username:   "1485880721@192c222c-1538-4f89-b025-325a59e9cbff.com",
                  password:   "f94a4119e0994aa0",
                  firstName:  "Vladimir",
                  lastName:   "Blick",
                  students:   [],
                  thresholds: [],
                  alerts:     [])
    }

    static var testHelpPage: Parent {
    return Parent(parentId:   "1930a5e0-3d3e-40f8-b4a4-2da5256d7f6f",
                  username:   "1485880721@dabf15f0-affc-4a5c-83f0-6150e40112d9.com",
                  password:   "022215a78e7d2955",
                  firstName:  "Khalil",
                  lastName:   "Lakin",
                  students:   [Students.testHelpPage],
                  thresholds: [],
                  alerts:     [])
    }

    static var testParentLoginPageWithoutStudents: Parent {
    return Parent(parentId:   "e92ebe2a-59b4-41aa-94a2-ef4889d4207e",
                  username:   "1485880723@a477dccf-9697-4319-80b0-ce33babf142e.com",
                  password:   "3a95cc0eb6a7a1d9",
                  firstName:  "Mina",
                  lastName:   "Keeling",
                  students:   [],
                  thresholds: [],
                  alerts:     [])
    }

    static var testParentLoginPageWithStudents: Parent {
    return Parent(parentId:   "3140d362-d7f3-42ba-a5b6-4c099b9d8f4d",
                  username:   "1485880723@caef34de-94aa-45bf-adf4-536054991d5c.com",
                  password:   "3d8bdee5f46aada3",
                  firstName:  "Jeffrey",
                  lastName:   "Huels",
                  students:   [Students.testParentLoginPage],
                  thresholds: [],
                  alerts:     [])
    }

    static var testSettingsPage: Parent {
    return Parent(parentId:   "54345f9e-8cf5-4585-85db-546b017e850e",
                  username:   "1485880725@361f74a8-e175-476c-98c5-9015f0a15182.com",
                  password:   "487648212e9a2fd9",
                  firstName:  "Jerrod",
                  lastName:   "Rowe",
                  students:   [],
                  thresholds: [],
                  alerts:     [])
    }

    static var testSettingsPageAddStudent: Parent {
    return Parent(parentId:   "2869d214-f93f-4597-9f8c-e4a300bf0310",
                  username:   "1485880726@53d3ff09-adc1-455a-b45f-bf24accd6967.com",
                  password:   "2a8cefcae0830e4d",
                  firstName:  "Julien",
                  lastName:   "Klein",
                  students:   [],
                  thresholds: [],
                  alerts:     [])
    }

    static var testThresholdsPage: Parent {
    return Parent(parentId:   "f8b4dbda-6b27-448c-90ee-df0e0f0227ba",
                  username:   "1485880726@3c4a5e8c-5a62-461f-870c-3acfb1a813eb.com",
                  password:   "1a74e6608371c134",
                  firstName:  "Noble",
                  lastName:   "Zulauf",
                  students:   [Students.testThresholdsPage],
                  thresholds: [],
                  alerts:     [])
    }

    static var testThresholdsPageSavesValues: Parent {
    return Parent(parentId:   "5c5db19e-042c-4128-9f3f-4168071361fc",
                  username:   "1485880728@4a9f7b16-3493-49a1-8079-deab592b6ba2.com",
                  password:   "5935279d87cfeba4",
                  firstName:  "Zetta",
                  lastName:   "Wintheiser",
                  students:   [Students.testThresholdsPageSavesValues],
                  thresholds: [],
                  alerts:     [])
    }

    static var testThresholdsPageLoadsValues: Parent {
        let thresholds: [AlertThreshold] = [AlertThreshold(student: Students.testThresholdsPageLoadsValues,
                                                           alertType: "assignment_grade_high",
                                                           threshold: "95"),
                                            AlertThreshold(student: Students.testThresholdsPageLoadsValues,
                                                           alertType: "assignment_grade_low",
                                                           threshold: "65"),
                                            AlertThreshold(student: Students.testThresholdsPageLoadsValues,
                                                           alertType: "assignment_missing",
                                                           threshold: ""),
                                            AlertThreshold(student: Students.testThresholdsPageLoadsValues,
                                                           alertType: "course_announcement",
                                                           threshold: ""),
                                            AlertThreshold(student: Students.testThresholdsPageLoadsValues,
                                                           alertType: "course_grade_high",
                                                           threshold: "90"),
                                            AlertThreshold(student: Students.testThresholdsPageLoadsValues,
                                                           alertType: "course_grade_low",
                                                           threshold: "75"),
                                            AlertThreshold(student: Students.testThresholdsPageLoadsValues,
                                                           alertType: "institution_announcement",
                                                           threshold: "")]
    return Parent(parentId:   "f5145de9-c0b9-4cef-9976-a44c49a6e0b3",
                  username:   "1485880730@86810ac4-33f9-445d-804a-4213b954f29f.com",
                  password:   "9496415cf28c65c8",
                  firstName:  "Mauricio",
                  lastName:   "Smitham",
                  students:   [Students.testThresholdsPageLoadsValues],
                  thresholds: thresholds,
                  alerts:     [])
    }

    static var testThresholdsPageRemoveOnlyStudent: Parent {
    return Parent(parentId:   "976dd38c-cf83-4503-ae5b-ba69c99dec1c",
                  username:   "1485880734@69030eb8-855b-48ad-99ec-cb527a1571b2.com",
                  password:   "5073dea943419510",
                  firstName:  "Wade",
                  lastName:   "Trantow",
                  students:   [Students.testThresholdsPageRemoveOnlyStudent],
                  thresholds: [],
                  alerts:     [])
    }

    static var testThresholdsPageRemoveOneStudent: Parent {
    return Parent(parentId:   "6ab1a3b2-dd25-419c-93be-c253db78a53a",
                  username:   "1485880736@d3a35ad9-91e0-47a9-94f9-2b03ffcf50cb.com",
                  password:   "dabc0f884a523d6b",
                  firstName:  "Brannon",
                  lastName:   "Stracke",
                  students:   [Students.testThresholdsPageRemoveOneStudent1,
                               Students.testThresholdsPageRemoveOneStudent2],
                  thresholds: [],
                  alerts:     [])
    }

    static var testThresholdsPageConstraints: Parent {
    return Parent(parentId:   "c5ddfc65-b680-44e5-a14b-dc9b1502ada8",
                  username:   "1485880741@9dae4b96-afcb-4eee-9176-0818cc1b3494.com",
                  password:   "685facdf4be5c4df",
                  firstName:  "Granville",
                  lastName:   "Mante",
                  students:   [Students.testThresholdsPageConstraints],
                  thresholds: [],
                  alerts:     [])
    }

}
