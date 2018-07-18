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

import Foundation
import SwiftGRPC
import SwiftProtobuf
import CanvasCore

let hostname = "soseedy.endpoints.delta-essence-114723.cloud.goog"
let address = "\(hostname):80"
let apiKey = Secrets.fetch(.gRPCSoSeedyAPIKey)!

func makeClient<T: ServiceClientBase >(_ client: T.Type) -> T {
  let client = client.init(address: address,
                     certificates: Certs.caCert,
                     clientCertificates: Certs.clientCert,
                     clientKey: Certs.clientPrivateKey,
                     arguments: [.sslTargetNameOverride("example.com")])
  try! client.metadata.add(key: "x-api-key", value: apiKey)
  client.host = hostname
  client.timeout = 5 * 60

  return client
}

let assignmentsClient = makeClient(Soseedy_SeedyAssignmentsServiceClient.self)
let conversationsClient = makeClient(Soseedy_SeedyConversationsServiceClient.self)
let coursesClient = makeClient(Soseedy_SeedyCoursesServiceClient.self)
let discussionsClient = makeClient(Soseedy_SeedyDiscussionsServiceClient.self)
let enrollmentsClient = makeClient(Soseedy_SeedyEnrollmentsServiceClient.self)
let filesClient = makeClient(Soseedy_SeedyFilesServiceClient.self)
let generalClient = makeClient(Soseedy_SeedyGeneralServiceClient.self)
let gradingPeriodsClient = makeClient(Soseedy_SeedyGradingPeriodsServiceClient.self)
let groupsClient = makeClient(Soseedy_SeedyGroupsServiceClient.self)
let pagesClient = makeClient(Soseedy_SeedyPagesServiceClient.self)
let quizzesClient = makeClient(Soseedy_SeedyQuizzesServiceClient.self)
let sectionsClient = makeClient(Soseedy_SeedySectionsServiceClient.self)
let usersClient = makeClient(Soseedy_SeedyUsersServiceClient.self)

// This function should wrap any calls made to data seeding methods on the above clients
// It will use the request that is passed into it as the key for storing/finding recorded
// data seeding responses.
public func recorded<T: SwiftProtobuf.Message>(request: SwiftProtobuf.Message, block: () -> T) -> T {
    let requestKey = try! request.jsonString()
    let response: String? = VCR.shared().response(for: requestKey)
    if let response = response {
        return try! T(jsonString: response)
    }
    let blockResponse = block()
    let blockResponseString = try! blockResponse.jsonString()
    VCR.shared().recordResponse(blockResponseString, for: requestKey)
    return blockResponse
}


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
    return recorded(request: enrollRequest) { try! enrollmentsClient.enrollUserInCourse(enrollRequest) }
}

public func enroll(_ user: Soseedy_CanvasUser, as type: EnrollmentType, inAll courses: [Soseedy_Course]) -> [Soseedy_Enrollment] {
    return courses.map { enroll(user, as: type, in: $0) }
}

public func createUser() -> Soseedy_CanvasUser {
    let createUserRequest = Soseedy_CreateCanvasUserRequest()
    return recorded(request: createUserRequest) { try! usersClient.createCanvasUser(createUserRequest) }
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

public func healthCheck() -> Soseedy_HealthCheck {
  return try! generalClient.getHealthCheck(Soseedy_HealthCheckRequest())
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
    let createCourseRequest = Soseedy_CreateCourseRequest()
    return recorded(request: createCourseRequest) { try! coursesClient.createCourse(createCourseRequest) }
}

@discardableResult public func favorite(_ course: Soseedy_Course, as user: Soseedy_CanvasUser) -> Soseedy_Favorite {
    var request = Soseedy_AddFavoriteCourseRequest()
    request.courseID = course.id
    request.token = user.token
    return recorded(request: request) { try! coursesClient.addFavoriteCourse(request) }
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
    return recorded(request: request) { try! assignmentsClient.createAssignment(request) }
}
