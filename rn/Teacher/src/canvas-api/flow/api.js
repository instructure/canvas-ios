//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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

export type ApiPromiseRejection = {
  config: ApiConfig,
  error: Error,
  request: XMLHttpRequest,
  response: ?ApiResponse<Object>,
} & Error

export type CanvasApi = typeof canvas
