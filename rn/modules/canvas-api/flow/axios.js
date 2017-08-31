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
