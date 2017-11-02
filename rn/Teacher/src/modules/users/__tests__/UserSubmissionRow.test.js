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

import React from 'react'
import UserSubmissionRow from '../UserSubmissionRow'

import renderer from 'react-test-renderer'

let templates = {
  ...require('../../../__templates__/assignments'),
  ...require('../../../__templates__/submissions'),
}

let defaultProps = {
  assignment: templates.assignment({ id: '1', points_possible: 10 }),
  submission: templates.submission({ id: '1', assignment_id: '1', score: 8, grade: 8 }),
  tintColor: '#fff',
}

describe('UserSubmissionRow', () => {
  it('renders', () => {
    let view = renderer.create(
      <UserSubmissionRow {...defaultProps} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })

  it('renders complete', () => {
    let assignment = templates.assignment({ id: '1', points_possible: 10, grading_type: 'complete_incomplete' })
    let submission = templates.submission({ id: '1', assignment_id: '1', score: 10, grade: 'complete' })

    let view = renderer.create(
      <UserSubmissionRow {...defaultProps} assignment={assignment} submission={submission} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })

  it('renders incomplete', () => {
    let assignment = templates.assignment({ id: '1', points_possible: 10, grading_type: 'complete_incomplete' })
    let submission = templates.submission({ id: '1', assignment_id: '1', score: 0, grade: 'incomplete' })

    let view = renderer.create(
      <UserSubmissionRow {...defaultProps} assignment={assignment} submission={submission} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })

  it('renders excused', () => {
    let submission = templates.submission({ id: '1', assignment_id: '1', excused: true })

    let view = renderer.create(
      <UserSubmissionRow {...defaultProps} submission={submission} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })

  it('renders needs grading', () => {
    let submission = templates.submission({ id: '1', assignment_id: '1', grade: null })

    let view = renderer.create(
      <UserSubmissionRow {...defaultProps} submission={submission} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })
})
