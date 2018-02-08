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

import i18n from 'format-message'
import setup, { sanitizeLocale } from '../setup'

describe('locale setup', () => {
  it('should work', () => {
    // $FlowFixMe
    i18n.setup = jest.fn()
    setup('en_US')
    expect(i18n.setup).toBeCalled()
  })
})

describe('sanitize locale', () => {
  it('should work with apple locale', () => {
    const sanitized = sanitizeLocale('en_US')
    expect(sanitized).toEqual('en-US')
  })

  it('should work with all the weird apple stuff', () => {
    const sanitized = sanitizeLocale('en_US@calendar=gregorian')
    expect(sanitized).toEqual('en-US')
  })

  it('handles missing locale', () => {
    const sanitized = sanitizeLocale(null)
    expect(sanitized).toEqual('en')
  })
})
