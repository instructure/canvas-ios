//
//  SoSeedy.swift
//  TeacherUITests
//
//  Created by Nathan Armstrong on 12/11/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import Foundation

let client = Soseedy_SoSeedyService(address: "localhost:50051")

@discardableResult func enroll(_ user: Soseedy_CanvasUser, as type: String, in course: Soseedy_Course) -> Soseedy_Enrollment {
    var enrollRequest = Soseedy_EnrollUserRequest()
    enrollRequest.courseID = course.id
    enrollRequest.userID = user.id
    enrollRequest.enrollmentType = type
    return try! client.enrolluserincourse(enrollRequest)
}

func createCourse() -> Soseedy_Course {
    return try! client.createcourse(Soseedy_CreateCourseRequest())
}

func createUser() -> Soseedy_CanvasUser {
    return try! client.createcanvasuser(Soseedy_CreateCanvasUserRequest())
}

func teacher(course: Soseedy_Course = createCourse()) -> Soseedy_CanvasUser {
    let user = createUser()
    enroll(user, as: "TeacherEnrollment", in: course)
    return user
}
