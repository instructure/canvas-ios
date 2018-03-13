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
