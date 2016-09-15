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
        let first = Course.build(context, name: "A", id: "1")
        let second = Course.build(context, name: "B", id: "2")
        let third = Course.build(context, name: "B", id: "3")
        
        attempt {
            let collection = try Enrollment.allCourses(session)
            XCTAssertEqual([first, second, third], collection.allObjects, "allCoursesCollection sorts by name then by id")
        }
    }
    
    func testEnrollment_allGroups_sortsByNameThenByID() {
        let first = Group.build(context, name: "A", id: "1")
        let second = Group.build(context, name: "B", id: "2")
        let third = Group.build(context, name: "B", id: "3")
        
        attempt {
            let collection = try Enrollment.allGroups(session)
            XCTAssertEqual([first, second, third], collection.allObjects, "allCoursesCollection sorts by name then by id")
        }
    }
    
    // MARK: colorfulFavoriteViewModel
    
    func testColorfulFavoriteViewModel() {
        let enrollment = Group.build(context, name: "A", id: "1")
        let vm = colorfulFavoriteViewModel(enrollment)
        XCTAssertEqual(enrollment.name, vm.title.value)
        XCTAssertEqual(enrollment.shortName, vm.detail.value)
        XCTAssertEqual(enrollment.color, vm.color.value)
    }
}