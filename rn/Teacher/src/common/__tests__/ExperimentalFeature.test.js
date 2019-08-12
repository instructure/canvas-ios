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

/* eslint-disable flowtype/require-valid-file-annotation */

import { setSession } from '../../canvas-api'
import * as templates from '../../__templates__'
import ExperimentalFeature from '../ExperimentalFeature'

describe('ExperimentalFeature', () => {
  let allEnabled = ExperimentalFeature.allEnabled
  afterEach(() => {
    ExperimentalFeature.allEnabled = allEnabled
  })

  it('calculates isEnabled', () => {
    ExperimentalFeature.allEnabled = false
    expect(new ExperimentalFeature(false).isEnabled).toEqual(false)
    expect(new ExperimentalFeature(true).isEnabled).toEqual(true)

    setSession(templates.session({ baseURL: 'https://canvas.beta.instructure.com' }))
    expect(new ExperimentalFeature('beta').isEnabled).toEqual(true)
    setSession(templates.session({ baseURL: 'https://canvas.instructure.com' }))
    expect(new ExperimentalFeature('beta').isEnabled).toEqual(false)
    setSession(null)
    expect(new ExperimentalFeature('beta').isEnabled).toEqual(false)

    setSession(templates.session({ baseURL: 'https://a.edu' }))
    expect(new ExperimentalFeature([ 'a.edu' ]).isEnabled).toEqual(true)
    expect(new ExperimentalFeature([ 'a.ed' ]).isEnabled).toEqual(false)
    expect(new ExperimentalFeature([ 'b.edu' ]).isEnabled).toEqual(false)
    setSession(null)
    expect(new ExperimentalFeature([ 'a.edu' ]).isEnabled).toEqual(false)

    ExperimentalFeature.allEnabled = true
    expect(new ExperimentalFeature(false).isEnabled).toEqual(true)
  })
})
