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

// @flow

import Reducer, { Action } from 'redux'

// given a bunch of reducers, just call them one after the other
export default function composeReducers<S, A: Action> (
  ...reducers: Reducer<S, A>[]
): Reducer<S, A> {
  return (initialState, action) => {
    return reducers.reduce((state, reducer) => {
      return reducer(state, action)
    }, initialState)
  }
}
