/* @flow */

import 'react-native'
import React from 'react'
import { AssignmentList } from '../AssignmentList'
import setProps from '../../../../test/helpers/setProps'
import explore from '../../../../test/helpers/explore'

const template = {
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../__templates__/react-native-navigation'),
}

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

jest.mock('TouchableHighlight', () => 'TouchableHighlight')
jest.mock('../../../routing')

test('renders correctly', () => {
  let course = template.course()
  let group = template.assignmentGroup()
  let tree = renderer.create(
    <AssignmentList assignmentGroups={[group]}
                    courseID={course.id}
                    course={course}
                    navigator={template.navigator()} />
  )
  setProps(tree, { assignmentGroups: [group] })
  expect(tree.toJSON()).toMatchSnapshot()
  expect(tree.getInstance().props).toMatchObject({
    assignmentGroups: [group],
  })
})

test('get next page is called onEndReached', () => {
  const nextPage = jest.fn()
  let course = template.course()
  let tree = renderer.create(
    <AssignmentList assignmentGroups={[template.assignmentGroup()]}
                    courseID={course.id}
                    course={course}
                    nextPage={nextPage}
                    navigator={template.navigator()} />
  )

  tree.getInstance().onEndReached()
  expect(nextPage).toHaveBeenCalled()
})

test('selected assignment', () => {
  const push = jest.fn()
  const navigator = template.navigator({
    push,
  })
  const course = template.course()
  const group = template.assignmentGroup()
  const assignment = group.assignments[0]
  const tree = renderer.create(
    <AssignmentList assignmentGroups={[group]}
                    courseID={course.id}
                    course={course}
                    navigator={navigator} />
  )
  setProps(tree, { assignmentGroups: [group] })
  const row: any = explore(tree.toJSON()).selectByID(`assignment-${assignment.id}`)
  row.props.onPress()
  expect(push).toHaveBeenCalled()
})

test('getSectionHeaderData', () => {
  let course = template.course()
  let tree = renderer.create(
    <AssignmentList assignmentGroups={[template.assignmentGroup()]}
                    courseID={course.id}
                    course={course}
                    navigator={template.navigator()} />
  )

  const data = {
    key: 'data',
  }
  const sectionHeaderData = tree.getInstance().getSectionHeaderData(data, 'key')
  expect(sectionHeaderData).toEqual('data')
})

test('getRowData', () => {
  let course = template.course()
  let tree = renderer.create(
    <AssignmentList assignmentGroups={[template.assignmentGroup()]}
                    courseID={course.id}
                    course={course}
                    navigator={template.navigator()} />
  )

  const data = {
    'courseID:assignmentID': 'data',
  }
  const sectionHeaderData = tree.getInstance().getRowData(data, 'courseID', 'assignmentID')
  expect(sectionHeaderData).toEqual('data')
})
