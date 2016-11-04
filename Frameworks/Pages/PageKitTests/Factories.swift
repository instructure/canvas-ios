
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
            vm.tokenViewText.value = NSLocalizedString("Front Page", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.PageKit")!, value: "", comment: "badge indicating front page")
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
        let page = Page(inContext: context)
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