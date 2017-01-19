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

class SimpleTransitionCoordinator: NSObject, UIViewControllerTransitionCoordinator, UIViewControllerTransitionCoordinatorContext {
    public var targetTransform: CGAffineTransform = .identity

    public var containerView: UIView = UIView()

    public var completionCurve: UIViewAnimationCurve = .easeIn

    public var completionVelocity: CGFloat = 1.0

    public var percentComplete: CGFloat = 100.0

    public var transitionDuration: TimeInterval = 1

    public var isCancelled: Bool = false

    public var isInteractive: Bool = false

    public var initiallyInteractive: Bool = false

    public var presentationStyle: UIModalPresentationStyle = .currentContext

    public var isAnimated: Bool = false

    var animateAlongsideTransitionWasCalled = false

    public func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        return nil
    }

    public func view(forKey key: UITransitionContextViewKey) -> UIView? {
        return nil
    }

    var isInterruptible: Bool {
        return true
    }

    public func animate(alongsideTransition animation: ((UIViewControllerTransitionCoordinatorContext) -> Void)?, completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)? = nil) -> Bool {
        animateAlongsideTransitionWasCalled = true
        animation?(self)
        completion?(self)
        return true
    }

    func animateAlongsideTransition(in view: UIView?, animation: ((UIViewControllerTransitionCoordinatorContext) -> Void)?, completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)?) -> Bool {
        animation?(self)
        completion?(self)
        return true
    }

    public func notifyWhenInteractionEnds(_ handler: @escaping (UIViewControllerTransitionCoordinatorContext) -> Void) {
        return
    }

    public func notifyWhenInteractionChanges(_ handler: @escaping (UIViewControllerTransitionCoordinatorContext) -> Void) {
        return
    }
}
