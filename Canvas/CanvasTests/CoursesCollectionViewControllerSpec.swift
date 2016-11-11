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
    
    

import UIKit
import Canvas
import Quick
import Nimble
import SoAutomated
@testable import EnrollmentKit

class CoursesCollectionViewControllerSpec: QuickSpec {
    override func spec() {
        describe("CoursesCollectionViewControllerSpec") {
            context("when a favorite is removed") {
                var vc: CoursesCollectionViewController!

                beforeEach {
                    let user = User(credentials: .user1)
                    let session = user.session
                    let managedObjectContext = try! session.enrollmentManagedObjectContext()
                    let courseToRemove = Course.build(inSession: session) { $0.id = "1"; $0.isFavorite = true }
                    Course.build(inSession: session) { $0.id = "2"; $0.isFavorite = true }
                    Course.build(inSession: session) { $0.id = "3"; $0.isFavorite = true }
                    Course.build(inSession: session) { $0.id = "4"; $0.isFavorite = true }
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
                    expect(vc.collectionView?.numberOfItemsInSection(0)).toEventually(equal(3), timeout: 2)
                }
            }
        }
    }
}
