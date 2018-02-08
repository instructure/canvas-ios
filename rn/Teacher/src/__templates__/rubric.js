//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

/* @flow */

import template, { type Template } from '../utils/template'

export const rubricRating: Template<RubricRating> = template({
  points: 10,
  id: '3',
  description: 'Lame',
})

export const rubric: Template<Rubric> = template({
  points: 10,
  id: '2',
  description: 'A description',
  long_description: 'A long description',
  ratings: [
    { id: '1', points: 0, description: 'No Credit' },
    { id: '2', points: 5, description: 'Partial Credit' },
    { id: '3', points: 10, description: 'Full Credit' },
  ].map(rubricRating),
})

export const rubricSettings: Template<RubricSettings> = template({
  id: '1',
  points_possible: 100,
  title: 'A possible item',
  free_form_criterion_comments: false,
})

export const rubricAssessment: Template<{ [string]: RubricAssessment }> = template({
  '1': {
    points: 10,
    comments: '',
  },
})
