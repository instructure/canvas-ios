// @flow

import template from '../../../utils/template'
import { user } from './users'

export const enrollment: Template<Enrollment> = template({
  id: '32',
  user_id: '5123',
  user: user(),
  type: 'StudentEnrollment',
  enrollment_state: 'active',
})
