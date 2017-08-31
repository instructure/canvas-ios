// @flow

import groupCustomColors from '../group-custom-colors'

test('group context codes by type', () => {
  const colors = {
    custom_colors: {
      course_1: '#fff',
      course_2: '#eee',
      account_1: '#ddd',
      group_2: '#aaa',
    },
  }

  expect(groupCustomColors(colors)).toEqual({
    custom_colors: {
      course: {
        '1': '#fff',
        '2': '#eee',
      },
      account: {
        '1': '#ddd',
      },
      group: {
        '2': '#aaa',
      },
    },
  })
})
