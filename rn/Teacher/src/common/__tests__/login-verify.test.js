//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
