//
// Copyright (C) 2016-present Instructure, Inc.
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
