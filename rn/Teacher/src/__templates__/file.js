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

export const usageRights: Template<UsageRights> = template({
  legal_copyright: '',
  use_justification: 'own_copyright',
})

export const file: Template<File> = template({
  id: '111',
  display_name: 'Book Report',
  url: 'http://canvaslms.com/bookreport',
  size: 488212,
  thumbnail_url: 'http://fillmurray.com/322/200',
  mime_class: 'document',
  preview_url: '/',
  filename: '/bookreport',
  parent_folder_id: null,
  locked: false,
  hidden: false,
  unlock_at: null,
  lock_at: null,
  usage_rights: usageRights(),
  'content-type': 'application/document',
})
