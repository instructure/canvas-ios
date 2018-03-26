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

export type File = {
  id: string,
  display_name: string,
  filename: string,
  url: string,
  size: number,
  thumbnail_url: string,
  mime_class: string,
  parent_folder_id: ?string,
  locked: boolean,
  hidden: boolean,
  unlock_at: ?string,
  lock_at: ?string,
  usage_rights: UsageRights,
  'content-type': string,
}

export type UpdateFileParameters = {
  name?: string,
  parent_folder_id?: ?string,
  lock_at?: ?string,
  unlock_at?: ?string,
  locked?: boolean,
  hidden?: boolean,
  on_duplicate?: 'overwrite' | 'rename',
}

export type UsageRights = {
  legal_copyright: string,
  use_justification: 'own_copyright' | 'public_domain' | 'used_by_permission' | 'fair_use' | 'creative_commons',
  license?: string,
  license_name?: string,
  message?: string,
}

export type UpdateUsageRightsParameters = {
  use_justification: string,
  legal_copyright?: string,
  license?: string,
}

export type License = {
  id: string,
  name: string,
  url: string,
}
