//
// Copyright (C) 2018-present Instructure, Inc.
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

import Foundation

public class LoadingViewController: UIViewController {
    @IBOutlet weak var logoView: IconView?

    public static func create() -> UIViewController {
        let controller = Bundle.loadController(self)
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        logoView?.tintColor = .currentLogoColor()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = 2 * Float.pi
        animation.repeatCount = Float.infinity
        animation.duration = 10.0
        logoView?.layer.add(animation, forKey: "spin")
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
