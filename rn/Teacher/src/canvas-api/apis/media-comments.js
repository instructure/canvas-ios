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
import { type Progress } from './file-uploads'

type MediaUploadOptions = {
  onProgress?: (Progress) => void,
  cancelUpload?: (() => void) => void,
}

export async function uploadMedia (uri: string, type: string, options: MediaUploadOptions = {}): Promise<string> {
  const domain = await getMediaServerDomain()
  const session = await getMediaSession()
  const token = await getUploadToken(domain, session)
  await postUpload(uri, domain, session, token, type, options)
  return getMediaID(domain, session, token, type)
}

// HELPERS

async function getMediaServerDomain (): Promise<string> {
  const response = await httpClient().get('/services/kaltura')
  return response.data.domain
}

async function getMediaSession (): Promise<string> {
  const response = await httpClient().post('/services/kaltura_session')
  return response.data.ks
}

async function getUploadToken (domain: string, session: string): Promise<string> {
  const url = uploadURL(domain, 'uploadtoken', 'add')
  const response = await httpClient().post(url, { ks: session }, {
    responseType: 'text',
    headers: { // remove default auth & accept
      'Authorization': null,
      'Accept': 'application/xml',
    },
  })
  return response.data.match(/<id>([^<]+)<\/id>/)[1]
}

async function postUpload (uri: string, domain: string, session: string, token: string, type: string, options: MediaUploadOptions): Promise<string> {
  const url = `${uploadURL(domain, 'uploadtoken', 'upload')}&uploadTokenId=${token}&ks=${session}`
  const formdata = new FormData()
  // $FlowFixMe
  formdata.append('fileData', {
    uri,
    name: type === 'video' ? 'videocomment.mp4' : 'audiocomment.wav',
    type: 'multipart/form-data',
  })

  const uploading = httpClient().post(url, formdata, {
    responseType: 'text',
    headers: { // remove default auth & accept
      'Authorization': null,
      'Accept': null,
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

async function getMediaID (domain: string, session: string, token: string, type: string): Promise<string> {
  const url = `${uploadURL(domain, 'media', 'addFromUploadedFile')}&uploadTokenId=${token}&ks=${session}`
  const response = await httpClient().post(url, {
    'mediaEntry:name': 'Media Comment',
    'mediaEntry:mediaType': type === 'video' ? '1' : '5',
  }, {
    responseType: 'text',
    headers: { // remove default auth & accept
      'Authorization': null,
      'Accept': 'application/xml',
    },
  })
  return response.data.match(/<id>([^<]+)<\/id>/)[1]
}

// UTILS

function formatDomain (domain) {
  if (!domain.startsWith('https')) {
    domain = `https://${domain}`
  }
  if (domain.endsWith('/')) {
    domain = domain.slice(0, -1)
  }
  return domain
}

function uploadURL (domain: string, service: string, action: string): string {
  return `${formatDomain(domain)}/api_v3/index.php?service=${service}&action=${action}`
}
