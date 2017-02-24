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

class ParentDomainPickerPageTests: LogoutBeforeEach {

  func testParentDomainPickerPage_displaysPageObjects() {
    parentDomainPickerPage.assertPageObjects()
  }

  func testParentDomainPickerPage_createAccountButton() {
    parentDomainPickerPage.tapCreateAccount()
    createAccountPage.assertPageObjects()
  }

  func testParentDomainPickerPage_forgotPasswordButton() {
    parentDomainPickerPage.tapForgotPassword()
    forgotPasswordPage.assertPageObjects()
  }

  func testParentDomainPickerPage_loginButtonDisabledWhenNoPassword() {
    parentDomainPickerPage.assertLoginButtonDisabled()
    parentDomainPickerPage.enterCredentials(Data.getNextParent(self))
    parentDomainPickerPage.clearPasswordField()
    parentDomainPickerPage.assertLoginButtonDisabled()
  }

  func testParentDomainPickerPage_loginButtonDisabledWhenNoEmail() {
    parentDomainPickerPage.assertLoginButtonDisabled()
    parentDomainPickerPage.enterCredentials(Data.getNextParent(self))
    parentDomainPickerPage.clearPasswordField()
    parentDomainPickerPage.assertLoginButtonDisabled()
  }

  func testParentDomainPickerPage_loginButtonEnabled() {
    parentDomainPickerPage.assertLoginButtonDisabled()
    parentDomainPickerPage.enterCredentials(Data.getNextParent(self))
    parentDomainPickerPage.assertLoginButtonEnabled()
  }

  func testParentDomainPickerPage_loginButton() {
    parentDomainPickerPage.loginAs(Data.getNextParent(self))
    gettingStartedPage.assertPageObjects()
  }
}
