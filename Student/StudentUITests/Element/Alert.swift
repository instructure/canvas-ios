//
// Copyright (C) 2019-present Instructure, Inc.
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

import Foundation
import SwiftUITest

struct Alert {
    let greyInteraction: GREYInteraction

    static func button(label: String) -> Alert {
        return Alert(greyInteraction: EarlGrey.selectElement(with: grey_allOf([
            grey_accessibilityLabel(label),
            grey_kindOfClass(NSClassFromString("_UIAlertControllerActionView")!),
        ])).atIndex(0))
    }

    func tap() {
        self.greyInteraction.perform(grey_tap())
    }

    func exists() -> Bool {
        var err: NSError?
        greyInteraction.assert(grey_notNil(), error: &err)
        return err == nil
    }
}
