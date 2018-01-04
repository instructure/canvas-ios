// @flow

import template, { type Template } from '../utils/template'

export const rolePermissions: Template<RolePermissions> = template({
  enabled: true,
})

export const role: Template<Role> = template({
  permissions: {
    become_user: rolePermissions(),
  },
})

