
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
@testable import ObserverAlertKit
import SoAutomated
import TooLegit
import DoNotShipThis
import Marshal
import AVFoundation

class AlertCountCoordinatorTests: XCTestCase {

    func testAlertCountCoordinator_unreadPredicate() {
        attempt {
            let session = Session.parentTest
            let predicate = Alert.unreadPredicate()

            let context = try session.alertsManagedObjectContext()
            let alertRead = Alert.build(context)
            alertRead.read = true

            let alertNotRead = Alert.build(context)
            alertNotRead.read = false

            let _ = AlertCountCoordinator(session: session, predicate: predicate) { count in
                XCTAssertEqual(1, count, "There should only be 1 not read alert counted")
            }
        }
    }

    func testAlertCountCoordinator_UndismissedPredicate() {
        attempt {
            let session = Session.parentTest
            let predicate = Alert.undismissedPredicate()

            let context = try session.alertsManagedObjectContext()
            let alertRead = Alert.build(context)
            alertRead.dismissed = true

            let alertNotRead = Alert.build(context)
            alertNotRead.dismissed = false

            let _ = AlertCountCoordinator(session: session, predicate: predicate) { count in
                XCTAssertEqual(1, count, "There should only be 1 not read alert counted")
            }
        }
    }


}