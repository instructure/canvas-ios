
//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import XCTest
import SoGrey
import EarlGrey

class TeacherEarlGrey: LogoutBeforeEach {

  func testExample() {
// When we switched from CanvasKeymaster (ObjC) to Keymaster (Swift) I think this test broke.
// The Keymaster domain search field does not provide a11y ids. :shame:
    EarlGrey().selectElementWithMatcher(grey_accessibilityID("domain_search_field"))
      .assertWithMatcher(grey_notNil())
  }
}
