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

import Foundation

let address = "localhost:50051"
let secure = false
let assignmentsClient = Soseedy_SeedyAssignmentsServiceClient(address: address, secure: secure)
let conversationsClient = Soseedy_SeedyConversationsServiceClient(address: address, secure: secure)
let coursesClient = Soseedy_SeedyCoursesServiceClient(address: address, secure: secure)
let discussionsClient = Soseedy_SeedyDiscussionsServiceClient(address: address, secure: secure)
let enrollmentsClient = Soseedy_SeedyEnrollmentsServiceClient(address: address, secure: secure)
let filesClient = Soseedy_SeedyFilesServiceClient(address: address, secure: secure)
let generalClient = Soseedy_SeedyGeneralServiceClient(address: address, secure: secure)
let gradingPeriodsClient = Soseedy_SeedyGradingPeriodsServiceClient(address: address, secure: secure)
let groupsClient = Soseedy_SeedyGroupsServiceClient(address: address, secure: secure)
let pagesClient = Soseedy_SeedyPagesServiceClient(address: address, secure: secure)
let quizzesClient = Soseedy_SeedyQuizzesServiceClient(address: address, secure: secure)
let sectionsClient = Soseedy_SeedySectionsServiceClient(address: address, secure: secure)
let usersClient = Soseedy_SeedyUsersServiceClient(address: address, secure: secure)

// MARK: - Enrollments

public enum EnrollmentType: String {
    case teacher = "TeacherEnrollment"
    case student = "StudentEnrollment"
}

@discardableResult public func enroll(_ user: Soseedy_CanvasUser, as type: EnrollmentType, in course: Soseedy_Course) -> Soseedy_Enrollment {
    var enrollRequest = Soseedy_EnrollUserRequest()
    enrollRequest.courseID = course.id
    enrollRequest.userID = user.id
    enrollRequest.enrollmentType = type.rawValue
    return try! enrollmentsClient.enrollUserInCourse(enrollRequest)
}

public func enroll(_ user: Soseedy_CanvasUser, as type: EnrollmentType, inAll courses: [Soseedy_Course]) -> [Soseedy_Enrollment] {
    return courses.map { enroll(user, as: type, in: $0) }
}

public func createUser() -> Soseedy_CanvasUser {
    return try! usersClient.createCanvasUser(Soseedy_CreateCanvasUserRequest())
}

public func createStudent(in course: Soseedy_Course = createCourse()) -> Soseedy_CanvasUser {
    let user = createUser()
    enroll(user, as: .student, in: course)
    return user
}

public func createStudent(inAll courses: [Soseedy_Course]) -> Soseedy_CanvasUser {
    let user = createUser()
    courses.forEach { enroll(user, as: .teacher, in: $0) }
    return user
}

public func createTeacher(in course: Soseedy_Course = createCourse()) -> Soseedy_CanvasUser {
    let user = createUser()
    enroll(user, as: .teacher, in: course)
    return user
}

public func createTeacher(inAll courses: [Soseedy_Course]) -> Soseedy_CanvasUser {
    let user = createUser()
    courses.forEach { enroll(user, as: .teacher, in: $0) }
    return user
}

// Takes a CanvasUser object and converts it into a hash for NativeLogin
public func getNativeLoginInfo(_ canvasUser:Soseedy_CanvasUser) -> [String: Any] {
    let user: [String: Any] = [
        "id":            canvasUser.id,
        "name":          canvasUser.name,
        "primary_email": canvasUser.loginID,
        "short_name":    canvasUser.shortName,
        "avatar_url":    canvasUser.avatarURL
    ]
    
    let baseURL = "https://\(canvasUser.domain)/"
    let authToken = canvasUser.token
    let loginInfo: [String: Any] = [
        "authToken": authToken,
        "baseURL": baseURL,
        "user": user
    ]
    
    return loginInfo
}

// MARK: - Courses

@discardableResult public func createCourse() -> Soseedy_Course {
    return try! coursesClient.createCourse(Soseedy_CreateCourseRequest())
}

@discardableResult public func favorite(_ course: Soseedy_Course, as user: Soseedy_CanvasUser) -> Soseedy_Favorite {
    var request = Soseedy_AddFavoriteCourseRequest()
    request.courseID = course.id
    request.token = user.token
    return try! coursesClient.addFavoriteCourse(request)
}

// MARK: - Assignments

public enum SubmissionType: String {
    case none = "none"
    case onPaper = "on_paper"
    case onlineTextEntry = "online_text_entry"
    case onlineURL = "online_url"
    case onlineUpload = "online_upload"
}

public func createAssignment(for course: Soseedy_Course = createCourse(), as teacher: Soseedy_CanvasUser, withDescription: Bool = false, submissionTypes: [Soseedy_SubmissionType] = []) -> Soseedy_Assignment {
    var request = Soseedy_CreateAssignmentRequest()
    request.courseID = course.id
    request.teacherToken = teacher.token
    request.withDescription = withDescription
    request.submissionTypes = submissionTypes
    return try! assignmentsClient.createAssignment(request)
}
