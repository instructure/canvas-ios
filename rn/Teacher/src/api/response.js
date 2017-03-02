/* @flow */

export type ApiResponse<T> = {
  data: T,
  status: number,
  headers: {
    link: ?string,
  },
  next: ?(() => Promise<ApiResponse<T>>),
}

export type ApiError = {
  response: {
    status: number,
    data: {
      errors: { message: string }[],
    },
  },
}
