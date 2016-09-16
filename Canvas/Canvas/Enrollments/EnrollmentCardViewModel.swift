//
//  EnrollmentCardViewModel.swift
//  iCanvas
//
//  Created by Derrick Hathaway on 3/22/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import EnrollmentKit
import SoPersistent
import SoPretty
import ReactiveCocoa

private let CourseNibAndReuseID = "CourseCardCell"
private let GroupNibAndReuseID = "GroupCardCell"


class EnrollmentCardViewModel: Enrollment.ViewModel, CollectionViewCellViewModel {
    
    var showingGrades = MutableProperty(false)
    var shortcutTabs = MutableProperty<[Tab]>([])
    var customize: ()->()
    var showGrades: ()->()
    var takeShortcut: NSURL->()
    var handleError: NSError->()
    let session: Session
    
    init(session: Session, enrollment: Enrollment, showGrades: ()->(), customize: ()->(), takeShortcut: NSURL->(), handleError: NSError->()) {
        self.customize = customize
        self.showGrades = showGrades
        self.session = session
        self.takeShortcut = takeShortcut
        self.handleError = handleError
        
        super.init(enrollment: enrollment)
    }
    
    static func viewDidLoad(collectionView: UICollectionView) {
        collectionView.registerNib(UINib(nibName: CourseNibAndReuseID, bundle: NSBundle(forClass: EnrollmentCardViewModel.self)), forCellWithReuseIdentifier: CourseNibAndReuseID)
        collectionView.registerNib(UINib(nibName: GroupNibAndReuseID, bundle: NSBundle(forClass: EnrollmentCardViewModel.self)), forCellWithReuseIdentifier: GroupNibAndReuseID)
    }
    
    static var layout: UICollectionViewLayout {
        return PrettyCardsLayout()
    }
    
    func cellForCollectionView(collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cellID: String
        if enrollment.value is Course {
            cellID = CourseNibAndReuseID
        } else {
            cellID = GroupNibAndReuseID
        }
        
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellID, forIndexPath: indexPath) as? EnrollmentCardCell else { fatalError("Get your cells straightened out, everyone") }
        cell.viewModel = self
        return cell
    }
}
