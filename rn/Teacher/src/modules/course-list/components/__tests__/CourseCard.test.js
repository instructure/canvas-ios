// @flow

import React from 'react'
import renderer from 'react-test-renderer'
import * as courseTemplate from '../../../../api/canvas-api/__templates__/course'

import CourseCard from '../CourseCard'

let defaultProps = {
  onPress: () => {},
  course: courseTemplate.course(),
  color: '#333',
  style: {},
  initialHeight: 100,
}

it('renders', () => {
  let tree = renderer.create(
    <CourseCard
      {...defaultProps}
    />
  ).toJSON()

  expect(tree).toMatchSnapshot()
})
