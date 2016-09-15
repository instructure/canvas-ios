//
//  ColorfulCollectionViewCell.swift
//  Enrollments
//
//  Created by Derrick Hathaway on 3/14/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
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
