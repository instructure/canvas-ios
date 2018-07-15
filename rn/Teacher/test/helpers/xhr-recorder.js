//
// Copyright (C) 2018-present Instructure, Inc.
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

import fakeXHR from 'nise/lib/fake-xhr'
import { NativeModules } from 'react-native'

const { VCR } = NativeModules

fakeXHR.useFakeXMLHttpRequest()
const RealXHR = fakeXHR.xhr.GlobalXMLHttpRequest

fakeXHR.FakeXMLHttpRequest.onCreate = (xhr) => {
  xhr.onSend = async () => {
    let requestKey = buildRequestConfig(xhr)
    let response = await VCR.responseForRequest(JSON.stringify(requestKey))
    if (response) {
      let responseData = JSON.parse(response)
      xhr.respond(
        responseData.statusCode,
        responseData.headers,
        responseData.responseText
      )
    } else {
      console.warn('request is not mocked', requestKey)
      await fulfillXHR(xhr)
    }
  }
}

async function fulfillXHR (fakeXHR) {
  const xhr = new RealXHR()

  xhr.open(
    fakeXHR.method,
    fakeXHR.url,
    fakeXHR.async,
    fakeXHR.username,
    fakeXHR.password
  )

  xhr.async = fakeXHR.async

  if (fakeXHR.async) {
    xhr.timeout = fakeXHR.timeout
    xhr.withCredentials = fakeXHR.withCredentials
  }

  for (const h in fakeXHR.requestHeaders) {
    xhr.setRequestHeader(h, fakeXHR.requestHeaders[h])
  }

  await resolveXhr(xhr, fakeXHR.body)
  await fakeXHR.respond(
    xhr.status,
    serializeResponseHeaders(xhr.getAllResponseHeaders()),
    xhr.responseText
  )
  await recordXHR(fakeXHR, xhr)
}

function resolveXhr (xhr, body) {
  return new Promise(resolve => {
    xhr.send(body)

    if (xhr.async) {
      const { onreadystatechange } = xhr

      xhr.onreadystatechange = (...args) => {
        onreadystatechange && onreadystatechange.apply(xhr, ...args)
        xhr.readyState === fakeXHR.FakeXMLHttpRequest.DONE && resolve()
      }
    } else {
      resolve()
    }
  })
}

function serializeResponseHeaders (responseHeaders = '') {
  return responseHeaders.split('\n').reduce((headers, header) => {
    const [key, value] = header.split(':')

    if (key) {
      headers[key] = value.replace(/(\r|\n|^\s+)/g, '')
    }

    return headers
  }, {})
}

function buildRequestConfig (xhr) {
  return {
    url: xhr.url,
    method: xhr.method,
    body: xhr.body,
  }
}

function buildResponseConfig (xhr) {
  return {
    status: xhr.status,
    headers: serializeResponseHeaders(xhr.getAllResponseHeaders()),
    responseText: xhr.responseText,
  }
}

function recordXHR (fakeXHR, realXHR) {
  let requestConfig = buildRequestConfig(fakeXHR)
  let responseConfig = buildResponseConfig(realXHR)

  let requestKey = JSON.stringify(requestConfig)
  let responseValue = JSON.stringify(responseConfig)

  return VCR.recordRequest(requestKey, responseValue)
}
