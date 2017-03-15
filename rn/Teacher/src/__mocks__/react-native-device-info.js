/* @flow */

export type DeviceInfo = {
  getSystemVersion: () => string,
  getModel: () => string,
  getReadableVersion: () => string,
}

export default ({
  getSystemVersion: () => '10.3',
  getModel: () => 'iPhone SE',
  getReadableVersion: () => '0.1.1992',
}: DeviceInfo)
