//
//  GradingPeriodSpec.swift
//  Enrollments
//
//  Created by Nathan Armstrong on 7/27/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
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
                    let managedObjectContext = try! session.enrollmentManagedObjectContext()
                    let course = Course.build(managedObjectContext, id: "1811031")
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
                        presenter.presentViewController(tableViewController, animated: false, completion: nil)
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
