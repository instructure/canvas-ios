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

import canvas from '../apis/'

export type ApiConfig = {
  baseURL?: string,
  headers?: { [string]: ?string },
  params?: { [string]: any },
  timeout?: number,
  responseType?: 'text' | 'json' | 'blob' | 'arraybuffer', // 'document' is not supported by react-native
  excludeVersion?: boolean,
  transform?: Function,
  cacheKey?: string,
  ttl?: number, // milliseconds
}

export type ApiResponse<T> = {
  data: T,
  status: number,
  headers: {
    link: ?string,
  },
  next?: ?() => ApiPromise<T>,
}

export type ApiError = {
  status: number,
  data: {
    errors: { message: string }[],
  },
}

export type ApiPromise<T> = {
  request?: XMLHttpRequest,
} & Promise<ApiResponse<T>>

export type CanvasApi = typeof canvas
