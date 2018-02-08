//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

/* @flow */

import template, { type Template } from '../utils/template'

export const gradingPeriod: Template<GradingPeriod> = template({
  id: '1023',
  title: 'First Block',
  start_date: '2014-01-07T15:04:00Z',
  end_date: '2014-05-07T17:07:00Z',
  close_date: '2014-06-07T17:07:00Z',
  weight: 33.33,
})
