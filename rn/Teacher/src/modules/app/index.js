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

export type AppId = 'student' | 'teacher'
export type App = {
  appId: AppId,
  filterCourse: (course: Course) => boolean,
}

const teacher = {
  appId: 'teacher',
  filterCourse: (course: Course): boolean => {
    if (course.access_restricted_by_date) return false
    const enrollments = course.enrollments
    if (!enrollments) return false
    return enrollments.some((e) =>
      [
        'teacher',
        'teacherenrollment',
        'designer',
        'ta',
      ].includes(e.type.toLowerCase())
    )
  },
}

const student = {
  appId: 'student',
  filterCourse: (course: Course): boolean => !course.access_restricted_by_date,
}

let current: App = teacher

const app = {
  setCurrentApp: (appId: AppId): void => {
    switch (appId) {
      case 'student':
        current = student
        break
      case 'teacher':
        current = teacher
        break
    }
  },
  current: (): App => current,
}

export function isTeacher (): boolean {
  return app.current().appId === 'teacher'
}
export function isStudent (): boolean {
  return app.current().appId === 'student'
}

export default app
