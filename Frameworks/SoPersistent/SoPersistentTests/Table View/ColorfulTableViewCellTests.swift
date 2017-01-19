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
    
    

@testable import SoPersistent
import XCTest
import Nimble

class ColorfulTableViewCellTests: XCTestCase {
    let tableView = UITableView()

    override func setUp() {
        super.setUp()
    }

    func testItShouldHaveNilAccessibilityIdentifiersByDefault() {
        let vm = ColorfulViewModel(features: [.subtitle, .icon])
        ColorfulViewModel.tableViewDidLoad(tableView)

        let cell = vm.cellForTableView(tableView, indexPath: IndexPath(row: 0, section: 0)) as! ColorfulTableViewCell
        expect(cell.accessibilityIdentifier).to(beNil())
        expect(cell.titleLabel.accessibilityIdentifier).to(beNil())
        expect(cell.subtitleLabel?.accessibilityIdentifier).to(beNil())

        vm.accessoryView.value = UIView()
        expect(cell.accessoryView!.accessibilityIdentifier).to(beNil())

        vm.icon.value = .icon(.inbox)
        expect(cell.iconView?.accessibilityIdentifier).to(beNil())
    }

    func testItShouldSetAccessibilityIdentifiers() {
        let vm = ColorfulViewModel(features: [.icon, .subtitle])
        vm.accessoryView.value = UIView()
        vm.icon.value = .icon(.inbox)
        ColorfulViewModel.tableViewDidLoad(tableView)

        let row0 = vm.cellForTableView(tableView, indexPath: IndexPath(row: 0, section: 0)) as! ColorfulTableViewCell
        vm.accessibilityIdentifier.value = "course"
        expect(row0.titleLabel.accessibilityIdentifier) == "course_title_0_0"
        expect(row0.subtitleLabel?.accessibilityIdentifier) == "course_subtitle_0_0"
        expect(row0.accessoryView!.accessibilityIdentifier) == "course_accessory_image_0_0"
        expect(row0.iconView?.accessibilityIdentifier) == "course_icon_0_0"
        expect(row0.accessibilityIdentifier) == "course_cell_0_0"
        vm.accessibilityIdentifier.value = "event"
        expect(row0.titleLabel.accessibilityIdentifier) == "event_title_0_0"
        expect(row0.subtitleLabel?.accessibilityIdentifier) == "event_subtitle_0_0"
        expect(row0.accessoryView!.accessibilityIdentifier) == "event_accessory_image_0_0"
        expect(row0.iconView?.accessibilityIdentifier) == "event_icon_0_0"
        expect(row0.accessibilityIdentifier) == "event_cell_0_0"

        let row1Section1 = vm.cellForTableView(tableView, indexPath: IndexPath(row: 1, section: 1)) as! ColorfulTableViewCell
        vm.accessibilityIdentifier.value = "course"
        expect(row1Section1.titleLabel.accessibilityIdentifier) == "course_title_1_1"
        expect(row1Section1.subtitleLabel?.accessibilityIdentifier) == "course_subtitle_1_1"
        expect(row1Section1.accessoryView!.accessibilityIdentifier) == "course_accessory_image_1_1"
        expect(row1Section1.iconView?.accessibilityIdentifier) == "course_icon_1_1"
        expect(row1Section1.accessibilityIdentifier) == "course_cell_1_1"
        vm.accessibilityIdentifier.value = "event"
        expect(row1Section1.titleLabel.accessibilityIdentifier) == "event_title_1_1"
        expect(row1Section1.subtitleLabel?.accessibilityIdentifier) == "event_subtitle_1_1"
        expect(row1Section1.accessoryView!.accessibilityIdentifier) == "event_accessory_image_1_1"
        expect(row1Section1.iconView?.accessibilityIdentifier) == "event_icon_1_1"
        expect(row1Section1.accessibilityIdentifier) == "event_cell_1_1"
    }
}

