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

export const session: Template<Session> = template({
  authToken: 'iamanauthtoken',
  baseURL: 'http://mobiledev.instructure.com/',
  user: {
    id: '1',
    name: 'Key and Peele',
    avatar_url: 'https://farm3.staticflickr.com/2926/14690771011_945f91045a.jpg',
    primary_email: 'keyandpeele@instructure.com',
  },
})
