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
import CanvasCore
import ReactiveSwift

private let CourseNibAndReuseID = "CourseCardCell"
private let GroupNibAndReuseID = "GroupCardCell"


class EnrollmentCardViewModel: EnrollmentViewModel, CollectionViewCellViewModel {
    
    var showingGrades = MutableProperty(false)
    var shortcutTabs = MutableProperty<[Tab]>([])
    var customize: ()->()
    var showGrades: ()->()
    var takeShortcut: (URL)->()
    var handleError: (NSError)->()
    let session: Session
    
    init(session: Session, enrollment: Enrollment, showGrades: @escaping ()->(), customize: @escaping ()->(), takeShortcut: @escaping (URL)->(), handleError: @escaping (NSError)->()) {
        self.customize = customize
        self.showGrades = showGrades
        self.session = session
        self.takeShortcut = takeShortcut
        self.handleError = handleError
        
        super.init(enrollment: enrollment)
    }
    
    static func viewDidLoad(_ collectionView: UICollectionView) {
        collectionView.register(UINib(nibName: CourseNibAndReuseID, bundle: Bundle(for: EnrollmentCardViewModel.self)), forCellWithReuseIdentifier: CourseNibAndReuseID)
        collectionView.register(UINib(nibName: GroupNibAndReuseID, bundle: Bundle(for: EnrollmentCardViewModel.self)), forCellWithReuseIdentifier: GroupNibAndReuseID)
    }
    
    static var layout: UICollectionViewLayout {
        return PrettyCardsLayout()
    }
    
    func cellForCollectionView(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellID: String
        if enrollment.value is Course {
            cellID = CourseNibAndReuseID
        } else {
            cellID = GroupNibAndReuseID
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as? EnrollmentCardCell else { fatalError("Get your cells straightened out, everyone") }
        cell.viewModel = self
        return cell
    }
}
