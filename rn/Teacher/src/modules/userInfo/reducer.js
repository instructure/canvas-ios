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

/* @flow */

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import Actions from './actions'
import handleAsync from '@utils/handleAsync'
import { getSession } from '@canvas-api/session'

const { refreshCanMasquerade, updateShowGradesOnDashboard, refreshAccountExternalTools } = Actions
const defaultState: UserInfo = {
  canMasquerade: false,
  showsGradesOnCourseCards: false,
  externalTools: [],
}

function isSiteAdmin () {
  const session = getSession()
  return Boolean(session.baseURL.match(/siteadmin/))
}

const isGauge = (tool: ExternalToolLaunchDefinition) => {
  if (tool.domain) return tool.domain === 'gauge.instructure.com'
  const url = (tool.placements.global_navigation || {}).url
  return /gauge-\w+(\.inseng\.net|-prod\.instructure\.com)/.test(url)
}

const isArc = (tool: ExternalToolLaunchDefinition) => {
  if (tool.domain) return tool.domain === 'arc.instructure.com'
  const url = (tool.placements.global_navigation || {}).url
  return /arc-\w+(\.inseng\.net|-prod\.instructure\.com)/.test(url)
}

export const userInfo: Reducer<UserInfo, any> = handleActions({
  [refreshAccountExternalTools.toString()]: handleAsync({
    resolved: (state, { result }) => {
      let externalTools = result.data.reduce((globalNav, tool) => {
        if (isGauge(tool) || isArc(tool)) globalNav.push(tool)
        return globalNav
      }, [])
      return {
        ...state,
        externalTools,
      }
    },
  }),
  [refreshCanMasquerade.toString()]: handleAsync({
    pending: (state) => {
      return state
    },
    resolved: (state, { result: { data } }) => {
      return {
        ...state,
        canMasquerade: isSiteAdmin() || data.become_user === true,
      }
    },
    rejected: (state) => {
      return {
        ...state,
        canMasquerade: false || isSiteAdmin(),
      }
    },
  }),
  [updateShowGradesOnDashboard.toString()]: (state, { payload }) => {
    return { ...state, ...payload }
  },
}, defaultState)
