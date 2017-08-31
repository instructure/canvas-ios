// @flow

import React from 'react'
import { QuizSubmissionList, refreshQuizSubmissionData } from '../QuizSubmissionList'
import renderer from 'react-test-renderer'
import setProps from '../../../../../test/helpers/setProps'
import cloneDeep from 'lodash/cloneDeep'

const template = {
  ...require('../../../../__templates__/helm'),
  ...require('../../../../__templates__/quiz'),
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
}]

const props = {
  rows,
  pending: false,
  courseID: '12',
  quizID: template.quiz().id,
  quiz: { data: template.quiz() },
  refreshQuizSubmissions: jest.fn(),
  refreshEnrollments: jest.fn(),
  shouldRefresh: false,
  refreshing: false,
  refresh: jest.fn(),
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

  test('loads with nothing and it should not explode, and then props should be set and it should be great', () => {
    const tree = renderer.create(
      <QuizSubmissionList navigator={template.navigator()} />
    )
    expect(tree).toBeDefined()
    setProps(tree, props)
    expect(tree.getInstance().state.rows).toEqual(props.rows)
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

  test('set a filter and then clear out that filter', () => {
    const instance = renderer.create(
      <QuizSubmissionList {...props} navigator={template.navigator()} filterType='whatisthis' />
    ).getInstance()
    instance.updateFilter({
      filter: instance.filterOptions[2],
    })
    expect(instance.state.rows).toMatchObject([])
    instance.clearFilter()
    expect(instance.state.rows).toMatchObject(props.rows)
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
      { selectedFilter: undefined, studentIndex: 33 }
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
