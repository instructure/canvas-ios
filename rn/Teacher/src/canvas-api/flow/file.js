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

export type UsageRights = {
  legal_copyright: string,
  use_justification: 'own_copyright' | 'public_domain' | 'used_by_permission' | 'fair_use' | 'creative_commons',
  license?: string,
  license_name?: string,
  message?: string,
}
