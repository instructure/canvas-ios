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

import { handleActions } from 'redux-actions'
import handleAsync from '../../utils/handleAsync'
import { parseErrorMessage } from '../../redux/middleware/error-handler'
import Actions from './actions'

const { refreshLTITools } = Actions

const attendanceTool = handleActions({
  [refreshLTITools.toString()]: handleAsync({
    pending: state => ({ ...state, pending: state.pending + 1, error: undefined }),
    resolved: (state, { result }: { result: { data: Array<LtiLaunchDefinition> } }) => {
      let id = null
      for (let i = 0; i < result.data.length; ++i) {
        let tool = result.data[i]
        let courseNav = tool.placements.course_navigation
        if (!courseNav) {
          continue
        }
        if (courseNav.url.includes('rollcall.instructure.com') ||
          courseNav.url.includes('rollcall.beta.instructure.com')) {
          id = tool.definition_id
          break
        }
      }

      return {
        pending: state.pending - 1,
        tabID: id ? `context_external_tool_${id}` : null,
        error: undefined,
      }
    },
    rejected: (state, { error }) => ({
      ...state,
      error: parseErrorMessage(error),
      pending: state.pending - 1,
    }),
  }),
}, { pending: 0 })

export default (attendanceTool: *)
