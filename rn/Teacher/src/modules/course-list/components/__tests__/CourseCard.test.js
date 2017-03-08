// @flow

import React from 'react'
import renderer from 'react-test-renderer'
import * as courseTemplate from '../../../../api/canvas-api/__templates__/course'

import CourseCard from '../CourseCard'

it('renders', () => {
  let tree = renderer.create(
    <CourseCard
      course={courseTemplate.course()}
      color={'#333'}
    />
  ).toJSON()

  expect(tree).toMatchSnapshot()
})
