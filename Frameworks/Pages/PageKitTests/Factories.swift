//
//  Factories.swift
//  Pages
//
//  Created by Joseph Davison on 5/25/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import CoreData
@testable import PageKit
import TooLegit
import SoAutomated
import PageKit
import TooLegit
import SoPersistent
import ReactiveCocoa
import EnrollmentKit

extension Page {

    static func colorfulPageViewModel(session session: Session, page: Page) -> ColorfulViewModel {
        let vm = ColorfulViewModel(style: .Token)
        vm.title.value = page.title
        if page.frontPage {
            vm.tokenViewText.value = NSLocalizedString("Front Page", comment: "badge indicating front page")
        }
        vm.color <~ session.enrollmentsDataSource.producer(page.contextID)
            .map { $0?.color ?? .prettyGray() }

        return vm
    }

}

extension Page {
    static func build(context: NSManagedObjectContext,
                      url: String = "page",
                      title: String = "Page",
                      createdAt: NSDate = NSDate(),
                      updatedAt: NSDate = NSDate(),
                      editingRoles: String = "Teachers",
                      published: Bool = true,
                      frontPage: Bool = false,
                      contextID: ContextID = ContextID(id: "24601", context: .Course),
                      lockedForUser: Bool = false ) -> Page {
        let page = Page.create(inContext: context)
        page.url = url
        page.title = title
        page.createdAt = createdAt
        page.updatedAt = updatedAt
        page.editingRoles = editingRoles
        page.published = published
        page.frontPage = frontPage
        page.contextID = contextID
        page.lockedForUser = lockedForUser
        
        return page
    }
}

extension PagesHomeViewController {

    static func build(session: Session = Session.ivy,
                      contextID: ContextID = ContextID(id: "24601", context: .Course),
                      route: (UIViewController, NSURL) -> () = { _,_ in } ) throws -> PagesHomeViewController {
        return try PagesHomeViewController(session: session, contextID: contextID, listViewModelFactory: { session, page in return Page.colorfulPageViewModel(session: session, page: page) }, route: route)
    }

}

extension Page.TableViewController {

    static func build(session: Session = Session.ivy,
                      contextID: ContextID = ContextID(canvasContext: "course_24601")!,
                      route: (UIViewController, NSURL) -> () = { _,_ in } ) throws -> Page.TableViewController {
        return try Page.TableViewController(session: session, contextID: contextID, viewModelFactory: { session, page in return Page.colorfulPageViewModel(session: session, page: page) }, route: route)
    }

}

extension Page.DetailViewController {

    static func build(session: Session = Session.ivy,
                      contextID: ContextID = ContextID(id: "24601", context: .Course),
                      url: String = "test-page",
                      route: (UIViewController, NSURL) -> () = {_, _ in } ) throws -> Page.DetailViewController {
        return try Page.DetailViewController(session: session, contextID: contextID, url: url, route: route)
    }

}