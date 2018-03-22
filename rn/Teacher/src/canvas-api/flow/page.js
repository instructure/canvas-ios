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

export type Page = {
  url: string,
  html_url: string,
  title: string,
  created_at: string,
  updated_at: string,
  hide_from_students: boolean,
  editing_roles: string, // comma separated eg: "students,teachers"
  body: string,
  published: boolean,
  front_page: boolean,
  page_id: string,
}

export type PageParameters = {
  title: ?string,
  body: ?string,
  editing_roles: ?string,
  published: boolean,
  front_page: boolean,
}
