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

export function getFolder (folderID: string): Promise<ApiResponse<Folder>> {
  const url = `folders/${folderID}`
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

export function updateFolder (folderID: string, folder: UpdateFolderParameters): Promise<ApiResponse<Folder>> {
  return httpClient().put(`folders/${folderID}`, folder)
}

export function deleteFolder (folderID: string, force: boolean): Promise<ApiResponse<>> {
  return httpClient().delete(`folders/${folderID}`, { params: { force } })
}

export function updateFile (fileID: string, file: UpdateFileParameters): Promise<ApiResponse<File>> {
  return httpClient().put(`files/${fileID}`, file)
}

export function deleteFile (fileID: string): Promise<ApiResponse<>> {
  return httpClient().delete(`files/${fileID}`)
}
