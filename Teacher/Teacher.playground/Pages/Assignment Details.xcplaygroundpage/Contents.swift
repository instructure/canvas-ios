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

//: [Previous](@previous)

import UIKit
import PlaygroundSupport
let page = PlaygroundPage.current
page.needsIndefiniteExecution = true

import TeacherKit
import SixtySix
import DoNotShipThis


class Deets: UIViewController, Destination {
    static func visit(with: (String, String)) -> UIViewController {
        let d = Deets()
        d.view.backgroundColor = UIColor(hue: 0.6, saturation: 0.8, brightness: 1.0, alpha: 1.0)
        return d
    }
}


page.liveView = Deets.visit(with: ("12", "55"))
