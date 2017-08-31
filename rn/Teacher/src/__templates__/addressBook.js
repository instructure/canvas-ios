/* @flow */

import template, { type Template } from '../utils/template'

export const addressBookResult: Template<AddressBookResult> = template({
  id: 1,
  name: 'Donald Trump',
  common_courses: {
    '11': ['TeacherEnrollment'],
  },
})
