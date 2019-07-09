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
