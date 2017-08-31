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

/* @flow */

import template from '../template'

test('template', () => {
  type Course = {
    id: number,
    name: string,
  }

  const t = template({
    id: 1,
    name: 'Foo',
  })

  let course: Course = t()
  expect(course.id).toBe(1)
  expect(course.name).toEqual('Foo')

  course = t({ id: 2, name: 'Bar' })
  expect(course.id).toBe(2)
  expect(course.name).toEqual('Bar')

  course = t({ id: 3 })
  expect(course.id).toBe(3)
  expect(course.name).toEqual('Foo')
})
