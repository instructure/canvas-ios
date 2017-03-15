/* @flow */

import googleForm from '../../common/google-form'
import device from 'react-native-device-info'

export const BASE_URI: string = 'https://docs.google.com/forms/d/e/1FAIpQLSeBW9mUTkwMUXpIr4LOE_jtAXzynjWExUDsfg98_ktBldq_6A/viewform'

const betaFeedbackForm = googleForm(BASE_URI, {
  os: '1079876773',
  osVersion: '1763625541',
  device: '50706604',
  betaVersion: '321299646',
  email: '941918261',
})

export const betaFeedbackFormURI: string = betaFeedbackForm({
  os: 'iOS',
  osVersion: device.getSystemVersion(),
  device: device.getModel(),
  betaVersion: device.getReadableVersion(),
})
