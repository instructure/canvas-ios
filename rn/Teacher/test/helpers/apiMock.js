/* @flow */

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
  const mock = response({
    data: data,
    status: opts.status || 200,
    headers: opts.headers || { link: null },
    next: opts.next,
  })
  return jest.fn(() => mock)
}

export function apiError (errorDetails?: { status?: number, message?: string }): Function {
  const mock = error((errorDetails && errorDetails.status) || 401, (errorDetails && errorDetails.message) || 'Default mock api error')
  return jest.fn(() => mock)
}
