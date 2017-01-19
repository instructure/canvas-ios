//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation
import SoPersistent

class SimpleCollectionViewDataSource: NSObject, CollectionViewDataSource {
    var viewDidLoadWasCalled = false
    var layoutForTraitsWasCalled = false
    var sizeInCollectionViewWasCalled = false

    func viewDidLoad(_ controller: UICollectionViewController) {
        viewDidLoadWasCalled = true
    }

    var layout: UICollectionViewLayout {
        layoutForTraitsWasCalled = true
        return UICollectionViewFlowLayout()
    }

    func sizeInCollectionView(_ collectionView: UICollectionView, forItemAtIndexPath indexPath: IndexPath) -> CGSize {
        sizeInCollectionViewWasCalled = true
        return .zero
    }

    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }

    func isEmpty() -> Bool {
        return true
    }

}
