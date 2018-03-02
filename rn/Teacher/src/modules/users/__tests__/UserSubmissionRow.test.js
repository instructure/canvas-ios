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

/* eslint-disable flowtype/require-valid-file-annotation */

import React from 'react'
import UserSubmissionRow from '../UserSubmissionRow'

import renderer from 'react-test-renderer'

let templates = {
  ...require('../../../__templates__/assignments'),
  ...require('../../../__templates__/submissions'),
}

const assignment = templates.assignment({ id: '1', points_possible: 10 })

let defaultProps = {
  submission: templates.submission({
    id: '1',
    assignment_id: '1',
    score: 8,
    grade: 8,
    submission_status: 'submitted',
    grading_status: 'graded',
    assignment }),
  tintColor: '#fff',
}

describe('UserSubmissionRow', () => {
  it('renders', () => {
    let view = renderer.create(
      <UserSubmissionRow {...defaultProps} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })

  it('renders published', () => {
    let props = {
      ...defaultProps,
    }
    props.submission.assignment = templates.assignment({ id: '1', points_possible: 10, published: true })
    let view = renderer.create(
      <UserSubmissionRow {...props} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })

  it('renders online quiz', () => {
    let props = {
      ...defaultProps,
    }
    props.submission.assignment = templates.assignment({ id: '1', points_possible: 10, submission_types: ['online_quiz'] })
    let view = renderer.create(
      <UserSubmissionRow {...props} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })

  it('renders discussion', () => {
    let props = {
      ...defaultProps,
    }
    props.submission.assignment = templates.assignment({ id: '1', points_possible: 10, submission_types: ['discussion_topic'] })
    let view = renderer.create(
      <UserSubmissionRow {...props} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })

  it('renders missing submittion types', () => {
    let props = {
      ...defaultProps,
    }
    props.submission.assignment = templates.assignment({ id: '1', points_possible: 10, submission_types: null })
    let view = renderer.create(
      <UserSubmissionRow {...props} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })

  it('renders complete', () => {
    let submission = templates.submission({ id: '1', assignment_id: '1', score: 10, grade: 'complete', submission_status: 'submitted', grading_status: 'graded' })
    submission.assignment = templates.assignment({ id: '1', points_possible: 10, grading_type: 'complete_incomplete' })

    let view = renderer.create(
      <UserSubmissionRow {...defaultProps} submission={submission} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })

  it('renders incomplete', () => {
    let submission = templates.submission({ id: '1', assignment_id: '1', score: 0, grade: 'incomplete', submission_status: 'submitted', grading_status: 'graded' })
    submission.assignment = templates.assignment({ id: '1', points_possible: 10, grading_type: 'complete_incomplete' })

    let view = renderer.create(
      <UserSubmissionRow {...defaultProps} submission={submission} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })

  it('renders excused', () => {
    let submission = templates.submission({ id: '1', assignment_id: '1', excused: true, assignment })

    let view = renderer.create(
      <UserSubmissionRow {...defaultProps} submission={submission} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })

  it('renders needs grading', () => {
    let submission = templates.submission({ id: '1', assignment_id: '1', grade: null, submission_status: 'submitted', grading_status: 'needs_grading', assignment })

    let view = renderer.create(
      <UserSubmissionRow {...defaultProps} submission={submission} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })
})
