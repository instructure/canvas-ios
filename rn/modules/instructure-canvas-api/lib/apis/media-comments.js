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
