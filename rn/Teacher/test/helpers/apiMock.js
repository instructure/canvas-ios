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

function response<T> (mock: ApiResponse<T>): ApiPromise<T> {
  return new Promise((resolve, reject) => {
    process.nextTick(() => {
      resolve(mock)
    })
  })
}

type Next<T> = () => ApiPromise<T>
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
