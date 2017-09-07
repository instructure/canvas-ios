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

/* @flow */

import httpClient from '../httpClient'
import axios from 'axios'
import { DOMParser } from 'xmldom'

export async function uploadMedia (uri: string, type: string): Promise<string> {
  const domain = await getMediaServerDomain()
  const session = await getMediaSession()
  const token = await getUploadToken(domain, session)
  await postUpload(uri, domain, session, token, type)
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
  const response = await axios.post(url, { ks: session })
  const doc = new DOMParser().parseFromString(response.data, 'text/xml')
  return doc.getElementsByTagName('id')[0].textContent
}

async function postUpload (uri: string, domain: string, session: string, token: string, type: string): Promise<string> {
  const url = `${uploadURL(domain, 'uploadtoken', 'upload')}&uploadTokenId=${token}&ks=${session}`
  const formdata = new FormData()
  // $FlowFixMe
  formdata.append('fileData', {
    uri,
    name: type === 'video' ? 'videocomment.mp4' : 'audiocomment.wav',
    type: 'multipart/form-data',
  })
  const response = await axios.post(url, formdata)
  return response.data
}

async function getMediaID (domain: string, session: string, token: string, type: string): Promise<string> {
  const url = `${uploadURL(domain, 'media', 'addFromUploadedFile')}&uploadTokenId=${token}&ks=${session}`
  const response = await axios.post(url, {
    'mediaEntry:name': 'Media Comment',
    'mediaEntry:mediaType': type === 'video' ? '1' : '5',
  })
  const doc = new DOMParser().parseFromString(response.data, 'text/xml')
  return doc.getElementsByTagName('id')[0].textContent
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
