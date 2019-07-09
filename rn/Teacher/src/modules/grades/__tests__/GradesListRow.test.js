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

// @flow

import React from 'react'
import GradesListRow from '../GradesListRow'
import * as templates from '../../../__templates__'
import { shallow } from 'enzyme'

describe('grades list row', () => {
  it('renders correctly', () => {
    let assignment = templates.assignment({ due_at: null })
    assignment.needs_grading_count = 0
    let tree = shallow(
      <GradesListRow assignment={assignment} tintColor='#fff' />
    )
    expect(tree).toMatchSnapshot()
  })

  it('renders correctly with selected props', () => {
    let assignment = templates.assignment({ due_at: null })
    assignment.needs_grading_count = 0
    let tree = shallow(
      <GradesListRow assignment={assignment} tintColor='#fff' underlayColor='#eee' selected />
    )
    expect(tree.find('Row').props().selected).toEqual(true)
  })

  it('renders the gradeProp when there is a submission', () => {
    let assignment = templates.assignment({
      submission: templates.submission(),
    })
    let tree = shallow(<GradesListRow assignment={assignment} />)
    expect(tree.find('Row').props().accessories).not.toBeUndefined()
  })

  it('renders the submission status label', () => {
    let assignment = templates.assignment({
      submission: templates.submission(),
    })
    let tree = shallow(<GradesListRow assignment={assignment} />)
    expect(tree.find('SubmissionStatusLabel').length).toEqual(1)
  })

  it('hides the submission status label if not_graded', () => {
    let assignment = templates.assignment({
      submission: templates.submission(),
      grading_type: 'not_graded',
    })
    let tree = shallow(<GradesListRow assignment={assignment} />)
    expect(tree.find('SubmissionStatusLabel').length).toEqual(0)
  })

  it('renders correctly assignment icon', () => {
    let assignment = templates.assignment({ submission_types: ['on_paper'] })
    let tree = shallow(<GradesListRow assignment={assignment} />).dive()
    expect(
      tree.find(`[testID="grades-list-row-assignment-icon-published-${assignment.id}.icon-img"]`).length
    ).toEqual(1)
  })

  it('renders correctly quiz icon', () => {
    let assignment = templates.assignment({ submission_types: ['online_quiz'] })
    let tree = shallow(<GradesListRow assignment={assignment} />).dive()
    expect(
      tree.find(`[testID="grades-list-row-quiz-icon-published-${assignment.id}.icon-img"]`).length
    ).toEqual(1)
  })

  it('renders correctly discussion icon', () => {
    let assignment = templates.assignment({ submission_types: ['discussion_topic'] })
    let tree = shallow(<GradesListRow assignment={assignment} />).dive()
    expect(
      tree.find(`[testID="grades-list-row-discussion-icon-published-${assignment.id}.icon-img"]`).length
    ).toEqual(1)
  })

  it('renders correctly unpublished quiz icon', () => {
    let assignment = templates.assignment({ submission_types: ['online_quiz'], published: false })
    let tree = shallow(<GradesListRow assignment={assignment} />).dive()
    expect(
      tree.find(`[testID="grades-list-row-quiz-icon-not-published-${assignment.id}.icon-img"]`).length
    ).toEqual(1)
  })

  it('passes assignment to onPress handler', () => {
    const assignment = templates.assignment()
    const onPress = jest.fn()
    const tree = shallow(<GradesListRow assignment={assignment} onPress={onPress} />)
    tree.find('[onPress]').simulate('Press')
    expect(onPress).toHaveBeenCalledWith(assignment)
  })
})
