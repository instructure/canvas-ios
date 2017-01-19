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

@testable import Canvas
import Quick
import Nimble
import SoAutomated
import TooLegit
@testable import SoEdventurous
@testable import EnrollmentKit
import SoPersistent
import ReactiveCocoa
import SoLazy

class ModuleViewModelSpec: QuickSpec {
    override func spec() {
        describe("ModuleViewModel") {
            var module: Module!
            var vm: ModuleViewModel!
            beforeEach {
                _ = login()
                module = Module.build()
                vm = try! ModuleViewModel(session: currentSession, module: module)
            }

            it("should format the unlock date") {
                module.unlockDate = Date(year: 2016, month: 10, day: 20)
                expect(vm.unlockDate.value).toEventually(equal("Locked until October 20, 2016"))

                module.unlockDate = nil
                expect(vm.unlockDate.value).toEventually(beNil())
            }

            describe("table view cell") {
                let tableView = UITableView()
                var cell: UITableViewCell!
                beforeEach {
                    ModuleViewModel.tableViewDidLoad(tableView)
                    cell = vm.cellForTableView(tableView, indexPath: IndexPath(row: 0, section: 0))

                    _ = Course.build {
                        $0.id = module.courseID
                        $0.roles = [.Student]
                    }
                    _ = ModuleItem.build {
                        $0.moduleID = module.id
                        $0.completionRequirement = .mustView
                        $0.completed = false
                    }
                }

                it("should have an accessibility label") {
                    module.name = "Module 1"
                    module.unlockDate = nil
                    module.state = nil
                    expect(cell.accessibilityLabel).toEventually(equal("Module 1"))

                    module.name = "Module 2"
                    module.unlockDate = nil
                    module.state = .started
                    expect(cell.accessibilityLabel).toEventually(equal("Module 2. Status: Started"))

                    module.state = .completed
                    expect(cell.accessibilityLabel).toEventually(equal("Module 2. Status: Completed"))

                    module.unlockDate = Date(year: 2016, month: 1, day: 1)
                    expect(cell.accessibilityLabel).toEventually(equal("Module 2. Locked until January 1, 2016. Status: Completed"))
                }

                it("should have an accessory view") {
                    module.state = nil
                    expect(cell.accessoryView).toEventually(beNil())

                    module.state = .started
                    expect(cell.accessoryView).toEventuallyNot(beNil())
                }

                it("should not have an accessory view if the state is nil") {
                    module.state = .completed
                    expect(cell.accessoryView).toEventuallyNot(beNil())

                    module.state = nil
                    expect(cell.accessoryView).toEventually(beNil())
                }
            }
        }
    }
}
