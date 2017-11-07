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

// @flow

export type AxiosRequestConfig = {
  url?: string,
  method?: string,
  baseURL?: string,
  transformRequest?: Function,
  transformResponse?: Function,
  headers?: any,
  params?: any,
  paramsSerializer: Function,
  data?: any,
  timeout?: number,
  withCredentials?: boolean,
  adapter?: Function,
  auth?: any,
  responseType?: 'arraybuffer' | 'blob' | 'document' | 'json' | 'text' | 'stream',
  xsrfCookieName?: string,
  xsrfHeaderName?: string,
  onUploadProgress?: Function,
  onDownloadProgress?: Function,
  maxContentLength?: number,
  validateStatus?: Function,
  maxRedirects?: number,
  httpAgent?: any,
  httpsAgent?: any,
  proxy?: any,
  cancelToken?: any,
}

export type AxiosResponse<T> = {
  data: T,
  status: number,
  headers: {
    link: ?string,
  },
}
