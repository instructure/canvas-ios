/* @flow */

import { createAction } from 'redux-actions'

export const updateAssignmentDescription: (id: string, description: string) => * = createAction('assignment.update.description', (id, description) => ({
  id,
  description,
}))
