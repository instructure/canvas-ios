/* @flow */

export type ApiResponse<T> = AxiosResponse & {
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
