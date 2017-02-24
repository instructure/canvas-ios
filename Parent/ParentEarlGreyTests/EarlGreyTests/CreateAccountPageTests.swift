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

class CreateAccountPageTests: LogoutBeforeEach {

  override func setUp() {
    super.setUp()
    parentDomainPickerPage.tapCreateAccount()
  }

  func testCreateAccountPage_displaysPageObjects() {
    createAccountPage.assertPageObjects()
  }

  func testCreateAccountPage_createAccountButtonDisabled_whenNoFirstName() {
    createAccountPage.assertCreateAccountButtonDisabled()
    createAccountPage.enterCredentials(Data.getNextParent(self))
    createAccountPage.clearForm("firstName")
    createAccountPage.assertCreateAccountButtonDisabled()
  }

  func testCreateAccountPage_createAccountButtonDisabled_whenNoLastName() {
    createAccountPage.assertCreateAccountButtonDisabled()
    createAccountPage.enterCredentials(Data.getNextParent(self))
    createAccountPage.clearForm("lastName")
    createAccountPage.assertCreateAccountButtonDisabled()
  }

  func testCreateAccountPage_createAccountButtonDisabled_whenNoEmail() {
    createAccountPage.assertCreateAccountButtonDisabled()
    createAccountPage.enterCredentials(Data.getNextParent(self))
    createAccountPage.clearForm("email")
    createAccountPage.assertCreateAccountButtonDisabled()
  }

  func testCreateAccountPage_createAccountButtonDisabled_whenNoPassword() {
    createAccountPage.assertCreateAccountButtonDisabled()
    createAccountPage.enterCredentials(Data.getNextParent(self))
    createAccountPage.clearForm("password")
    createAccountPage.assertCreateAccountButtonDisabled()
  }

  func testCreateAccountPage_createAccountButtonDisabled_whenNoConfirmPassword() {
    createAccountPage.assertCreateAccountButtonDisabled()
    createAccountPage.enterCredentials(Data.getNextParent(self))
    createAccountPage.clearForm("confirmPassword")
    createAccountPage.assertCreateAccountButtonDisabled()
  }

  func testCreateAccountPage_cancelButton() {
    createAccountPage.tapCancelButton()
    parentDomainPickerPage.assertPageObjects()
  }
}
