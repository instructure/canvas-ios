/* @flow */

import 'react-native'
import React from 'react'
import { AssignmentList } from '../AssignmentList'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/course'),
}

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

let refresh: any
beforeEach(() => {
  refresh = jest.fn()
})

jest.mock('../../../routing')

test('renders correctly', () => {
  let course = template.course()
  let tree = renderer.create(
    <AssignmentList assignmentGroups={[template.assignmentGroup()]}
                    courseID={course.id}
                    refreshAssignmentList={refresh} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('get next page is called onEndReached', () => {
  const nextPage = jest.fn()
  let course = template.course()
  let tree = renderer.create(
    <AssignmentList assignmentGroups={[template.assignmentGroup()]}
                    courseID={course.id}
                    refreshAssignmentList={refresh}
                    nextPage={nextPage} />
  )

  tree._component._renderedComponent._instance.onEndReached()
  expect(nextPage).toHaveBeenCalled()
})

test('selected assignment', () => {
  const push = jest.fn()
  const navigator = {
    push,
  }
  let course = template.course()
  let tree = renderer.create(
    <AssignmentList assignmentGroups={[template.assignmentGroup()]}
                    courseID={course.id}
                    refreshAssignmentList={refresh}
                    navigator={navigator} />
  )
  let assignment = template.assignment()
  tree._component._renderedComponent._instance.selectedAssignment(assignment)
  expect(push).toHaveBeenCalled()
})

test('getSectionHeaderData', () => {
  let course = template.course()
  let tree = renderer.create(
    <AssignmentList assignmentGroups={[template.assignmentGroup()]}
                    courseID={course.id}
                    refreshAssignmentList={refresh}
                    navigator={navigator} />
  )

  const data = {
    key: 'data',
  }
  const sectionHeaderData = tree._component._renderedComponent._instance.getSectionHeaderData(data, 'key')
  expect(sectionHeaderData).toEqual('data')
})

test('getRowData', () => {
  let course = template.course()
  let tree = renderer.create(
    <AssignmentList assignmentGroups={[template.assignmentGroup()]}
                    courseID={course.id}
                    refreshAssignmentList={refresh}
                    navigator={navigator} />
  )

  const data = {
    'courseID:assignmentID': 'data',
  }
  const sectionHeaderData = tree._component._renderedComponent._instance.getRowData(data, 'courseID', 'assignmentID')
  expect(sectionHeaderData).toEqual('data')
})
