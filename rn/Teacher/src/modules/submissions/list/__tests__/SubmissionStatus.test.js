// @flow

import 'react-native'
import React from 'react'
import SubmissionStatus from '../SubmissionStatus'
import renderer from 'react-test-renderer'

describe('SubmissionStatus', () => {
  it('status `none` renders properly', () => {
    let tree = renderer.create(
      <SubmissionStatus status={'none'} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('status `missing` renders properly', () => {
    let tree = renderer.create(
      <SubmissionStatus status={'missing'} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('status `late` renders properly', () => {
    let tree = renderer.create(
      <SubmissionStatus status={'late'} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('status `submitted` renders properly', () => {
    let tree = renderer.create(
      <SubmissionStatus status={'submitted'} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })
})
