//
//  DashboardPage.swift
//  SoGrey
//
//  Created by Layne Moseley on 4/11/18.
//  Copyright © 2018 Instructure. All rights reserved.
//

import Foundation

import EarlGrey
import SoSeedySwift

public class DashboardPage {
    
    public static let sharedInstance = DashboardPage()
    private init() {}
    
    // MARK: Elements
    
    private let feedbackButton = e.selectBy(id: "favorited-course-list.feedback-btn")
    private let editButton = e.selectBy(id: "dashboard.edit-btn")
    private let profileButton = e.selectBy(id: "favorited-course-list.profile-btn")
    private let headerStarImage = e.selectBy(id: "favorited-course-list.header-star-img")
    private let headerCoursesLabel = e.selectBy(id: "favorited-course-list.header-courses-lbl")
    private let seeAllCoursesButton = e.selectBy(id: "dashboard.courses.see-all-btn")
    private let pageView = e.selectBy(id: "favorited-course-list.view1")
    private let emptyStateWelcomeLabel = e.selectBy(id: "no-courses.welcome-lbl")
    private let emptyStateDescriptionLabel = e.selectBy(id: "no-courses.description-lbl")
    private let emptyStateAddCourseButton = e.selectBy(id: "no-courses.add-courses-btn")
    
    // MARK: - Helpers
    
    //    private func courseId(_ course: Course) -> String {
    //        return "course-card.kabob-\(course.id)"
    //    }
    
    private func courseCard(_ course: Soseedy_Course) -> GREYInteraction {
        return e.selectBy(id: "course-\(course.id)")
    }
    
    // MARK: - Assertions
    
    public func assertPageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        pageView.assertExists()
    }
    
    public func assertEmptyStatePageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        emptyStateWelcomeLabel.assertExists()
        emptyStateDescriptionLabel.assertExists()
        emptyStateAddCourseButton.assertExists()
    }
    
    public func assertHasFavoritesStatePageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        feedbackButton.assertExists()
        editButton.assertExists()
        headerStarImage.assertExists()
        headerCoursesLabel.assertExists()
        seeAllCoursesButton.assertExists()
    }
    
    public func assertCourseExists(_ course: Soseedy_Course, _ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        e.selectBy(id: "course-\(course.id)").assertExists()
    }
    
    public func assertCourseDoesNotExist(_ course: Soseedy_Course, _ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        e.selectBy(id: "course-\(course.id)").assertHidden()
    }
    
    // MARK: - UI Actions
    
    public func openCourseFavoritesEditPage(_ emptyState: Bool, file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        if emptyState {
            emptyStateAddCourseButton.tap()
        } else {
            editButton.tapUntilHidden()
        }
    }
    
    public func openAllCoursesPage(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        seeAllCoursesButton.tap()
    }
    
    public func openCourseDetailsPage(_ course: Soseedy_Course, _ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        courseCard(course).tap()
    }
    
    public func openProfile(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        profileButton.tap()
    }
}
