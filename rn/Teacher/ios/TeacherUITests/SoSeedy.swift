//
//  SoSeedy.swift
//  TeacherUITests
//
//  Created by Nathan Armstrong on 12/11/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import Foundation

let client = Soseedy_SoSeedyService(address: "localhost:50051")

// MARK: - Enrollments

@discardableResult func enroll(_ user: Soseedy_CanvasUser, as type: String, in course: Soseedy_Course) -> Soseedy_Enrollment {
    var enrollRequest = Soseedy_EnrollUserRequest()
    enrollRequest.courseID = course.id
    enrollRequest.userID = user.id
    enrollRequest.enrollmentType = type
    return try! client.enrolluserincourse(enrollRequest)
}

func createUser() -> Soseedy_CanvasUser {
    return try! client.createcanvasuser(Soseedy_CreateCanvasUserRequest())
}

func createTeacher(in course: Soseedy_Course = createCourse()) -> Soseedy_CanvasUser {
    let user = createUser()
    enroll(user, as: "TeacherEnrollment", in: course)
    return user
}

// MARK: - Courses

func createCourse() -> Soseedy_Course {
    return try! client.createcourse(Soseedy_CreateCourseRequest())
}

@discardableResult func favorite(_ course: Soseedy_Course, as user: Soseedy_CanvasUser) -> Soseedy_Favorite {
    var request = Soseedy_AddFavoriteCourseRequest()
    request.courseID = course.id
    request.token = user.token
    return try! client.addfavoritecourse(request)
}

// MARK: - Assignments

enum SubmissionType: String {
    case none = "none"
    case onPaper = "on_paper"
    case onlineTextEntry = "online_text_entry"
    case onlineURL = "online_url"
    case onlineUpload = "online_upload"
}

func createAssignment(for course: Soseedy_Course = createCourse(), as teacher: Soseedy_CanvasUser, withDescription: Bool = false, submissionTypes: [SubmissionType] = []) -> Soseedy_Assignment {
    var request = Soseedy_CreateAssignmentRequest()
    request.courseID = course.id
    request.teacherToken = teacher.token
    request.withDescription = withDescription
    request.submissionTypes = submissionTypes.map { $0.rawValue }
    return try! client.createassignment(request)
}
