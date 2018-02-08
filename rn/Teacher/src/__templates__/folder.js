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

export const folder: Template<Folder> = template({
  id: '111',
  name: 'some folder',
  full_name: 'course files/some_folder',
  context_type: 'course',
  context_id: '1',
  files_count: 2,
  position: 1,
  updated_at: '',
  folders_url: '',
  files_url: '',
  lock_at: null,
  folders_count: 1,
  parent_folder_id: null,
  created_at: '',
  unlock_at: null,
  hidden: false,
  hidden_for_user: false,
  locked: false,
  locked_for_user: false,
  for_submissions: false,
})
