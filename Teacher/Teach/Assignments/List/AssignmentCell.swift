
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
    
    

import UIKit
import SoPretty
import ReactiveCocoa

class AssignmentCell: UITableViewCell {
    
    @IBOutlet private weak var icon: UIImageView?
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var subtitleLabel: UILabel?
    
    func prepare(iconImage: UIImage, iconA11yLabel: String, title: String, subtitle: String) {
        icon?.image = iconImage
        titleLabel?.text = title
        subtitleLabel?.text = subtitle
        
        accessibilityLabel = title + " — " + iconA11yLabel + " — " + subtitle
    }
    
    override func prepareForReuse() {
        colorDisposable?.dispose()
        colorDisposable = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let bg = UIView()
        bg.backgroundColor = color.lighterShade()
        selectedBackgroundView = bg
    }

    // MARK: Color
    
    func observe(color: MutableProperty<UIColor>) {
        let disposeColor = color
            .producer
            .observeOn(UIScheduler())
            .startWithNext { [unowned self] color in
            self.color = color
        }
        
        colorDisposable = ScopedDisposable(disposeColor)
    }
    
    private var colorDisposable: Disposable? = nil
    
    private var color: UIColor = .prettyGray() {
        didSet {
            selectedBackgroundView?.backgroundColor = color.lighterShade()
            tintColor = color
        }
    }
}