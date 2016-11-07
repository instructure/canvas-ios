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