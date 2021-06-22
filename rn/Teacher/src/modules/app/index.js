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

// @flow

export type AppId = 'student' | 'teacher' | 'parent'
export type App = {
  appId: AppId,
  filterCourse: (course: Course) => boolean,
  isK5Enabled: boolean,
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
  isK5Enabled: false,
}

const student = {
  appId: 'student',
  filterCourse: (course: Course): boolean => !course.access_restricted_by_date,
  isK5Enabled: false,
}

const parent = {
  appId: 'parent',
  filterCourse: (course: Course): boolean => true,
  isK5Enabled: false,
}

let current: App = teacher

const app = {
  setCurrentApp: (appId: AppId, isK5Enabled: boolean = false): void => {
    switch (appId) {
      case 'student':
        current = student
        break
      case 'teacher':
        current = teacher
        break
      case 'parent':
        current = parent
        break
    }

    current.isK5Enabled = isK5Enabled
  },
  current: (): App => current,
}

export function isTeacher (): boolean {
  return app.current().appId === 'teacher'
}
export function isStudent (): boolean {
  return app.current().appId === 'student'
}

export function isParent (): boolean {
  return app.current().appId === 'parent'
}

export default app
