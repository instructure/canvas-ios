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

import ReactiveSwift
import Result



open class EnrollmentCollectionViewCell: PrettyCardsCell {
    open var enrollment: MutableProperty<Enrollment?> = MutableProperty(nil)
    fileprivate var colorDisposable: Disposable?

    fileprivate func beginObservingColors() {
        colorDisposable = ScopedDisposable(enrollment.producer
            .skipNil()
            .observe(on: UIScheduler())
            .flatMap(.latest) { $0.color.producer }
            .startWithValues { [weak self] color in
                self?.colorUpdated(color ?? .prettyGray())
            })
    }

    open func colorUpdated(_ color: UIColor) {
        self.backgroundColor = color
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        beginObservingColors()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        beginObservingColors()
    }
}
