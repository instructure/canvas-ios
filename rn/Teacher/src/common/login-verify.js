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

// @flow

import { NativeModules } from 'react-native'
import canvas, { getSession } from '../canvas-api'
import { logEvent } from './CanvasAnalytics'

// if the user has an invalid login, the promise will send `true`. Otherwise it will send `false`
export default async function loginVerify (): Promise<boolean> {
  return new Promise((resolve, reject) => {
    canvas.getUserProfile('self')
      .then(() => resolve(false))
      .catch((e) => {
        const isFakeStudent = getSession()?.isFakeStudent === true
        if (e.response && e.response.status === 401 && !isFakeStudent) {
          resolve(true)
          logEvent('auto_logout_401')
          NativeModules.NativeLogin.logout()
        } else {
          resolve(false)
        }
      })
  })
}
