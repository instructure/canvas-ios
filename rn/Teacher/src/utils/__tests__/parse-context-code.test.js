// @flow

import parseContextCode from '../parse-context-code'

test('it parses a context string into type and id', () => {
  expect(parseContextCode('course_1')).toEqual({
    type: 'course',
    id: '1',
  })
  expect(parseContextCode('account_3')).toEqual({
    type: 'account',
    id: '3',
  })
})
