//
//  CoursesCollectionViewControllerSpec.swift
//  Canvas
//
//  Created by Nathan Armstrong on 8/23/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import Canvas
import Quick
import Nimble
import SoAutomated
import EnrollmentKit

class CoursesCollectionViewControllerSpec: QuickSpec {
    override func spec() {
        describe("CoursesCollectionViewControllerSpec") {
            context("when a favorite is removed") {
                var vc: CoursesCollectionViewController!

                beforeEach {
                    let user = User(credentials: .user1)
                    let session = user.session
                    let managedObjectContext = try! session.enrollmentManagedObjectContext()
                    let courseToRemove = Course.build(managedObjectContext, id: "1", isFavorite: true)
                    Course.build(managedObjectContext, id: "2", isFavorite: true)
                    Course.build(managedObjectContext, id: "3", isFavorite: true)
                    Course.build(managedObjectContext, id: "4", isFavorite: true)
                    try! managedObjectContext.save()
                    vc = try! CoursesCollectionViewController(session: session) { _ in }

                    waitUntil { done in
                        if vc.collectionView?.numberOfItemsInSection(0) == 4 {
                            courseToRemove.setValue(false, forKey: "isFavorite")
                            done()
                        }
                    }
                }

                it("updates the collection view") {
                    expect(vc.collectionView?.numberOfItemsInSection(0)).toEventually(equal(3))
                }
            }
        }
    }
}
