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

import * as template from '../../__templates__'
import {
  CourseModel,
  PageModel,
} from '../model'

describe('CourseModel', () => {
  describe('keyExtractor', () => {
    it('returns course id', () => {
      const course = template.courseModel()
      expect(CourseModel.keyExtractor(course)).toBe(course.id)
    })
  })
})

describe('PageModel', () => {
  describe('keyExtractor', () => {
    it('returns page id', () => {
      const page = template.pageModel()
      expect(PageModel.keyExtractor(page)).toBe(page.url)
    })
  })
})
