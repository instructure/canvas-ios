// @flow

import find from 'lodash/find'
import { type Course } from 'instructure-canvas-api'

export type AppId = 'student' | 'teacher'
export type App = {
  filterCourse: (course: Course) => boolean,
}

const teacher = {
  filterCourse: (course: Course): boolean => {
    const enrollments = course.enrollments
    if (!enrollments) return false
    return !!find(enrollments, (e) => {
      return [
        'teacher',
        'teacherenrollment',
        'designer',
        'ta',
      ].includes(e.type.toLowerCase())
    })
  },
}

const student = {
  filterCourse: (course: Course): boolean => true,
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

export default (app: *)
