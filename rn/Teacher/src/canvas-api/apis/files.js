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

import { paginate, exhaust } from '../utils/pagination'
import httpClient from '../httpClient'

export function getFolderFiles (folderID: string): ApiPromise<File[]> {
  const files = paginate(`folders/${folderID}/files`, {
    params: {
      per_page: 100,
      include: ['usage_rights'],
    },
  })

  return exhaust(files)
}

// Get folders contains with folder
export function getFolderFolders (folderID: string): ApiPromise<Folder[]> {
  const files = paginate(`folders/${folderID}/folders`, {
    params: {
      per_page: 100,
      include: ['usage_rights'],
    },
  })

  return exhaust(files)
}

// Get the whole folder hierachy from root to this path inclusive
export function getContextFolderHierarchy (context: CanvasContext, contextID: string, path: string): ApiPromise<Folder[]> {
  const url = `${context}/${contextID}/folders/by_path/${path}`
  const options = {
    params: {
      include: ['usage_rights'],
    },
  }
  return httpClient.get(url, options)
}

export function getFolder (folderID: string): ApiPromise<Folder> {
  const url = `folders/${folderID}`
  const options = {
    params: {
      include: ['usage_rights'],
    },
  }
  return httpClient.get(url, options)
}

export function getFile (fileID: string): ApiPromise<File> {
  return httpClient.get(`files/${fileID}`)
}

export function createFolder (context: CanvasContext, contextID: string, folder: NewFolder): ApiPromise<Folder> {
  return httpClient.post(`${context}/${contextID}/folders`, folder)
}

export function updateFolder (folderID: string, folder: UpdateFolderParameters): ApiPromise<Folder> {
  return httpClient.put(`folders/${folderID}`, folder)
}

export function deleteFolder (folderID: string, force?: boolean): ApiPromise<null> {
  return httpClient.delete(`folders/${folderID}`, { params: { force } })
}

export function updateFile (fileID: string, file: UpdateFileParameters): ApiPromise<File> {
  return httpClient.put(`files/${fileID}`, file)
}

export function deleteFile (fileID: string): ApiPromise<null> {
  return httpClient.delete(`files/${fileID}`)
}

export function updateCourseFileUsageRights (courseID: string, fileID: string, params: UpdateUsageRightsParameters): ApiPromise<UsageRights> {
  return httpClient.put(`courses/${courseID}/usage_rights`, {
    file_ids: [ fileID ],
    usage_rights: params,
  })
}
