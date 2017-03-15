/* @flow */

import {
  BASE_URI,
  betaFeedbackFormURI,
} from '../form'

describe('beta feedback form uri', () => {
  it('has the device info pre-populated', () => {
    const expected = `${BASE_URI}?entry.1079876773=iOS&entry.1763625541=10.3&entry.50706604=iPhone+SE&entry.321299646=0.1.1992`
    expect(betaFeedbackFormURI).toEqual(expected)
  })
})
