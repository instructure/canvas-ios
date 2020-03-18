//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

// Modified from https://github.com/corymsmith/react-native-fabric

// @flow

import { NativeModules } from 'react-native'
const CanvasCrashlytics = NativeModules.CanvasCrashlytics

export const Crashlytics = {
  crash: CanvasCrashlytics.crash,
  throwException: CanvasCrashlytics.throwException,

  recordError: function (error: mixed) {
    var newError

    if (typeof error === 'string' || error instanceof String) {
      newError = { domain: error }
    } else if (typeof error === 'number') {
      newError = { code: error }
    } else if (typeof error === 'object') {
      newError = {}

      // Pass everything in as a string or number to be safe
      for (var k in error) {
        if (error.hasOwnProperty(k)) {
          if (
            typeof error[k] !== 'number' &&
            typeof error[k] !== 'string' &&
            !(error[k] instanceof String)
          ) {
            newError[k] = JSON.stringify(error[k])
          } else {
            newError[k] = error[k]
          }
        }
      }
    } else {
      // Array?
      // Fall back on JSON
      newError = {
        json: JSON.stringify(error),
      }
    }
    CanvasCrashlytics.recordError(newError)
  },

  logException: function (value: string) {
    CanvasCrashlytics.logException(value)
  },

  log: function (message: string) {
    CanvasCrashlytics.log(message)
  },

  setUserIdentifier: function (userIdentifier: string | null) {
    CanvasCrashlytics.setUserIdentifier(userIdentifier)
  },

  setBool: function (key: string, value: boolean) {
    CanvasCrashlytics.setBool(key, value)
  },

  setString: function (key: string, value: string) {
    CanvasCrashlytics.setString(key, value)
  },
}
