//
//  CourseViewModel.swift
//  Teach
//
//  Created by Derrick Hathaway on 4/11/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import EnrollmentKit
import SoPretty
import SoLazy

class CourseViewModel: Course.ViewModel {
    let customize: (source: UIButton)->()
    let makeAnAnnouncement: ()->()
    
    init(enrollment: Course, customize: (source: UIButton)->(), makeAnAnnouncement: ()->()) {
        self.customize = customize
        self.makeAnAnnouncement = makeAnAnnouncement
        super.init(enrollment: enrollment)
    }
}



import SoPersistent

extension CourseViewModel: CollectionViewCellViewModel {
    static func viewDidLoad(collectionView: UICollectionView) {
        collectionView.registerNib(UINib(nibName: "CourseCell", bundle: nil), forCellWithReuseIdentifier: "CourseCell")
    }
    
    static var layout: UICollectionViewLayout {
        return PrettyCardsLayout()
    }
    
    func cellForCollectionView(collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CourseCell", forIndexPath: indexPath) as? CourseCell else { ❨╯°□°❩╯⌢"Register your course cell!!!" }
        cell.viewModel = self
        return cell
    }
}