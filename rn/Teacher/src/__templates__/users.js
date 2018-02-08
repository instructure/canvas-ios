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

export const user: Template<User> = template({
  id: '1',
  name: 'Donald Trump',
  short_name: 'The Donald',
  sortable_name: 'Mr. President',
  bio: 'my bio is yuuuuuuuge',
  avatar_url: 'http://www.fillmurray.com/100/100',
  primary_email: 'donald@trump.com',
})

export const userDisplay: Template<UserDisplay> = template({
  id: '1',
  short_name: 'The Donald',
  display_name: 'The Donald',
  avatar_url: 'http://www.fillmurray.com/100/100',
  avatar_image_url: 'http://www.fillmurray.com/100/100',
  html_url: '',
})
