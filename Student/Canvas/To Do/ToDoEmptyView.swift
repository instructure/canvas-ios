//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
import Core

class ToDoEmptyView: UIView {
    @IBOutlet var emptyImageView: UIImageView?
    @IBOutlet var mainLabel: UILabel?
    @IBOutlet var descriptionLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        mainLabel?.text = NSLocalizedString("No To-Do Items", comment: "")
        descriptionLabel?.text = NSLocalizedString("It looks like there’s nothing to do today. Enjoy your day!", comment: "")
    }
}
