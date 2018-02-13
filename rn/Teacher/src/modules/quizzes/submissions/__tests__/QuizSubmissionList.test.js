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
import { QuizSubmissionList, refreshQuizSubmissionData } from '../QuizSubmissionList'
import renderer from 'react-test-renderer'
import cloneDeep from 'lodash/cloneDeep'

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
      { modal: true, modalPresentationStyle: 'fullscreen' },
      { filter: instance.state.filter, studentIndex: 33 }
    )
  })

  test('navigate to submission settings', () => {
    let localProps = cloneDeep(props)
    localProps.quiz.data.assignment_id = '1'
    let navigator = template.navigator()

    let tree = renderer.create(
      <QuizSubmissionList {...localProps} navigator={navigator} filterType='whatisthis' />
    )

    expect(tree.toJSON()).toMatchSnapshot()
    tree.getInstance().openSubmissionSettings()
    expect(navigator.show).toHaveBeenCalledWith(
      `/courses/12/assignments/1/submission_settings`,
      { modal: true },
    )
  })

  test('refresh function', () => {
    refreshQuizSubmissionData(props)
    expect(props.refreshQuizSubmissions).toHaveBeenCalledWith(props.courseID, props.quizID)
    expect(props.refreshEnrollments).toHaveBeenCalledWith(props.courseID)
  })
})
