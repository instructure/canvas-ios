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

// @flow

import {
  NativeModules,
  NativeEventEmitter,
} from 'react-native'

import api from './'
import i18n from 'format-message'

const { APIBridge } = NativeModules

export async function handleAPIBridgeRequest (body: any) {
  const { requestID, args, name } = body
  const apiCall = api[name]
  if (!apiCall) {
    throw new Error(`${name} cannot be found in the API bridge. Check the name of the api you are trying to call.`)
  }

  try {
    let result = await apiCall(...args)
    return APIBridge.requestCompleted(requestID, result.data, null)
  } catch (e) {
    return APIBridge.requestCompleted(requestID, null, i18n('Request could not be completed.'))
  }
}

export default function setup () {
  const apiBridgeEmitter = new NativeEventEmitter(APIBridge)
  apiBridgeEmitter.addListener('APICall', handleAPIBridgeRequest)
}
