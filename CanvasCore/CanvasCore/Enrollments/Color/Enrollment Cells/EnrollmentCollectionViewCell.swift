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
    
    

import Foundation

import ReactiveSwift
import Result



open class EnrollmentCollectionViewCell: PrettyCardsCell {
    open var enrollment: MutableProperty<Enrollment?> = MutableProperty(nil)
    fileprivate var colorDisposable: Disposable?

    fileprivate func beginObservingColors() {
        colorDisposable = ScopedDisposable(enrollment.producer
            .skipNil()
            .observe(on: UIScheduler())
            .flatMap(.latest) { $0.color.producer }
            .startWithValues { [weak self] color in
                self?.colorUpdated(color ?? .prettyGray())
            })
    }

    open func colorUpdated(_ color: UIColor) {
        self.backgroundColor = color
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        beginObservingColors()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        beginObservingColors()
    }
}
