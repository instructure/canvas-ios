//
//  SoSeedy.swift
//  TeacherUITests
//
//  Created by Nathan Armstrong on 12/11/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import Foundation

let address = "localhost:50051"
let secure = false
let assignmentsClient = Soseedy_SeedyAssignmentsService(address: address, secure: secure)
let conversationsClient = Soseedy_SeedyConversationsService(address: address, secure: secure)
let coursesClient = Soseedy_SeedyCoursesService(address: address, secure: secure)
let discussionsClient = Soseedy_SeedyDiscussionsService(address: address, secure: secure)
let enrollmentsClient = Soseedy_SeedyEnrollmentsService(address: address, secure: secure)
let filesClient = Soseedy_SeedyFilesService(address: address, secure: secure)
let generalClient = Soseedy_SeedyGeneralService(address: address, secure: secure)
let gradingPeriodsClient = Soseedy_SeedyGradingPeriodsService(address: address, secure: secure)
let groupsClient = Soseedy_SeedyGroupsService(address: address, secure: secure)
let pagesClient = Soseedy_SeedyPagesService(address: address, secure: secure)
let quizzesClient = Soseedy_SeedyQuizzesService(address: address, secure: secure)
let sectionsClient = Soseedy_SeedySectionsService(address: address, secure: secure)
let usersClient = Soseedy_SeedyUsersService(address: address, secure: secure)

// MARK: - Enrollments

enum EnrollmentType: String {
    case teacher = "TeacherEnrollment"
}

@discardableResult func enroll(_ user: Soseedy_CanvasUser, as type: EnrollmentType, in course: Soseedy_Course) -> Soseedy_Enrollment {
    var enrollRequest = Soseedy_EnrollUserRequest()
    enrollRequest.courseID = course.id
    enrollRequest.userID = user.id
    enrollRequest.enrollmentType = type.rawValue
    return try! enrollmentsClient.enrolluserincourse(enrollRequest)
}

func enroll(_ user: Soseedy_CanvasUser, as type: EnrollmentType, inAll courses: [Soseedy_Course]) -> [Soseedy_Enrollment] {
    return courses.map { enroll(user, as: type, in: $0) }
}

func createUser() -> Soseedy_CanvasUser {
    return try! usersClient.createcanvasuser(Soseedy_CreateCanvasUserRequest())
}

func createTeacher(in course: Soseedy_Course = createCourse()) -> Soseedy_CanvasUser {
    let user = createUser()
    enroll(user, as: .teacher, in: course)
    return user
}

func createTeacher(inAll courses: [Soseedy_Course]) -> Soseedy_CanvasUser {
    let user = createUser()
    courses.forEach { enroll(user, as: .teacher, in: $0) }
    return user
}

// MARK: - Courses

@discardableResult func createCourse() -> Soseedy_Course {
    return try! coursesClient.createcourse(Soseedy_CreateCourseRequest())
}

@discardableResult func favorite(_ course: Soseedy_Course, as user: Soseedy_CanvasUser) -> Soseedy_Favorite {
    var request = Soseedy_AddFavoriteCourseRequest()
    request.courseID = course.id
    request.token = user.token
    return try! coursesClient.addfavoritecourse(request)
}

// MARK: - Assignments

enum SubmissionType: String {
    case none = "none"
    case onPaper = "on_paper"
    case onlineTextEntry = "online_text_entry"
    case onlineURL = "online_url"
    case onlineUpload = "online_upload"
}

func createAssignment(for course: Soseedy_Course = createCourse(), as teacher: Soseedy_CanvasUser, withDescription: Bool = false, submissionTypes: [Soseedy_SubmissionType] = []) -> Soseedy_Assignment {
    var request = Soseedy_CreateAssignmentRequest()
    request.courseID = course.id
    request.teacherToken = teacher.token
    request.withDescription = withDescription
    request.submissionTypes = submissionTypes
    return try! assignmentsClient.createassignment(request)
}
