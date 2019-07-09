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

import App from '../'
import * as templates from '../../../__templates__'

describe('App', () => {
  let app

  describe('teacher', () => {
    beforeEach(() => {
      App.setCurrentApp('teacher')
      app = App.current()
    })

    describe('filterCourse', () => {
      it('filters courses access restricted by date', () => {
        const restricted = templates.course({ access_restricted_by_date: true })
        const available = templates.course({ access_restricted_by_date: false })
        const result = [restricted, available].filter(app.filterCourse)
        expect(result).toEqual([available])
      })

      it('filters courses based on enrollment types', () => {
        let courses = [
          templates.course({ enrollments: [templates.enrollment({ type: 'teacher' })] }),
          templates.course({ enrollments: [templates.enrollment({ type: 'teacherenrollment' })] }),
          templates.course({ enrollments: [templates.enrollment({ type: 'designer' })] }),
          templates.course({ enrollments: [templates.enrollment({ type: 'ta' })] }),
          templates.course({ enrollments: [templates.enrollment({ type: 'student' })] }),
        ]

        const result = courses.filter(app.filterCourse)
        expect(result.every(c => c.enrollments && c.enrollments[0].type !== 'student')).toEqual(true)
      })
    })
  })

  describe('student', () => {
    beforeEach(() => {
      App.setCurrentApp('student')
      app = App.current()
    })

    describe('filterCourse', () => {
      it('filters courses access restricted by date', () => {
        const restricted = templates.course({ access_restricted_by_date: true })
        const available = templates.course({ access_restricted_by_date: false })
        const result = [restricted, available].filter(app.filterCourse)
        expect(result).toEqual([available])
      })
    })
  })
})
