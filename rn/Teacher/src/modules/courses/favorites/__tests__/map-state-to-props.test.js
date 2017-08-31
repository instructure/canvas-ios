//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

// @flow

import { mapStateToProps } from '../FavoritedCourseList'
import { normalizeCourse } from '../../courses-reducer'
import * as courseTemplate from '../../../../__templates__/course'
import { appState } from '../../../../redux/__templates__/app-state'
import fromPairs from 'lodash/fromPairs'

describe('favorite courses mapStateToProps', () => {
  const a = courseTemplate.course({ id: 1, name: 'a' })
  const b = courseTemplate.course({ id: 2, name: 'b' })
  const c = courseTemplate.course({ id: 3, name: 'c' })
  const courseTemplates = [
    a, b, c,
    courseTemplate.course({ id: 4, name: 'd' }),
  ]

  const colors: { [courseID: string]: string } = {
    '1': '#aaa',
    '2': '#bbb',
    '3': '#ccc',
    '4': '#ddd',
  }

  const courseStates: Array<CourseState> = courseTemplates
    .map((course) => normalizeCourse(course, colors))
  const pairs: Array<Array<*>> = courseStates
      .map((courseState) => ([courseState.course.id, courseState]))
  const courses: CoursesState = fromPairs(pairs)

  const state = appState({
    favoriteCourses: { courseRefs: ['3', '1', '2'] },
    entities: {
      courses,
    },
  })

  const props = mapStateToProps(state)

  it('courses sorted alphabetically', () => {
    const expected = [a, b, c].map(course => ({ ...course, color: colors[course.id] }))
    expect(props.courses).toEqual(expected)
  })

  it('has colors', () => {
    expect(props.courses.map(course => course.color))
      .toEqual(['#aaa', '#bbb', '#ccc'])
  })
})
