// @flow

const realPermissions = require.requireActual('../permissions')

export default ({
  ...realPermissions.default,
  checkMicrophone: jest.fn(() => Promise.resolve(true)),
  checkCamera: jest.fn(() => Promise.resolve(true)),
}: *)
