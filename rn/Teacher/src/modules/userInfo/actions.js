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

import { createAction } from 'redux-actions'
import canvas from '../../canvas-api'

export let UserInfoActions = (api: CanvasApi): * => ({
  refreshAccountExternalTools: createAction('userInfo.refreshAccountExternalTools', () => {
    return {
      promise: api.refreshAccountExternalTools(),
    }
  }),
  refreshHelpLinks: createAction('userInfo.refreshHelpLinks', () => ({
    promise: api.getHelpLinks(),
    handlesError: true,
  })),
  refreshCanActAsUser: createAction('userInfo.canActAsUser', () => {
    return {
      promise: api.becomeUserPermissions('self'),
      handlesError: true,
    }
  }),
  updateShowGradesOnDashboard: createAction('userInfo.updateShowGradesOnDashboard', (showsGradesOnCourseCards: boolean) => {
    return { showsGradesOnCourseCards }
  }),
  getUserSettings: createAction('userInfo.getUserSettings', (userID: string = 'self') => {
    return {
      promise: api.getUserSettings(userID),
    }
  }),
  updateUserSettings: createAction('userInfo.updateUserSettings', (userID: string = 'self', hideOverlay: boolean) => {
    return {
      promise: api.updateUserSettings(userID, hideOverlay),
      hideOverlay,
    }
  }),
})

export default (UserInfoActions(canvas): *)
