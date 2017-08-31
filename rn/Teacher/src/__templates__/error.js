/* @flow */

import template, { type Template } from '../utils/template'

export const apiError: Template<ApiError> = template({
  status: 500,
  data: {
    errors: [{ message: 'Something went wrong.' }],
  },
})

export function error (message: string): ApiError {
  return apiError({
    data: {
      errors: [{ message: message }],
    },
  })
}
