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

import { shallow } from 'enzyme'
import React from 'react'
import UserSubmissionRow from '../UserSubmissionRow'
import * as templates from '../../../__templates__'

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
  it('renders published', () => {
    let props = {
      ...defaultProps,
    }
    props.submission.assignment = templates.assignment({ id: '1', points_possible: 10, published: true })
    let tree = shallow(<UserSubmissionRow {...props} />)
    let image = shallow(tree.find('Row').prop('renderImage')())
    expect(image.find('AccessIcon').prop('entry')).toBe(props.submission.assignment)
  })

  it('renders online quiz', () => {
    let props = {
      ...defaultProps,
    }
    props.submission.assignment = templates.assignment({ id: '1', points_possible: 10, submission_types: ['online_quiz'] })
    let tree = shallow(<UserSubmissionRow {...props} />)
    let image = shallow(tree.find('Row').prop('renderImage')())
    expect(image.find('AccessIcon').prop('image')).toEqual({ uri: 'quizLine' })
  })

  it('renders discussion', () => {
    let props = {
      ...defaultProps,
    }
    props.submission.assignment = templates.assignment({ id: '1', points_possible: 10, submission_types: ['discussion_topic'] })
    let tree = shallow(<UserSubmissionRow {...props} />)
    let image = shallow(tree.find('Row').prop('renderImage')())
    expect(image.find('AccessIcon').prop('image')).toEqual({ uri: 'discussionLine' })
  })

  it('renders missing submission types', () => {
    let props = {
      ...defaultProps,
    }
    props.submission.assignment = templates.assignment({ id: '1', points_possible: 10, submission_types: null })
    let tree = shallow(<UserSubmissionRow {...props} />)
    let image = shallow(tree.find('Row').prop('renderImage')())
    expect(image.find('AccessIcon').prop('image')).toEqual({ uri: 'assignmentLine' })
  })

  it('renders complete', () => {
    let submission = templates.submission({ id: '1', assignment_id: '1', score: 10, grade: 'complete', submission_status: 'submitted', grading_status: 'graded' })
    submission.assignment = templates.assignment({ id: '1', points_possible: 10, grading_type: 'complete_incomplete' })
    let tree = shallow(<UserSubmissionRow {...defaultProps} submission={submission} />)
    expect(tree.find('OldSubmissionStatusLabel').prop('status')).toBe('submitted')
    expect(tree.find('Text').prop('children')).toBe('Complete')
  })

  it('renders incomplete', () => {
    let submission = templates.submission({ id: '1', assignment_id: '1', score: 0, grade: 'incomplete', submission_status: 'submitted', grading_status: 'graded' })
    submission.assignment = templates.assignment({ id: '1', points_possible: 10, grading_type: 'complete_incomplete' })
    let tree = shallow(<UserSubmissionRow {...defaultProps} submission={submission} />)
    expect(tree.find('OldSubmissionStatusLabel').prop('status')).toBe('submitted')
    expect(tree.find('Text').prop('children')).toBe('Incomplete')
  })

  it('renders excused', () => {
    let submission = templates.submission({ id: '1', assignment_id: '1', excused: true, assignment })
    let tree = shallow(<UserSubmissionRow {...defaultProps} submission={submission} />)
    expect(tree.find('OldSubmissionStatusLabel').prop('status')).toBe('excused')
  })

  it('renders needs grading', () => {
    let submission = templates.submission({ id: '1', assignment_id: '1', grade: null, submission_status: 'submitted', grading_status: 'needs_grading', assignment })
    let tree = shallow(<UserSubmissionRow {...defaultProps} submission={submission} />)
    expect(tree.find('Token').prop('children')).toBe('Needs Grading')
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
