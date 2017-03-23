/* @flow */

import {
  BASE_URI,
  betaFeedbackForm,
} from '../form'

import device from 'react-native-device-info'

const template = {
  ...require('../../../api/canvas-api/__templates__/session'),
}

describe('beta feedback form uri', () => {
  it('has the device info pre-populated', () => {
    const session = template.session({
      user: {
        ...template.session().user,
        primary_email: 'beta@feedback.com',
      },
    })
    const expected = `${BASE_URI}?entry.1079876773=iOS&entry.1763625541=10.3&entry.50706604=iPhone+SE&entry.321299646=0.1.1992&entry.941918261=beta@feedback.com`
    expect(betaFeedbackForm(session.user, device)).toEqual(expected)
  })
})
