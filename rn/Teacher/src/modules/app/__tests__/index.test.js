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

import App from '../'

const template = {
  ...require('../../../__templates__/course'),
}

describe('App', () => {
  let app

  describe('teacher', () => {
    beforeEach(() => {
      App.setCurrentApp('teacher')
      app = App.current()
    })

    describe('filterCourse', () => {
      it('filters courses access restricted by date', () => {
        const restricted = template.course({ access_restricted_by_date: true })
        const available = template.course({ access_restricted_by_date: false })
        const result = [restricted, available].filter(app.filterCourse)
        expect(result).toEqual([available])
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
        const restricted = template.course({ access_restricted_by_date: true })
        const available = template.course({ access_restricted_by_date: false })
        const result = [restricted, available].filter(app.filterCourse)
        expect(result).toEqual([available])
      })
    })
  })
})
