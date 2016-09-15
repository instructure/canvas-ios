//
//  Course+CollectionsTests.swift
//  Enrollments
//
//  Created by Nathan Armstrong on 5/30/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import XCTest
@testable import EnrollmentKit
import TooLegit
import CoreData
import SoAutomated
import SoPersistent

class CourseCollectionsTests: UnitTestCase {
    let session = Session.nas
    var context: NSManagedObjectContext!

    lazy var studentContext: String->NSManagedObjectContext = { studentID in
        var context: NSManagedObjectContext!
        self.attempt {
            context = try self.session.enrollmentManagedObjectContext(studentID)
        }
        return context
    }

    override func setUp() {
        super.setUp()
        attempt {
            context = try session.enrollmentManagedObjectContext()
        }
    }

    // MARK: allCoursesCollection

    func testCourse_allCoursesCollection_sortsByNameThenByID() {
        let first = Course.build(context, name: "A", id: "1")
        let second = Course.build(context, name: "B", id: "2")
        let third = Course.build(context, name: "B", id: "3")

        attempt {
            let collection = try Course.allCoursesCollection(session)
            XCTAssertEqual([first, second, third], collection.allObjects, "allCoursesCollection sorts by name then by id")
        }
    }

    // MARK: favoritesCollection

    func testCourse_favoritesCollection_includesCoursesWithIsFavoriteFlag() {
        let favorite = Course.build(context, isFavorite: true)
        attempt {
            let collection = try Course.favoritesCollection(session)
            XCTAssert(collection.contains(favorite), "favoritesCollection includes courses with isFavorite flag")
        }
    }

    func testCourse_favoritesCollection_excludesCoursesWithoutIsFavoriteFlag() {
        let nonFavorite = Course.build(context, isFavorite: false)
        attempt {
            let collection = try Course.favoritesCollection(session)
            XCTAssertFalse(collection.contains(nonFavorite), "favoritesCollection excludes courses with isFavorite flag")
        }
    }

    func testCourse_favoritesCollection_sortsByNameThenByID() {
        let first = Course.build(context, name: "A", id: "1", isFavorite: true)
        let second = Course.build(context, name: "B", id: "2", isFavorite: true)
        let third = Course.build(context, name: "B", id: "3", isFavorite: true)
        attempt {
            let collection = try Course.favoritesCollection(session)
            XCTAssertEqual([first, second, third], collection.allObjects, "favoritesCollection sorts by name then by id")
        }
    }

    // MARK: collectionByStudent

    func testCourse_collectionByStudent_includesCoursesInStudentContext() {
        let course = Course.build(studentContext("1"))
        attempt {
            let collection = try Course.collectionByStudent(session, studentID: "1")
            XCTAssert(collection.contains(course), "collectionByStudent includes courses in student context")
        }
    }

    func testCourse_collectionByStudent_excludesCoursesNotInStudentContext() {
        let course = Course.build(context)
        let other = Course.build(studentContext("2"))
        attempt {
            let collection = try Course.collectionByStudent(session, studentID: "1")
            XCTAssertFalse(collection.contains(course), "collectionByStudent excludes courses in regular context")
            XCTAssertFalse(collection.contains(other), "collectionByStudent excludes courses in other student contexts")
        }
    }

    func testCourse_collectionByStudent_sortsByNameThenByID() {
        let first = Course.build(studentContext("1"), name: "A", id: "1")
        let second = Course.build(studentContext("1"), name: "B", id: "2")
        let third = Course.build(studentContext("1"), name: "B", id: "3")
        attempt {
            let collection = try Course.collectionByStudent(session, studentID: "1")
            XCTAssertEqual([first, second, third], collection.allObjects, "collectionByStudent sorts by name then by id")
        }
    }

    // MARK: refresher

    func testCourse_refresher_syncsCourses() {
        attempt {
            let refresher = try Course.refresher(session)
            assertDifference({ Course.count(inContext: context) }, 3, "refresher syncs courses") {
                stub(session, "refresh-all-courses") { expectation in
                    refresher.refreshingCompleted.observeNext(self.refreshCompletedWithExpectation(expectation))
                    refresher.refresh(true)
                }
            }
        }
    }

    func testCourse_refresher_syncsFavoriteColors() {
        attempt {
            let course = Course.build(context, id: "24219", color: nil)
            try context.save()
            let refresher = try Course.refresher(session)
            stub(session, "refresh-all-courses") { expectation in
                refresher.refreshingCompleted.observeNext(self.refreshCompletedWithExpectation(expectation))
                refresher.refresh(true)
            }
            XCTAssertEqual("#009688", course.rawColor, "refresher syncs favorite colors")
        }
    }
}

class CourseTableViewControllerTests: UnitTestCase {
    let session = Session.nas
    let tvc = Course.TableViewController()
    let viewModelFactory = ViewModelFactory<Course>.new { _ in UITableViewCell() }

    func testTableViewController_prepare_setsCollection() {
        attempt {
            let collection = try Course.allCoursesCollection(session)
            tvc.prepare(collection, viewModelFactory: viewModelFactory)
            XCTAssertEqual(collection, tvc.collection, "prepare sets the collection")
        }
    }

    func testTableViewController_prepare_setsRefresher() {
        attempt {
            let collection = try Course.allCoursesCollection(session)
            let refresher = try Course.refresher(session)
            tvc.prepare(collection, refresher: refresher, viewModelFactory: viewModelFactory)
            XCTAssertNotNil(tvc.refresher, "prepare sets the refresher")
        }
    }

    func testTableViewController_prepare_setsDataSource() {
        attempt {
            let collection = try Course.allCoursesCollection(session)
            tvc.prepare(collection, viewModelFactory: viewModelFactory)
            XCTAssertNotNil(tvc.dataSource, "prepare sets the data source")
        }
    }
}
