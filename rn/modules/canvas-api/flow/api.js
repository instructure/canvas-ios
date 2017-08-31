/* @flow */

import canvas from '../apis/'

export type ApiResponse<T> = AxiosResponse<T> & {
  next: ?(() => Promise<ApiResponse<T>>),
}

export type ApiError = {
  status: number,
  data: {
    errors: { message: string }[],
  },
}

export type CanvasApi = typeof canvas