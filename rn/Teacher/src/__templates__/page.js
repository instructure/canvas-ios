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

// @flow
import { PageModel } from '../canvas-api/model'
import template, { type Template } from '../utils/template'

export const page: Template<Page> = template({
  page_id: '1',
  url: 'page-1',
  html_url: '/pages/page-1',
  title: 'Page 1',
  created_at: '2017-03-17T19:15:25Z',
  updated_at: '2017-03-17T19:15:25Z',
  hide_from_students: false,
  editing_roles: 'teachers',
  body: '<p>Hello, World!</p>',
  published: true,
  front_page: false,
})

export const pageModel: Template<PageModel> = overrides =>
  Object.assign(new PageModel(page()), overrides)
