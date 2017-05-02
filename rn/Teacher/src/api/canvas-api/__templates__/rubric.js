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
  ratings: [{ id: '1', points: 0 }, { id: '2', points: 5 }, { id: '3', points: 10 }].map(rubricRating),
})

export const rubricSettings: Template<RubricSettings> = template({
  id: '1',
  points_possible: 100,
  title: 'A possible item',
})

export const rubricAssessment: Template<{ [string]: RubricAssessment }> = template({
  '1': {
    points: 10,
    comments: '',
  },
})
