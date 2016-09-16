//
//  CalendarCollectionView.swift
//  Calendar
//
//  Created by Brandon Pluim on 2/9/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit

protocol CalendarCollectionViewDelegate: UICollectionViewDelegate {
    func collectionViewWillLayoutSubview(calendarCollectionView: CalendarCollectionView)
}

class CalendarCollectionView: UICollectionView {
    var calendarDelegate: CalendarCollectionViewDelegate?
    var selfBackgroundColor: UIColor = UIColor.whiteColor()
    
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