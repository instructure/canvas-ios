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

/* @flow */

import googleForm from '../google-form'

const uri = 'https://docs.google.com/a/'

describe('google form', () => {
  it('returns uri without answers', () => {
    const form = googleForm(uri, {})
    expect(form({})).toEqual(uri)
  })

  it('can be configured with entries and pre-filled answers', () => {
    const form = googleForm(uri, {
      os: '1',
      osVersion: '2',
      device: '3',
    })

    const expected = 'https://docs.google.com/a/?entry.1=iOS&entry.2=0.1'
    expect(form({ os: 'iOS', osVersion: '0.1' })).toEqual(expected)
  })

  it('converts spaces to +', () => {
    const form = googleForm(uri, {
      os: '1',
      osVersion: '2',
      device: '3',
    })

    const expected = 'https://docs.google.com/a/?entry.1=iOS&entry.3=iPhone+7'
    expect(form({ os: 'iOS', device: 'iPhone 7' })).toEqual(expected)
  })
})
