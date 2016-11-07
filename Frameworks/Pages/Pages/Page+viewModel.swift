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

