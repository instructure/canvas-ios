/* @flow */

export type ApiResponse<T> = {
  data: T,
  status: number,
}

export type PaginatedApiResponse<T> = {
  data: T,
  status: number,
  next: ?(() => Promise<PaginatedApiResponse<T>>),
}
