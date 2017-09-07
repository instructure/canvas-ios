/* @flow */

import httpClient from '../httpClient'
import axios, { CancelToken } from 'axios'

type UploadTarget = {
  upload_url: string,
  upload_params: any,
}

export type UploadOptions = {
  path: string,
  parentFolderID?: string,
  parentFolderPath?: string,
  onProgress?: (Progress) => void,
  cancelUpload: (() => void) => void,
}

export type Progress = {
  loaded: number,
  total: number,
}

export async function uploadAttachment (attachment: Attachment, options: UploadOptions): Promise<File> {
  const target = await requestUploadTarget(attachment, options)
  return await postFile(attachment.uri, target, options)
}

// Helpers

async function requestUploadTarget (attachment: Attachment, options: UploadOptions): Promise<UploadTarget> {
  const params: any = {
    name: attachment.filename || attachment.display_name,
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

  const cancelToken = new CancelToken(c => options.cancelUpload && options.cancelUpload(c))
  const response = await axios.post(upload_url, formdata, {
    onUploadProgress: ({ loaded, total }) => { options.onProgress && options.onProgress({ loaded, total }) },
    cancelToken,
  })
  return response.data
}
