/* @flow */

export type DeviceInfo = {
  getSystemVersion: () => string,
  getModel: () => string,
  getReadableVersion: () => string,
}
