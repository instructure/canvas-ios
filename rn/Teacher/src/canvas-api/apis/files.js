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

import { paginate, exhaust } from '../utils/pagination'
import httpClient from '../httpClient'

export function getCourseFiles (courseID: string): Promise<ApiResponse<Array<File>>> {
  const files = paginate(`courses/${courseID}/files`, {
    params: {
      per_page: 99,
      include: ['usage_rights'],
    },
  })

  return exhaust(files)
}

export function getFolderFiles (folderID: string): Promise<ApiResponse<Array<File>>> {
  const files = paginate(`folders/${folderID}/files`, {
    params: {
      per_page: 99,
      include: ['usage_rights'],
    },
  })

  return exhaust(files)
}

// Get folders contains with folder
export function getFolderFolders (folderID: string): Promise<ApiResponse<Array<File>>> {
  const files = paginate(`folders/${folderID}/folders`, {
    params: {
      per_page: 99,
      include: ['usage_rights'],
    },
  })

  return exhaust(files)
}

export function getCourseFolders (courseID: string): Promise<ApiResponse<Array<Folder>>> {
  const folders = paginate(`courses/${courseID}/folders`, {
    params: {
      per_page: 99,
      include: ['usage_rights'],
    },
  })

  return exhaust(folders)
}

// Get a single folder for a course by id
// To get the root folder, pass `root` for `folderID`
export function getCourseFolder (courseID: string, folderID: string): Promise<ApiResponse<Array<Folder>>> {
  const url = `courses/${courseID}/folders/${folderID}`
  const options = {
    params: {
      include: ['usage_rights'],
    },
  }
  return httpClient().get(url, options)
}

export function createFolder (courseID: string, folder: NewFolder): Promise<ApiResponse<Folder>> {
  return httpClient().post(`courses/${courseID}/folders`, folder)
}
