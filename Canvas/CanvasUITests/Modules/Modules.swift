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

import XCTest
import TestsFoundation

enum ModulesDetail {
    static func module(index: Int) -> Element {
        return app.find(id: "module_cell_0_\(index)")
    }

    static func moduleItem(index: Int) -> Element {
        return app.find(id: "module_item_cell_0_\(index)")
    }
}

enum ModuleItemNavigation {
    static var nextButton: Element {
        return app.find(id: "next_module_item_button")
    }

    static var previousButton: Element {
        return app.find(id: "previous_module_item_button")
    }

    static var backButton: Element {
        return app.find(labelContaining: "Assignment Module")
    }
}

enum ExternalTool {
    static var launchButton: Element {
        return app.find(labelContaining: "Launch External Tool")
    }

    static func pageText(_ string: String) -> Element {
        return app.find(labelContaining: string)
    }

    static var doneButton: Element {
        return app.find(labelContaining: "Done")
    }
}
