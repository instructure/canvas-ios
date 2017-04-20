// @flow

import 'react-native'
import React from 'react'
import {
  SubmissionList,
  refreshSubmissionList,
  shouldRefresh,
} from '../SubmissionList'
import renderer from 'react-test-renderer'
import { submissionProps } from './map-state-to-props.test'

const template = {
  ...require('../../../../__templates__/react-native-navigation'),
}

const props = {
  submissions: submissionProps,
  pending: false,
  courseID: '12',
  assignmentID: '32',
  courseColor: '#ddd',
  refreshSubmissions: jest.fn(),
  refreshEnrollments: jest.fn(),
  shouldRefresh: false,
  refreshing: false,
  refresh: jest.fn(),
}

test('SubmissionList loaded', () => {
  const tree = renderer.create(
    <SubmissionList {...props} navigator={template.navigator()} />
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

test('refreshSubmissionList', () => {
  refreshSubmissionList(props)
  expect(props.refreshSubmissions).toHaveBeenCalledWith(props.courseID, props.assignmentID)
  expect(props.refreshEnrollments).toHaveBeenCalledWith(props.courseID)
})
