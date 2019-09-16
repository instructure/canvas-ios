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

/* eslint-disable flowtype/require-valid-file-annotation */

import React from 'react'
import UserSubmissionRow from '../UserSubmissionRow'

import renderer from 'react-test-renderer'
import { shallow } from 'enzyme'

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

  it('doesnt accidently send NaN through the bridge', () => {
    let submission = templates.submission({
      grading_status: 'graded',
      assignment: templates.assignment({ points_possible: 0 }),
    })

    let view = shallow(
      <UserSubmissionRow {...defaultProps} submission={submission} />
    )
    let props = view.find('LinearGradient').props()
    expect(props.style.flex).toEqual(1)
  })
})
