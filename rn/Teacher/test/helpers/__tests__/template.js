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
