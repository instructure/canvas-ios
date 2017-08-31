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

protocol CalendarCollectionViewDelegate: UICollectionViewDelegate {
    func collectionViewWillLayoutSubview(_ calendarCollectionView: CalendarCollectionView)
}

class CalendarCollectionView: UICollectionView {
    var calendarDelegate: CalendarCollectionViewDelegate?
    var selfBackgroundColor: UIColor = .white
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        initialize()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        initialize()
    }
    
    func initialize() {
        backgroundColor = selfBackgroundColor
        showsHorizontalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        scrollsToTop = false
        delaysContentTouches = false
    }

    override func layoutSubviews() {
        calendarDelegate?.collectionViewWillLayoutSubview(self)
        super.layoutSubviews()
    }
}
