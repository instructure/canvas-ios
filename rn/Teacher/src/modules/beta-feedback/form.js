/* @flow */

import googleForm from '../../common/google-form'

export const BASE_URI: string = 'https://docs.google.com/forms/d/e/1FAIpQLSeBW9mUTkwMUXpIr4LOE_jtAXzynjWExUDsfg98_ktBldq_6A/viewform'

const form = googleForm(BASE_URI, {
  os: '1079876773',
  osVersion: '1763625541',
  device: '50706604',
  betaVersion: '321299646',
  email: '941918261',
})

export function betaFeedbackForm (user: SessionUser, device: DeviceInfo): string {
  return form({
    os: 'iOS',
    osVersion: device.getSystemVersion(),
    device: device.getModel(),
    betaVersion: device.getReadableVersion(),
    email: user.primary_email,
  })
}
