// @flow

import React from 'react'
import UserSubmissionRow from '../UserSubmissionRow'

import renderer from 'react-test-renderer'

let templates = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/submissions'),
}

let defaultProps = {
  assignment: templates.assignment({ id: '1', points_possible: 10 }),
  submission: templates.submission({ id: '1', assignment_id: '1', score: 8 }),
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
})
