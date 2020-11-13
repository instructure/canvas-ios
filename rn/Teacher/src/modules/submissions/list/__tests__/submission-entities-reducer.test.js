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

import { submissions } from '../submission-entities-reducer'
import Actions from '../actions'

const { refreshSubmissions, getUserSubmissions } = Actions
const templates = {
  ...require('../../../../__templates__/submissions'),
}

describe('refreshSubmissions', () => {
  it('captures entities', () => {
    let data = [
      { id: 1 },
      { id: 2 },
    ].map(override => templates.submissionHistory([override]))

    const action = {
      type: refreshSubmissions.toString(),
      payload: { result: { data } },
    }

    expect(submissions({}, action)).toEqual({
      '1': {
        submission: data[0],
        pending: 0,
        error: null,
        selectedAttachmentIndex: 0,
      },
      '2': {
        submission: data[1],
        pending: 0,
        error: null,
        selectedAttachmentIndex: 0,
      },
    })
  })
})

describe('getUserSubmissions', () => {
  it('captures entities from getUserSubmissions', () => {
    let data = [
      { id: '1' },
      { id: '2' },
    ].map(override => templates.submissionHistory([override]))

    const action = {
      type: getUserSubmissions.toString(),
      payload: { result: { data } },
    }

    expect(submissions({}, action)).toEqual({
      '1': {
        submission: data[0],
        pending: 0,
        error: null,
        selectedAttachmentIndex: 0,
      },
      '2': {
        submission: data[1],
        pending: 0,
        error: null,
        selectedAttachmentIndex: 0,
      },
    })
  })
})
