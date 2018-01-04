// @flow

export type Role = {
  permissions: {
    become_user?: RolePermissions,
  },
}

export type RolePermissions = {
  enabled: boolean,
}
