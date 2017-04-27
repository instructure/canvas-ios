/* @flow */

import template, { type Template } from '../../../utils/template'

export const rubricRating: Template<Rubric> = template({
  points: 10,
  id: '3',
  description: 'Lame',
})

export const rubric: Template<Rubric> = template({
  points: 10,
  id: '2',
  description: 'A description',
  long_description: 'A long description',
  ratings: [{ points: 0 }, { points: 5 }, { points: 10 }].map(rubricRating),
})

export const rubricSettings: Template<RubricSettings> = template({
  id: '1',
  points_possible: 100,
  title: 'A possible item',
})
