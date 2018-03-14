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

import httpClient from '../httpClient'
import { getFile } from './files'

type UploadTarget = {
  upload_url: string,
  upload_params: any,
}

export type UploadOptions = {
  path: string,
  parentFolderID?: ?string,
  parentFolderPath?: ?string,
  onProgress?: (Progress) => void,
  cancelUpload?: (() => void) => void,
}

export type Progress = {
  loaded: number,
  total: number,
}

export async function uploadAttachment (attachment: Attachment, options: UploadOptions): Promise<File> {
  const target = await requestUploadTarget(attachment, options)
  const file = await postFile(attachment.uri, target, options)

  // GET the file because we need the url to contain the verifier token
  const response = await getFile(file.id)
  return response.data
}

// Helpers

async function requestUploadTarget (attachment: Attachment, options: UploadOptions): Promise<UploadTarget> {
  const params: any = {
    name: attachment.filename || attachment.display_name,
    on_duplicate: 'rename',
  }
  if (attachment.size) params.size = attachment.size
  if (options.parentFolderID) params.parent_folder_id = options.parentFolderID
  if (options.parentFolderPath) params.parent_folder_path = options.parentFolderPath

  const response = await httpClient().post(options.path, params)
  if (response.data.attachments && response.attachments.length) {
    return response.data.attachments[0]
  }
  return response.data
}

async function postFile (uri: string, target: UploadTarget, options: UploadOptions): Promise<File> {
  const { upload_url, upload_params } = target
  const formdata = new FormData()
  Object.keys(upload_params).forEach(key => formdata.append(key, upload_params[key]))
  // $FlowFixMe
  formdata.append('file', {
    uri,
    type: 'multipart/form-data',
  })

  const uploading = httpClient().post(upload_url, formdata, {
    headers: { // remove default auth & accept
      'Authorization': null,
      'Accept': 'application/json',
    },
  })
  const request = uploading.request
  if (request) {
    request.upload.addEventListener('progress', ({ loaded, total }) => {
      options.onProgress && options.onProgress({ loaded, total })
    })
    options.cancelUpload && options.cancelUpload(() => request.abort())
  }
  const response = await uploading

  return response.data
}
