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
import ReactiveSwift
import Result

open class ProgressDispatcher: NSObject {
    fileprivate let dispatcher: Dispatcher<Progress, Progress, NSError>

    public override init() {
        dispatcher = Dispatcher { SignalProducer(value: $0) }
        super.init()
    }

    open var onProgress: Signal<Progress, NoError> {
        return dispatcher.values
    }

    open func dispatch(_ progress: Progress) {
        dispatcher.apply(progress).start()
    }
}
