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

import { NativeModules } from 'react-native'
import canvas from '../canvas-api'

// if the user has an invalid login, the promise will send `true`. Otherwise it will send `false`
export default async function loginVerify (): Promise<boolean> {
  return new Promise((resolve, reject) => {
    canvas.getUserProfile('self')
      .then(() => resolve(false))
      .catch((e) => {
        if (e.response && e.response.status === 401) {
          resolve(true)
          NativeModules.NativeLogin.logout()
        } else {
          resolve(false)
        }
      })
  })
}
