//
//  CalendarCollectionViewLayout.swift
//  Calendar
//
//  Created by Brandon Pluim on 2/9/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
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