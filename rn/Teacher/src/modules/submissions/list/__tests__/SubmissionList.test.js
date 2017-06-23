// @flow

import React from 'react'
import { AlertIOS } from 'react-native'
import {
  SubmissionList,
  refreshSubmissionList,
  shouldRefresh,
} from '../SubmissionList'
import renderer from 'react-test-renderer'
import { submissionProps } from './map-state-to-props.test'
import setProps from '../../../../../test/helpers/setProps'
import cloneDeep from 'lodash/cloneDeep'

const template = {
  ...require('../../../../__templates__/helm'),
  ...require('../__templates__/submission-props'),
}

jest
  .mock('../../../../routing')
  .mock('AlertIOS', () => ({
    alert: jest.fn(),
  }))
  .mock('knuth-shuffle-seeded', () => jest.fn())

const props = {
  submissions: submissionProps,
  pending: false,
  courseID: '12',
  assignmentID: '32',
  courseColor: '#ddd',
  courseName: 'fancy name',
  refreshSubmissions: jest.fn(),
  refreshEnrollments: jest.fn(),
  refreshGroupsForCourse: jest.fn(),
  shouldRefresh: false,
  refreshing: false,
  refresh: jest.fn(),
  anonymous: false,
  muted: false,
  groupAssignment: null,
}

beforeEach(() => jest.resetAllMocks())

test('SubmissionList loaded', () => {
  const tree = renderer.create(
    <SubmissionList {...props} navigator={template.navigator()} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('SubmissionList loaded with nothing and it should not explode, and then props should be set and it should be great', () => {
  const tree = renderer.create(
    <SubmissionList {...props} navigator={template.navigator()} />
  )
  expect(tree).toBeDefined()
  setProps(tree, props)
  expect(tree.getInstance().state.submissions).toEqual(props.submissions)
})

test('SubmissionList select filter function', () => {
  const expandedProps = cloneDeep(props)
  expandedProps.submissions = expandedProps.submissions.concat([
    template.submissionProps({
      name: 'S5',
      status: 'submitted',
      grade: '60',
      score: 60,
      userID: '5',
    }),
    template.submissionProps({
      name: 'S6',
      status: 'submitted',
      grade: '30',
      score: 30,
      userID: '6',
    }),
  ])

  const instance = renderer.create(
    <SubmissionList { ...expandedProps } navigator={template.navigator()} />
  ).getInstance()

  instance.updateFilter({
    filter: instance.filterOptions[0],
  })
  expect(instance.state.submissions).toMatchObject(expandedProps.submissions)

  instance.updateFilter({
    filter: instance.filterOptions[1],
  })
  expect(instance.state.submissions).toMatchObject([
    {
      status: 'late',
    },
  ])

  instance.updateFilter({
    filter: instance.filterOptions[2],
  })
  expect(instance.state.submissions).toMatchObject([
    {
      grade: 'not_submitted',
    },
  ])

  instance.updateFilter({
    filter: instance.filterOptions[3],
  })
  expect(instance.state.submissions).toMatchObject([
    {
      grade: 'ungraded',
    },
  ])

  instance.updateFilter({
    filter: instance.filterOptions[5],
    metadata: 50,
  })
  expect(instance.state.submissions).toMatchObject([
    {
      score: 30,
      status: 'submitted',
    },
  ])

  // Scored more than…
  instance.updateFilter({
    filter: instance.filterOptions[6],
    metadata: 50,
  })
  expect(instance.state.submissions).toMatchObject([
    {
      score: 60,
      status: 'submitted',
    },
  ])

  // Cancel
  instance.clearFilter()
  expect(instance.state.submissions).toMatchObject(expandedProps.submissions)
  instance.updateFilter({
    filter: instance.filterOptions[7],
  })
  expect(instance.state.submissions).toMatchObject(expandedProps.submissions)
})

test('SubmissionList renders correctly with a passed in filter', () => {
  const expandedProps = cloneDeep(props)
  expandedProps.submissions = expandedProps.submissions.concat([
    template.submissionProps({
      name: 'S5',
      status: 'submitted',
      grade: '60',
      score: 60,
      userID: '5',
    }),
  ])

  expandedProps.filterType = 'graded'

  const tree = renderer.create(
    <SubmissionList {...expandedProps} navigator={template.navigator()} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('should refresh', () => {
  expect(shouldRefresh(props)).toBeFalsy()

  const emptyProps = {
    ...props,
    shouldRefresh: true,
  }
  expect(shouldRefresh(emptyProps)).toBeTruthy()
})

test('should navigate to submission settings', () => {
  let navigator = template.navigator({
    show: jest.fn(),
  })

  const tree = renderer.create(
    <SubmissionList {...props} navigator={navigator} />
  )
  tree.getInstance().openSettings()

  expect(navigator.show).toHaveBeenCalledWith('/courses/12/assignments/32/submission_settings', {
    modal: true,
    modalPresentationStyle: 'fullscreen',
  })
})

test('should navigate to a submission', () => {
  let submission = props.submissions[0]
  let navigator = template.navigator({
    show: jest.fn(),
  })
  const tree = renderer.create(
    <SubmissionList {...props} navigator={navigator} />
  )
  tree.getInstance().navigateToSubmission(submission.userID)

  expect(navigator.show).toHaveBeenCalledWith(
    '/courses/12/assignments/32/submissions/1',
    { modal: true },
    { selectedFilter: undefined }
  )
})

test('should prevent going to speed grader when offline', () => {
  let submission = props.submissions[0]
  let navigator = template.navigator({
    show: jest.fn(),
  })
  let tree = renderer.create(
    <SubmissionList {...props} navigator={navigator} />
  )
  tree.getInstance().setState({ isConnected: false })
  tree.getInstance().navigateToSubmission(submission.userID)

  expect(AlertIOS.alert).toHaveBeenCalled()
  expect(navigator.show).not.toHaveBeenCalled()
})

test('refreshSubmissionList', () => {
  refreshSubmissionList(props)
  expect(props.refreshSubmissions).toHaveBeenCalledWith(props.courseID, props.assignmentID, false)
  expect(props.refreshEnrollments).toHaveBeenCalledWith(props.courseID)
})

test('refreshSubmissionList (group submissions)', () => {
  refreshSubmissionList({
    ...props,
    groupAssignment: { groupCategoryID: '2', gradeIndividually: false },
  })
  expect(props.refreshSubmissions).toHaveBeenCalledWith(props.courseID, props.assignmentID,
  true)
  expect(props.refreshGroupsForCourse).toHaveBeenCalledWith(props.courseID)
})
