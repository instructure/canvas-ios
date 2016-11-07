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
import ReactiveCocoa
import Result

public class ProgressDispatcher: NSObject {
    private var pipe = Signal<Progress, NoError>.pipe()
    
    public var onProgress: Signal<Progress, NoError> {
        return pipe.0
    }
    
    public func dispatch(progress: Progress) {
        pipe.1.sendNext(progress)
    }
}


