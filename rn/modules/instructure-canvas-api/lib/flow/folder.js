//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
}

export type NewFolder = {
  name: string,
  parent_folder_id?: string,
  parent_folder_path?: string,
  lock_at?: string,
  unlock_at?: string,
  locked?: boolean,
  hidden?: boolean,
  position?: number,
}
