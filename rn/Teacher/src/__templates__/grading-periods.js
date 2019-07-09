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

import template, { type Template } from '../utils/template'

export const gradingPeriod: Template<GradingPeriod> = template({
  id: '1023',
  title: 'First Block',
  start_date: '2014-01-07T15:04:00Z',
  end_date: '2014-05-07T17:07:00Z',
  close_date: '2014-06-07T17:07:00Z',
  weight: 33.33,
})
