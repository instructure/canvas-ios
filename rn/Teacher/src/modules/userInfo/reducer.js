//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

/* @flow */

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import Actions from './actions'
import handleAsync from '../../utils/handleAsync'
import { getSession } from '../../canvas-api/session'
import i18n from 'format-message'

const {
  refreshCanActAsUser,
  updateShowGradesOnDashboard,
  refreshAccountExternalTools,
  refreshHelpLinks,
  getUserSettings,
  updateUserSettings,
} = Actions
const defaultState: UserInfo = {
  canActAsUser: false,
  showsGradesOnCourseCards: false,
  externalTools: [],
  userSettings: {},
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

export function defaultHelpLinks () {
  const reportAProblem = {
    id: 'report_a_problem',
    type: 'default',
    available_to: [
      'user',
      'student',
      'teacher',
    ],
    text: i18n('Report a Problem'),
    url: '#create_ticket',
  }

  return {
    help_link_name: i18n('Help'),
    help_link_icon: 'help',
    default_help_links: [reportAProblem],
    custom_help_links: [],
  }
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
  [refreshHelpLinks.toString()]: handleAsync({
    resolved: (state, { result: { data } }) => ({
      ...state,
      helpLinks: data,
    }),
    rejected: (state) => {
      // In case this request fails, fallback to default help links
      return {
        ...state,
        helpLinks: defaultHelpLinks(),
      }
    },
  }),
  [refreshCanActAsUser.toString()]: handleAsync({
    pending: (state) => {
      return state
    },
    resolved: (state, { result: { data } }) => {
      return {
        ...state,
        canActAsUser: isSiteAdmin() || data.become_user === true,
      }
    },
    rejected: (state) => {
      return {
        ...state,
        canActAsUser: false || isSiteAdmin(),
      }
    },
  }),
  [updateShowGradesOnDashboard.toString()]: (state, { payload }) => {
    return { ...state, ...payload }
  },
  [getUserSettings.toString()]: handleAsync({
    resolved: (state, { result: { data } }) => {
      return {
        ...state,
        userSettings: data,
      }
    },
  }),
  [updateUserSettings.toString()]: handleAsync({
    pending: (state, { hideOverlay }) => ({
      ...state,
      userSettings: {
        ...state.userSettings,
        hide_dashcard_color_overlays: hideOverlay,
      },
    }),
    rejected: (state, { hideOverlay }) => ({
      ...state,
      userSettings: {
        ...state.userSettings,
        hide_dashcard_color_overlays: !hideOverlay,
      },
    }),
  }),
}, defaultState)
