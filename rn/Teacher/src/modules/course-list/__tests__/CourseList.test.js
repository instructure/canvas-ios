/* @flow */

import 'react-native'
import React from 'react'
import { CourseList } from '../CourseList.js'
import * as courseTemplate from '../../../api/canvas-api/__templates__/course'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

const courses = [
  courseTemplate.course({
    name: 'Biology 101',
    course_code: 'BIO 101',
    short_name: 'BIO 101',
    id: 1,
    is_favorite: true,
  }),
  courseTemplate.course({
    name: 'American Literature Psysicks foobar hello world 401',
    course_code: 'LIT 401',
    short_name: 'LIT 401',
    id: 2,
    is_favorite: false,
  }),
  courseTemplate.course({
    name: 'Foobar 102',
    course_code: 'FOO 102',
    id: 3,
    short_name: 'FOO 102',
    is_favorite: true,
  }),
]

const colors = {
  '1': '#27B9CD',
  '2': '#8F3E97',
  '3': '#8F3E99',
}

let refreshCourses = () => {}

test('renders correctly', () => {
  let tree = renderer.create(
    <CourseList width={320} refreshCourses={ refreshCourses } courses={ courses } customColors={colors} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders correctly with wide device', () => {
  let tree = renderer.create(
    <CourseList width={768} refreshCourses={ refreshCourses } courses={ courses } customColors={colors} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('refreshCourses was called', () => {
  let didCallRefresh = false
  let refresh = () => {
    didCallRefresh = true
  }
  let tree = renderer.create(
    <CourseList width={320} refreshCourses={ refresh } courses={ courses } customColors={colors} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
  expect(didCallRefresh).toBe(true)
})
