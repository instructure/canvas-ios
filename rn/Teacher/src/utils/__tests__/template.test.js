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
