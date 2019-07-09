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

export type Folder = {
  id: string,
  context_type: string,
  context_id: string,
  files_count: number,
  position: number,
  updated_at: string,
  folders_url: string,
  files_url: string,
  full_name: string,
  lock_at: ?string,
  folders_count: number,
  name: string,
  parent_folder_id: ?string,
  created_at: string,
  unlock_at: ?string,
  hidden: boolean,
  hidden_for_user: boolean,
  locked: boolean,
  locked_for_user: boolean,
  for_submissions: boolean,
  can_upload?: boolean,
}

export type NewFolder = {
  name: string,
  parent_folder_id: string,
  locked: boolean,
}

export type UpdateFolderParameters = {
  name?: string,
  parent_folder_id?: ?string,
  lock_at?: ?string,
  unlock_at?: ?string,
  locked?: boolean,
  hidden?: boolean,
  position?: number,
}
