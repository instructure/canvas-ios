//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

// @flow

import { shallow } from 'enzyme'
import React from 'react'
import { NativeModules } from 'react-native'
import AppRatingPrompt from '../AppRatingPrompt'
import * as templates from '../../../__templates__'

describe('AppRatingPrompt', () => {
  const defaults = {
    style: { width: 320, padding: 8 },
    collapsed: false,
    navigator: templates.navigator(),
  }

  beforeEach(() => {
    jest.resetAllMocks()
  })

  it('renders', () => {
    const tree = shallow(
      <AppRatingPrompt {...defaults} />
    )
    expect(tree).toMatchSnapshot()
  })

  it('renders hidden', () => {
    const tree = shallow(
      <AppRatingPrompt {...defaults} collapsed={true} />
    )
    expect(tree).toMatchSnapshot()
  })

  it('can like app', () => {
    const tree = shallow(
      <AppRatingPrompt {...defaults} />
    )
    tree.find('[testID="prompt-to-rate.button.yes"]').simulate('Press')
    expect(NativeModules.AppStoreReview.handleUserFeedbackOnDashboard).toHaveBeenCalledWith(true)
    expect(NativeModules.CanvasAnalytics.logEvent).toHaveBeenCalledWith('appReview_userAccepted', undefined)
  })

  it('can not like app', () => {
    const tree = shallow(
      <AppRatingPrompt {...defaults} />
    )
    tree.find('[testID="prompt-to-rate.button.no"]').simulate('Press')
    expect(NativeModules.AppStoreReview.handleUserFeedbackOnDashboard).toHaveBeenCalledWith(false)
    expect(NativeModules.CanvasAnalytics.logEvent).toHaveBeenCalledWith('appReview_userDeclined', undefined)
    expect(defaults.navigator.show).toHaveBeenCalledWith('/support/problem', { 'modal': true })
  })

  it('can hide', () => {
    const props = {
      ...defaults,
    }
    const tree = shallow(
      <AppRatingPrompt {...props} />
    )
    tree.find('[testID="prompt-to-rate.butotn.dismiss"]').simulate('Press')
    expect(tree).toMatchSnapshot()
  })

  it('dismiss pressed', () => {
    const tree = shallow(
      <AppRatingPrompt {...defaults} />
    )
    tree.find('[testID="prompt-to-rate.butotn.dismiss"]').simulate('Press')
    expect(NativeModules.AppStoreReview.handleUserFeedbackOnDashboard).toHaveBeenCalledWith(false)
    expect(tree.instance().state.collapsed).toBe(true)
  })
})
