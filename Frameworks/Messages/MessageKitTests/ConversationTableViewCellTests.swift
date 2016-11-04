
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
    
    

import SoAutomated
import MessageKit
import SoPersistent
import SoLazy

class ConversationTableViewCellTests: UnitTestCase {

    func testConversationTableViewController_tableViewRowHeightIsAutomaticDimension() {
        let context = login(User1())
        let tvc = prepareTableViewController(context, fixture: "conversations")
        XCTAssertEqual(UITableViewAutomaticDimension, tvc.tableView.rowHeight)
    }

    func testConversationTableViewController_tableViewEstimatedRowHeight_is44() {
        let context = login(User1())
        let tvc = prepareTableViewController(context, fixture: "conversations")
        XCTAssertEqual(44, tvc.tableView.estimatedRowHeight)
    }

    func testConversationTableViewController_sortsConversationsByWorkflowStateThenDate() {
        let context = login(User1())
        let tvc = prepareTableViewController(context, fixture: "conversations-2")
        let first = tvc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! ConversationTableViewCell
        let second = tvc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! ConversationTableViewCell
        let expectedOrder = ["User 2", "User 2, +1"]
        let actualOrder = [first, second].map { $0.nameTextLabel?.text ?? "" }
        XCTAssertEqual(expectedOrder, actualOrder, "it should order by workflow state")
    }

    func testConversationTableViewCell_nameTextLabel_shouldNotBeNil() {
        let cell = firstCell()
        XCTAssertNotNil(cell.nameTextLabel, "it should not be nil")
    }

    func testConversationTableViewCell_nameTextLabel_whenThereIsOneParticipant_isTheNameOfTheParticipant() {
        let cell = whenThereIsOneParticipant()
        XCTAssertEqual("User 2", cell.nameTextLabel?.text, "it should be the name of the participant")
    }

    func testConversationTableViewCell_nameTextLabel_whenThereAreMultipleParticipants_isTheNameOfTheMostRecentSenderPlusCount() {
        let cell = whenThereAreMultipleParticipants()
        XCTAssertEqual("User 2, +1", cell.nameTextLabel?.text, "it should match name + count")
    }

    func testConversationTableViewCell_subjectTextLabel_whenThereIsASubject_isTheSubject() {
        let cell = whenThereIsASubject()
        XCTAssertEqual("This is a Subject Line Demo", cell.subjectTextLabel?.text, "it should match the subject")
    }

    func testConversationTableViewCell_subjectTextLabel_whenThereIsNotASubject_isAnEmptyString() {
        let cell = whenThereIsNotASubject()
        XCTAssertEqual("", cell.subjectTextLabel?.text, "it should be empty")
    }

    func testConversationTableViewCell_date_whenTheDateIsNotToday_isTheMonthAndDate() {
        let cell = whenTheDateIsNotToday()
        XCTAssertEqual("Jul 1", cell.dateTextLabel?.text, "it should be the month and the date")
    }

    func testConversationTableViewCell_date_whenTheDateIsToday_isTheTime() {
        Clock.timeTravel(to: NSDate(year: 2016, month: 7, day: 7)) {
            let cell = whenTheDateIsToday()
            XCTAssertEqual("8:25 PM", cell.dateTextLabel?.text, "it should be the time")
        }
    }

    func testConversationTableViewCell_displaysMostRecentMessage() {
        let cell = firstCell()
        let expectedBody = "This is an example of a group message that doesn't have a subject line. It should be really long ..."
        XCTAssertEqual(expectedBody, cell.messageTextLabel?.text, "it should match the body")
    }

    func testConversationTableViewCell_shows2LinesOfMostRecentMessage() {
        let cell = firstCell()
        XCTAssertEqual(2, cell.messageTextLabel?.numberOfLines, "it should have 2 number of lines")
    }

    func testConversationTableViewCell_displaysMostRecentSenderAvatar() {
        let cell = firstCell()
        XCTAssertNotNil(cell.avatarImageView?.image, "it should have an avatar image")
    }

    // MARK: Contexts

    private func whenThereIsOneParticipant() -> ConversationTableViewCell {
        return user1Cell2()
    }

    private func whenThereAreMultipleParticipants() -> ConversationTableViewCell {
        return user1Cell1("conversations")
    }

    private func whenThereIsASubject() -> ConversationTableViewCell {
        return user1Cell2()
    }

    private func whenThereIsNotASubject() -> ConversationTableViewCell {
        return user1Cell1("conversations")
    }

    private func whenTheDateIsNotToday() -> ConversationTableViewCell {
        return user1Cell1("conversations")
    }

    private func whenTheDateIsToday() -> ConversationTableViewCell {
        return user1Cell1("conversations-2")
    }

    // MARK: Helpers

    private func firstCell() -> ConversationTableViewCell {
        let context = login(User1())
        let tvc = prepareTableViewController(context, fixture: "conversations")
        return tvc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! ConversationTableViewCell
    }

    private func user1Cell1(fixture: Fixture?) -> ConversationTableViewCell {
        let context = login(User1())
        let tvc = prepareTableViewController(context, fixture: fixture)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        return tvc.tableView.cellForRowAtIndexPath(indexPath) as! ConversationTableViewCell
    }

    private func user1Cell2() -> ConversationTableViewCell {
        let context = login(User1())
        let tvc = prepareTableViewController(context, fixture: "conversations")
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        return tvc.tableView.cellForRowAtIndexPath(indexPath) as! ConversationTableViewCell
    }

    private func prepareTableViewController(context: Context, fixture: Fixture?) -> Conversation.TableViewController {
        let tvc = Conversation.TableViewController()

        attempt {
            let collection = try Conversation.collection(context.user.session)
            let refresher = try Conversation.refresher(context.user.session)
            tvc.prepare(collection, refresher: refresher, viewModelFactory: ConversationViewModel.init)
            
            let refreshCompleted = refresher.refreshCompleted

            let refresh: XCTestExpectation->Void = { expectation in
                refresher.refreshCompleted = { error in
                    if let error = error {
                        XCTFail(error.localizedDescription)
                        return
                    }
                    refreshCompleted(error)
                    expectation.fulfill()
                }

                guard let window = UIApplication.sharedApplication().keyWindow else {
                    XCTFail("expected a window")
                    return
                }

                window.rootViewController = tvc
                window.makeKeyAndVisible()
            }

            if let fixture = fixture {
                stub(context.user.session, fixture) { expectation in
                    refresh(expectation)
                }
            } else {
                let expectation = expectationWithDescription("first refresh")
                refresh(expectation)
                waitForExpectationsWithTimeout(4, handler: nil)
            }
        }

        return tvc
    }

}

extension XCTestCase {
    func login(user: User) -> Context {
        return Context(user: user, testCase: self)
    }
}
