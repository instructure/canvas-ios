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
import { QuizSubmissionList, refreshQuizSubmissionData } from '../QuizSubmissionList'
import renderer from 'react-test-renderer'
import cloneDeep from 'lodash/cloneDeep'
import { shallow } from 'enzyme'

const template = {
  ...require('../../../../__templates__/helm'),
  ...require('../../../../__templates__/quiz'),
  ...require('../../../../__templates__/section'),
}

jest.mock('../../../../routing')

const rows = [{
  userID: '1',
  avatarURL: 'http://www.fillmurray.com/200/300',
  name: 'Bill Murray',
  status: 'submitted',
  grade: '8',
  score: 8,
  disclosure: true,
  sectionID: '1',
}]

const props = {
  rows,
  pending: false,
  courseID: '12',
  quizID: template.quiz().id,
  quiz: { data: template.quiz() },
  refreshQuizSubmissions: jest.fn(),
  refreshEnrollments: jest.fn(),
  refreshSections: jest.fn(),
  shouldRefresh: false,
  refreshing: false,
  refresh: jest.fn(),
  sections: [template.section({ id: '1' })],
  getCourseEnabledFeatures: jest.fn(),
}

describe('QuizSubmissionList', () => {
  test('loads correctly when data is supplied', () => {
    const tree = renderer.create(
      <QuizSubmissionList {...props} navigator={template.navigator()} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  test('loads while pending', () => {
    const tree = renderer.create(
      <QuizSubmissionList {...props} navigator={template.navigator()} pending={true} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  test('loads with a filter type', () => {
    const tree = renderer.create(
      <QuizSubmissionList {...props} navigator={template.navigator()} filterType='graded' />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  test('loads with a filter type that does not exist and it should not explode', () => {
    const tree = renderer.create(
      <QuizSubmissionList {...props} navigator={template.navigator()} filterType='whatisthis' />
    ).toJSON()
    expect(tree).toBeDefined()
  })

  test('do not navigate to speedgrader if you do not have an assignment id', () => {
    const navigator = template.navigator()
    const instance = renderer.create(
      <QuizSubmissionList {...props} navigator={navigator} filterType='whatisthis' />
    ).getInstance()
    instance.navigateToSubmission(33)('1')
    expect(navigator.show).not.toHaveBeenCalled()
  })

  test('navigate to speedgrader', () => {
    const localProps = cloneDeep(props)
    localProps.quiz.data.assignment_id = '1'
    const navigator = template.navigator()
    const instance = renderer.create(
      <QuizSubmissionList {...localProps} navigator={navigator} filterType='whatisthis' />
    ).getInstance()
    instance.navigateToSubmission(33)('1')
    expect(navigator.show).toHaveBeenCalledWith(
      '/courses/12/assignments/1/submissions/1',
      { modal: true, modalPresentationStyle: 'fullscreen', embedInNavigationController: false },
      { filter: instance.state.filter, studentIndex: 33 }
    )
  })

  test('shows the practice quiz snackbar message when row is pressed', () => {
    let tree = shallow(
      <QuizSubmissionList {...props} />
    )

    let showSnackbar = jest.fn()
    tree.instance().showSnackbar = showSnackbar

    let row = shallow(
      tree.instance().renderRow({ item: props.rows[0], index: 0 })
    )

    row.simulate('press')

    expect(showSnackbar).toHaveBeenCalled()
  })

  test('refresh function', () => {
    refreshQuizSubmissionData(props)
    expect(props.refreshQuizSubmissions).toHaveBeenCalledWith(props.courseID, props.quizID)
    expect(props.refreshEnrollments).toHaveBeenCalledWith(props.courseID)
  })
})
