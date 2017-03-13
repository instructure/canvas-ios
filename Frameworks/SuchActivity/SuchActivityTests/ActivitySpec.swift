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

@testable import SuchActivity
import Quick
import Nimble
import SoAutomated
import SoPersistent
import CoreData
import TooLegit
import Result
import Marshal
import ReactiveCocoa
import AVFoundation
import WebKit


extension Activity {
    static var validJSON: JSONObject {
        return [
            "id": 1,
            "title": "An activity stream item",
            "message": "Some deets",
            "html_url": "https://google.com",
            "type": "Submission",
            "context_type": "Course",
            "course_id": "1",
            "created_at": "2016-11-14T22:01:52Z",
            "updated_at": "2016-11-14T22:01:52Z"
        ]
    }
}

class ActivitySpec: QuickSpec {
    override func spec() {
        describe("Activity") {
            context("init") {
                var activity: Activity!
                var moc: NSManagedObjectContext!
                beforeEach {
                    moc = User(credentials: .user1).session.suchActivityManagedObjectContext
                    activity = Activity(inContext: moc)
                }

                it("gets inserted") {
                    expect(moc.insertedObjects.contains(activity)) == true
                }
            }
        }

        describe("updateValues") {
            var activity: Activity!
            var session: Session!
            var moc: NSManagedObjectContext!
            beforeEach {
                session = .user1
                moc = session.suchActivityManagedObjectContext
                activity = Activity(inContext: moc)
            }

            it("should update values correctly") {
                let json = Activity.validJSON
                try! activity.updateValues(json, inContext: moc)

                expect(activity.title).to(equal("An activity stream item"))
                expect(activity.message).to(equal("Some deets"))
                expect(activity.url).to(equal(NSURL(string: "https://google.com")!))
                expect(activity.type).to(equal(ActivityType.Submission))
            }

            it("should set context when type is course") {
                var json = Activity.validJSON
                json["context_type"] = "Course"
                json["course_id"] = "1"
                try! activity.updateValues(json, inContext: moc)

                expect(activity.context.canvasContextID).to(equal("course_1"))
            }

            it("should set context when type is group") {
                var json = Activity.validJSON
                json["context_type"] = "Group"
                json["group_id"] = "1"
                try! activity.updateValues(json, inContext: moc)

                expect(activity.context.canvasContextID).to(equal("group_1"))
            }
        }

        describe("refreshers") {
            describe("collection refresher") {
                it("syncs activities") {
                    let session = User(credentials: .user1).session
                    let count = Activity.observeCount(inSession: session)

                    let refresher = try! Activity.refresher(session)
                    expect {
                        refresher.playback("RefreshUserActivities", in: .soAutomated, with: session)
                    }.to(change({ count.currentCount }, from: 0, to: 1))
                }
            }
        }
    }
}
