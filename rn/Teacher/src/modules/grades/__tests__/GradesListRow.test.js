//
// Copyright (C) 2018-present Instructure, Inc.
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
