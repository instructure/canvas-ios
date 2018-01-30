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

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import { default as ListActions } from './list/actions'

const { refreshedToDo } = ListActions

const defaultState = {
  needsGrading: {},
}

export const toDo: Reducer<ToDoState, any> = handleActions({
  [refreshedToDo.toString()]: (state, { payload: { items } }) => {
    if (!items.length) {
      return {
        ...state,
        needsGrading: [],
      }
    }
    const needsGrading = items
      .filter(item => item.type === 'grading' && item.course_id && (item.assignment || item.quiz))
      .reduce((memo, item) => {
        const type = item.assignment ? 'assignment' : 'quiz'
        const id = item.assignment && item.assignment.id || item.quiz && item.quiz.id
        return {
          ...memo,
          [`${item.course_id}-${type}-${id}`]: item,
        }
      }, state.needsGrading)
    return { ...state, needsGrading }
  },
}, defaultState)

export default (toDo: *)
