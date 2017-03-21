// @flow

import { Action } from 'redux'

export type CourseAction = Action & {
  +courseID: string,
}
