/* @flow */

import template, { type Template } from '../utils/template'

export const gradingPeriod: Template<GradingPeriod> = template({
  id: 1023,
  title: 'First Block',
  start_date: '2014-01-07T15:04:00Z',
  end_date: '2014-05-07T17:07:00Z',
  close_date: '2014-06-07T17:07:00Z',
  weight: 33.33,
})
