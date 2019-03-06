//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/* eslint-disable flowtype/require-valid-file-annotation */

import { NativeModules } from 'react-native'
import canvas from '../../canvas-api'
import loginVerify from '../login-verify'

describe('loginVerify', () => {
  it('logs out if user profile returns 401', async () => {
    canvas.getUserProfile.mockReturnValueOnce(Promise.resolve())
    expect(await loginVerify()).toBe(false)
    expect(NativeModules.NativeLogin.logout).not.toHaveBeenCalled()

    canvas.getUserProfile.mockReturnValueOnce(Promise.reject(new Error()))
    expect(await loginVerify()).toBe(false)
    expect(NativeModules.NativeLogin.logout).not.toHaveBeenCalled()

    const notAuth = new Error()
    notAuth.response = { status: 401 }
    canvas.getUserProfile.mockReturnValueOnce(Promise.reject(notAuth))
    expect(await loginVerify()).toBe(true)
    expect(NativeModules.NativeLogin.logout).toHaveBeenCalled()
  })
})
