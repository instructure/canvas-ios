//
// Copyright (C) 2017-present Instructure, Inc.
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
