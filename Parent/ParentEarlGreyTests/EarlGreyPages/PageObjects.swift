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

import EarlGrey
import SoGrey
import XCTest

extension XCTestCase {
  private struct Static {
    static let parentDomainPickerPage = ParentDomainPickerPage.self
    static let createAccountPage = CreateAccountPage.self
    static let forgotPasswordPage = ForgotPasswordPage.self
    static let logoutActionSheetPage = LogoutActionSheetPage.self
    static let gettingStartedPage = GettingStartedPage.self
    static let dashboardPage = DashboardPage.self
    static let settingsPage = SettingsPage.self
    static let coursesTabPage = CoursesTabPage.self
    static let coursePage = CoursePage.self
  }

  var parentDomainPickerPage: ParentDomainPickerPage.Type { return Static.parentDomainPickerPage }
  var createAccountPage: CreateAccountPage.Type { return Static.createAccountPage }
  var forgotPasswordPage: ForgotPasswordPage.Type { return Static.forgotPasswordPage }
  var logoutActionSheetPage: LogoutActionSheetPage.Type { return Static.logoutActionSheetPage }
  var gettingStartedPage: GettingStartedPage.Type { return Static.gettingStartedPage }
  var dashboardPage: DashboardPage.Type { return Static.dashboardPage }
  var settingsPage: SettingsPage.Type { return Static.settingsPage }
  var coursesTabPage: CoursesTabPage.Type { return Static.coursesTabPage }
  var coursePage: CoursePage.Type { return Static.coursePage }
}
