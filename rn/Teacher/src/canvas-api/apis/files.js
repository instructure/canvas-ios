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

export function getFolderFiles (folderID: string): ApiPromise<File[]> {
  const files = paginate(`folders/${folderID}/files`, {
    params: {
      per_page: 99,
      include: ['usage_rights'],
    },
  })

  return exhaust(files)
}

// Get folders contains with folder
export function getFolderFolders (folderID: string): ApiPromise<Folder[]> {
  const files = paginate(`folders/${folderID}/folders`, {
    params: {
      per_page: 99,
      include: ['usage_rights'],
    },
  })

  return exhaust(files)
}

// Get a single folder for a context by id
// To get the root folder, pass `root` for `folderID`
export function getContextFolder (context: CanvasContext, contextID: string, folderID: string): ApiPromise<Folder[]> {
  const url = `${context}/${contextID}/folders/${folderID}`
  const options = {
    params: {
      include: ['usage_rights'],
    },
  }
  return httpClient().get(url, options)
}

export function getFolder (folderID: string): ApiPromise<Folder> {
  const url = `folders/${folderID}`
  const options = {
    params: {
      include: ['usage_rights'],
    },
  }
  return httpClient().get(url, options)
}

export function getFile (fileID: string): ApiPromise<File> {
  return httpClient().get(`files/${fileID}`)
}

export function createFolder (context: CanvasContext, contextID: string, folder: NewFolder): ApiPromise<Folder> {
  return httpClient().post(`${context}/${contextID}/folders`, folder)
}

export function updateFolder (folderID: string, folder: UpdateFolderParameters): ApiPromise<Folder> {
  return httpClient().put(`folders/${folderID}`, folder)
}

export function deleteFolder (folderID: string, force?: boolean): ApiPromise<null> {
  return httpClient().delete(`folders/${folderID}`, { params: { force } })
}

export function updateFile (fileID: string, file: UpdateFileParameters): ApiPromise<File> {
  return httpClient().put(`files/${fileID}`, file)
}

export function deleteFile (fileID: string): ApiPromise<null> {
  return httpClient().delete(`files/${fileID}`)
}

export function updateCourseFileUsageRights (courseID: string, fileID: string, params: UpdateUsageRightsParameters): ApiPromise<UsageRights> {
  return httpClient().put(`courses/${courseID}/usage_rights`, {
    file_ids: [ fileID ],
    usage_rights: params,
  })
}
