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
import TooLegit
import ReactiveCocoa
import Result
import SoLazy
import SoPretty

extension Enrollment {
    var colorSignalProducer: SignalProducer<UIColor, NoError> {
        return rac_valuesForKeyPath("color", observer: nil)
            .toSignalProducer()
            .map { $0 as? UIColor ?? .prettyGray() }
            .flatMapError { _ in SignalProducer<UIColor, NoError>(value: UIColor.prettyGray()) }
    }
}

public class EnrollmentCollectionViewCell: PrettyCardsCell {
    public var enrollment: MutableProperty<Enrollment?> = MutableProperty(nil)
    private var colorDisposable: Disposable?

    private func beginObservingColors() {
        colorDisposable = enrollment.producer
            .observeOn(UIScheduler())
            .flatMap(.Latest) { enrollment in
                return enrollment?.colorSignalProducer ?? SignalProducer<UIColor, NoError>(value: .prettyGray())
            }
            .startWithNext { [weak self] color in
                self?.colorUpdated(color)
            }
    }

    public func colorUpdated(color: UIColor) {
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
