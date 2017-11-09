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

// @flow

import type { CourseListDataProps } from '../course-prop-types'
import localeSort from '../../../utils/locale-sort'
import App from '../../app'

export default function mapStateToProps (state: AppState): CourseListDataProps {
  const allCourses = state.entities.courses
  const { pending, error } = state.favoriteCourses
  let courses = Object.keys(allCourses)
    .map(id => allCourses[id])
    .map(({ course, color }) => ({ ...course, color }))
    .filter(App.current().filterCourse)
    .sort((c1, cs2) => localeSort(c1.name, cs2.name))

  return { pending, error, courses }
}
