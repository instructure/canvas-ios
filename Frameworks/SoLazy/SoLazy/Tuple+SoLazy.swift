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

public func blend<A,B,C>(tuple: (A,B), other: C) -> (A,B,C) {
    return (tuple.0, tuple.1, other)
}

public func blend<A,B,C>(other: A, tuple: (B,C)) -> (A,B,C) {
    return (other, tuple.0, tuple.1)
}

public func blend<A,B,C,D>(tuple: (A,B,C), other: D) -> (A,B,C,D) {
    return (tuple.0, tuple.1, tuple.2, other)
}

public func blend<A,B,C,D>(other: A, tuple: (B,C,D)) -> (A,B,C,D) {
    return (other, tuple.0, tuple.1, tuple.2)
}
