//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
  '2': {
    points: 10,
    rating_id: '3',
    comments: '',
  },
})
