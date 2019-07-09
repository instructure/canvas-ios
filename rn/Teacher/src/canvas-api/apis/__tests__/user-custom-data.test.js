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

import { constructNamespace } from '../user-custom-data'
import { setSession } from '../../session'

const template = {
  ...require('../../../__templates__/session'),
}

describe('test constructNamespace', () => {
  it('constructNamespace handles empty string as expected', () => {
    setSession(template.session({ baseURL: '' }))
    expect(constructNamespace()).toBe('')
  })

  it('constructNamespace handles domain only', () => {
    setSession(template.session({ baseURL: 'twilson' }))
    expect(constructNamespace()).toBe('com.twilson.canvas-app')
  })

  it('constructNamespace handles domain and slash', () => {
    setSession(template.session({ baseURL: 'twilson/' }))
    expect(constructNamespace()).toBe('com.twilson.canvas-app')
  })

  it('constructNamespace handles subdomain', () => {
    setSession(template.session({ baseURL: 'twilson.instructure.com' }))
    expect(constructNamespace()).toBe('com.twilson.canvas-app')
  })

  it('constructNamespace handles subdomain with https', () => {
    setSession(template.session({ baseURL: 'https://twilson.instructure.com' }))
    expect(constructNamespace()).toBe('com.twilson.canvas-app')
  })

  it('constructNamespace handles null session', () => {
    setSession(undefined)
    expect(constructNamespace()).toBe('')
  })
})
