// @flow

const { it, expect } = global
import React from 'react'
import renderer from 'react-test-renderer'

import CourseCard from '../CourseCard'

it('renders', () => {
  let tree = renderer.create(
    <CourseCard
      course={{
        name: 'Course',
        course_code: 'yo',
        image_download_url: 'http://fillmurray.com/200/200',
      }}
      color={'#333'}
    />
  ).toJSON()

  expect(tree).toMatchSnapshot()
})
