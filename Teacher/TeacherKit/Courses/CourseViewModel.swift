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
import EnrollmentKit
import SoPretty
import SoLazy

class CourseViewModel: Course.ViewModel {
    let customize: (_ source: UIButton)->()
    let makeAnAnnouncement: ()->()
    
    init(enrollment: Course, customize: @escaping (UIButton)->(), makeAnAnnouncement: @escaping ()->()) {
        self.customize = customize
        self.makeAnAnnouncement = makeAnAnnouncement
        super.init(enrollment: enrollment)
    }
}



import SoPersistent

extension CourseViewModel: CollectionViewCellViewModel {
    static func viewDidLoad(_ collectionView: UICollectionView) {
        collectionView.register(UINib(nibName: "CourseCell", bundle: .teacherKit), forCellWithReuseIdentifier: "CourseCell")
    }
    
    static var layout: UICollectionViewLayout {
        return PrettyCardsLayout()
    }
    
    func cellForCollectionView(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CourseCell", for: indexPath) as? CourseCell else { ❨╯°□°❩╯⌢"Register your course cell!!!" }
        cell.viewModel = self
        return cell
    }
}
