//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import XCTest
@testable import Core

class UIBarButtonItemExtensionTests: XCTestCase {

    var nav: UINavigationController?
    func testBarButtonItem() {
        let b = UIBarButtonItem(image: UIImage.icon(.addAudioLine), style: .plain, target: self, action: nil)
        let v = UIView()
        b.setValue(v, forKey: "view")
        XCTAssertNoThrow(  b.addBadge(number: 3, color: .red) )
        print(v.layer.sublayers!)
        let textLayer: CATextLayer? = v.layer.sublayers?.first?.sublayers?.filter { $0 is CATextLayer }.first as? CATextLayer
        let value: String? = textLayer?.string as? String
        XCTAssertEqual(value, "3")
        let shape = v.layer.sublayers?.first as? CAShapeLayer
        XCTAssertEqual(shape?.fillColor, UIColor.white.cgColor)
        XCTAssertEqual(shape?.strokeColor, UIColor.red.cgColor)
    }
}
