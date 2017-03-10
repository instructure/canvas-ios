/* @flow */

import 'react-native'
import React from 'react'
import { CourseDetails } from '../CourseDetails.js'

const template = {
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../api/canvas-api/__templates__/tab'),
}

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

let refresh: any
beforeEach(() => {
  refresh = jest.fn()
})

test('renders correctly', () => {
  const tabs = [template.tab()]
  let tree = renderer.create(
    <CourseDetails course={template.course()} tabs={tabs} courseColors={template.customColors()} refreshTabs={refresh} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders correctly without tabs', () => {
  let tree = renderer.create(
    <CourseDetails course={template.course()} tabs={[]} courseColors={template.customColors()} refreshTabs={refresh} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('refresh on mount', () => {
  renderer.create(
    <CourseDetails course={template.course()} tabs={[]} courseColors={template.customColors()} refreshTabs={refresh} />
  )
  expect(refresh).toHaveBeenCalled()
})
