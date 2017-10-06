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

class DomainPickerTests: TeacherTest {
    
    func testDomainPicker_domainFieldAllowsInput() {
        let domain = "mobiledev"
        domainPickerPage.enterDomain(domain)
        domainPickerPage.assertDomainField(contains: domain)
    }

    // todo: tmp test only. used to validate webdriver logic
    func testBadLogin() {
        let domain = "mobileqa.test.instructure.com"
        domainPickerPage.openDomain(domain)

        let client = Soseedy_SoSeedyService.init(address: "localhost:50051")
        let user:Soseedy_Teacher = try! client.createteacher(Soseedy_CreateTeacherRequest())

        canvasLoginPage.logInTmp(loginId: user.username, password: user.password)
    }
}
