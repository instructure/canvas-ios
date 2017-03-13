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
import XCTest

class CKITodoItemTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        
        let todoItemDictionary = Helpers.loadJSONFixture("todo_item") as NSDictionary
        let todoItem = CKITodoItem(fromJSONDictionary: todoItemDictionary)
        
        XCTAssertEqual(todoItem.type!, "grading", "Todo Item type was not parsed correctly")
        
        XCTAssertNotNil(todoItem.assignment, "Todo Item assignment was not parsed correctly")
        
        var url = NSURL(string:"https://mobiledev.instructure.com/api/v1/users/self/todo/assignment_3493245/grading?permanent=0")
        XCTAssertEqual(todoItem.ignore!, url!, "Todo Item ignore was not parsed correctly")
        
        url = NSURL(string:"https://mobiledev.instructure.com/api/v1/users/self/todo/assignment_3493245/grading?permanent=1")!
        XCTAssertEqual(todoItem.ignorePermanently!, url!, "Todo Item ignorePermanently was not parsed correctly")
        
        url = NSURL(string:"https://mobiledev.instructure.com/courses/1111375/gradebook/speed_grader?assignment_id=3493245")!
        XCTAssertEqual(todoItem.htmlUrl!, url!, "Todo Item htmlUrl was not parsed correctly")
        
        XCTAssertEqual(todoItem.needsGradingCount, 1, "Todo Item needsGradingCount was not parsed correctly")
        
        XCTAssertEqual(todoItem.courseID!, "1", "Todo Item courseID was not parsed correctly")
        
        XCTAssertEqual(todoItem.contextType!, "Course", "Todo Item contextType was not parsed correctly")
        
        XCTAssertEqual(todoItem.groupID!, "2", "Todo Item groupID was not parsed correctly")
        
        XCTAssertEqual(todoItem.path!, "/api/v1/users/self/todo/1", "Todo Item Path was not parsed correctly")
    }
}
