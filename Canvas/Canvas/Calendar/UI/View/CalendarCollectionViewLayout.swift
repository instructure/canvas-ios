
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

public class CalendarCollectionViewLayout: UICollectionViewFlowLayout {

    let daysInWeek = NSCalendar.currentCalendar().maximumRangeOfUnit(.Weekday).length
    
    let selfMinimumLineSpacing: CGFloat = 2.0
    let selfMinimumInteritemSpacing: CGFloat = 2.0
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        initialize()
    }
    
    override init() {
        super.init()
        initialize()
    }
    
    func initialize() {
        self.minimumLineSpacing = self.selfMinimumLineSpacing
        self.minimumInteritemSpacing = self.selfMinimumInteritemSpacing
    }
    
    func updateItemSize() {
        let totalIteritemSpacing: CGFloat = floor(self.selfMinimumInteritemSpacing * (CGFloat(daysInWeek) - 1))
        let itemWidth: CGFloat = floor((CGRectGetWidth(self.collectionView!.frame) - totalIteritemSpacing) / CGFloat(daysInWeek))
        let itemHeight: CGFloat = isPad() ? 100.0 : 62.0
        self.itemSize = CGSizeMake(itemWidth, itemHeight)
    }
    
    func updateHeaderSize() {
        let headerWidth = CGRectGetWidth(self.collectionView!.frame)
        let headerHeight: CGFloat = isPad() ? 64.0 : 34.0
        self.headerReferenceSize = CGSizeMake(headerWidth, headerHeight)
    }
    
    func isPad() -> Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad
    }
}