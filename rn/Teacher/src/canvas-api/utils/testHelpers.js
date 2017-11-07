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

export const DEFAULT_ERROR_MESSAGE: string = 'Default mock api error'

function error<T> (status: number, message: string): Promise<ApiError<T>> {
  return new Promise((resolve, reject) => {
    process.nextTick(() => {
      reject({
        status: status,
        data: {
          errors: [{ message: message }],
        },
      })
    })
  })
}

function response<T> (mock: ApiResponse<T>): Promise<ApiResponse<T>> {
  return new Promise((resolve, reject) => {
    process.nextTick(() => {
      resolve(mock)
    })
  })
}

type Next<T> = () => Promise<ApiResponse<T>>
type MockResponseOptions<T> = {
  status?: ?number,
  headers?: ?{ link?: ?string },
  next?: ?Next<T>,
}

export function apiResponse<T> (data: T, opts: MockResponseOptions<T> = {}): Function {
  const mock = (data) => response({
    data: data,
    status: opts.status || 200,
    headers: opts.headers || { link: null },
    next: opts.next,
  })

  if (typeof data === 'function') {
    // $FlowFixMe
    return jest.fn((...args) => mock(data.apply(null, args)))
  }

  return jest.fn(() => mock(data))
}

export function apiError (errorDetails?: { status?: number, message?: string }): Function {
  const mock = error((errorDetails && errorDetails.status) || 401, (errorDetails && errorDetails.message) || DEFAULT_ERROR_MESSAGE)
  return jest.fn(() => mock)
}
