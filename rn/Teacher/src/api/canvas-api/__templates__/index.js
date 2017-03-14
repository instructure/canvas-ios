// @flow
import * as course from './course'
import * as session from './session'

export default ({
  ...course,
  ...session,
}: typeof course & typeof session)
