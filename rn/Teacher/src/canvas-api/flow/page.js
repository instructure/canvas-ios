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

// @flow

export type Page = {
  url: string,
  html_url: string,
  title: string,
  created_at: string,
  updated_at: string,
  hide_from_students: boolean,
  editing_roles: string, // comma separated eg: "students,teachers"
  body: ?string,
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
