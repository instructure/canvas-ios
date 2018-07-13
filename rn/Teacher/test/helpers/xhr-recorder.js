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
