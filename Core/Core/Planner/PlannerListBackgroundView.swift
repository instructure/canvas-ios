//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

/**
 The purpose of this subclass is to hide the empty panda view in case there's not enough vertical space like in landscape mode on a smaller iphone.
 */
public class PlannerListBackgroundView: ListBackgroundView {
    @IBOutlet private weak var pandaHeight: NSLayoutConstraint!
    @IBOutlet private weak var pandaTextVerticalPadding: NSLayoutConstraint!
    private var originalPandaHeight: CGFloat = 0
    private var originalPandaTextVerticalPadding: CGFloat = 0

    public override func awakeFromNib() {
        super.awakeFromNib()
        originalPandaHeight = pandaHeight.constant
        originalPandaTextVerticalPadding = pandaTextVerticalPadding.constant
    }

    public override func layoutSubviews() {
        if traitCollection.verticalSizeClass == .compact {
            pandaHeight.constant = 0
            pandaTextVerticalPadding.constant = 0
        } else {
            pandaHeight.constant = originalPandaHeight
            pandaTextVerticalPadding.constant = originalPandaTextVerticalPadding
        }

        super.layoutSubviews()
    }
}
