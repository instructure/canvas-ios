/* @flow */

import 'react-native'
import React from 'react'
import { CourseList } from '../CourseList.js'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

const courses: Course[] = [{
  color: '#27B9CD',
  image_download_url: 'https://farm3.staticflickr.com/2926/14690771011_945f91045a.jpg',
  name: 'Biology 101',
  course_code: 'BIO 101',
  short_name: 'BIO 101',
  id: 1,
}, {
  color: '#8F3E97',
  image_download_url: 'https://farm3.staticflickr.com/2926/14690771011_945f91045a.jpg',
  name: 'American Literature Psysicks foobar hello world 401',
  course_code: 'LIT 401',
  short_name: 'LIT 401',
  id: 2,
}, {
  color: '#8F3E97',
  image_download_url: 'https://farm3.staticflickr.com/2926/14690771011_945f91045a.jpg',
  name: 'Foobar 102',
  course_code: 'FOO 102',
  id: 3,
  short_name: 'FOO 102',
}]

let refreshCourses = () => {}

test('renders correctly', () => {
  let tree = renderer.create(
    <CourseList width={320} refreshCourses={ refreshCourses } courses={ courses } />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders correctly with wide device', () => {
  let tree = renderer.create(
    <CourseList width={768} refreshCourses={ refreshCourses } courses={ courses } />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('refreshCourses was called', () => {
  let didCallRefresh = false
  let refresh = () => {
    didCallRefresh = true
  }
  let tree = renderer.create(
    <CourseList width={320} refreshCourses={ refresh } courses={ courses }/>
  ).toJSON()
  expect(tree).toMatchSnapshot()
  expect(didCallRefresh).toBe(true)
})
