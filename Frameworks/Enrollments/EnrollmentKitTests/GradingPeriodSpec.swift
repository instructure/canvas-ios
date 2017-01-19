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
    
    

@testable import EnrollmentKit
import SoAutomated
import Quick
import Nimble

class GradingPeriodSpec: QuickSpec {
    override func spec() {
        describe("Grading Period") {
            describe("TableViewController") {
                var tableViewController: GradingPeriod.TableViewController!
                beforeEach {
                    let user = User(credentials: .user1)
                    let session = user.session
                    let course = Course.build(inSession: session) { $0.id = "1811031" }
                    let gradingPeriods = try! GradingPeriod.collectionByCourseID(session, courseID: course.id)
                    let collection = GradingPeriodCollection(course: course, gradingPeriods: gradingPeriods)
                    let refresher = EmptyRefresher()
                    tableViewController = try! GradingPeriod.TableViewController(
                        session: session,
                        courseID: course.id,
                        collection: collection,
                        refresher: refresher
                    )
                }

                describe(".viewDidLoad") {
                    beforeEach {
                        let _ = tableViewController.view
                    }

                    it("adds a cancel button") {
                        let cancelButton = tableViewController.navigationItem.leftBarButtonItem
                        expect(cancelButton).toNot(beNil())
                        expect(cancelButton?.target === tableViewController) == true
                        expect(cancelButton?.action) == #selector(GradingPeriod.TableViewController.cancel)
                    }
                }

                describe(".cancel") {
                    var presenter: UIViewController!
                    beforeEach {
                        let window = UIWindow()
                        presenter = UIViewController()
                        window.rootViewController = presenter
                        window.makeKeyAndVisible()
                        presenter.present(tableViewController, animated: false, completion: nil)
                        expect(presenter.presentedViewController).toNot(beNil())
                    }

                    it("dismisses vc") {
                        tableViewController.cancel()
                        expect(presenter.presentedViewController).toEventually(beNil())
                    }
                }
            }
        }
    }
}
