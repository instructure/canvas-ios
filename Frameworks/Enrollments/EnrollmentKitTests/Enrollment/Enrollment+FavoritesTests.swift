//
//  Enrollment+FavoritesTests.swift
//  Enrollments
//
//  Created by Egan Anderson on 7/1/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import XCTest
@testable import EnrollmentKit
import TooLegit
import CoreData
import SoAutomated
import SoPersistent

class EnrollmentFavoritesTests: UnitTestCase {
    let session = Session.art
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        attempt {
            context = try session.enrollmentManagedObjectContext()
        }
    }
    
    // MARK: allCourses, allGroups
    
    func testEnrollment_allCourses_sortsByNameThenByID() {
        let first = Course.build(inSession: session) {
            $0.name = "A"
            $0.id = "1"
        }
        let second = Course.build(inSession: session) {
            $0.name = "B"
            $0.id = "2"
        }
        let third = Course.build(inSession: session) {
            $0.name = "B"
            $0.id = "3"
        }
        
        let collection = try! Enrollment.allCourses(session)
        XCTAssert(collection[0, 0] === first)
        XCTAssert(collection[0, 1] === second)
        XCTAssert(collection[0, 2] === third)
    }
    
    func testEnrollment_allGroups_sortsByNameThenByID() {
        let first = Group.build(inSession: session) {
            $0.name = "A"
            $0.id = "1"
        }
        let second = Group.build(inSession: session) {
            $0.name = "B"
            $0.id = "2"
        }
        let third = Group.build(inSession: session) {
            $0.name = "B"
            $0.id = "3"
        }
        
        let collection = try! Enrollment.allGroups(session)
        XCTAssert(collection[0, 0] === first)
        XCTAssert(collection[0, 1] === second)
        XCTAssert(collection[0, 2] === third)
    }
    
    // MARK: colorfulFavoriteViewModel
    
    func testColorfulFavoriteViewModel() {
        let enrollment = Group.build(inSession: session) {
            $0.name = "A"
            $0.id = "1"
        }
        let vm = colorfulFavoriteViewModel(enrollment)
        XCTAssertEqual(enrollment.name, vm.title.value)
        XCTAssertEqual(enrollment.shortName, vm.detail.value)
        XCTAssertEqual(enrollment.color, vm.color.value)
    }
}
