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

/* eslint-disable flowtype/require-valid-file-annotation */

import { userInfo } from '../reducer'
import Actions from '../actions'

const { refreshCanMasquerade, refreshAccountExternalTools } = Actions

const template = {
  ...require('../../../__templates__/role'),
  ...require('../../../__templates__/error'),
  ...require('../../../__templates__/launch-definitions'),
}

describe('userInfo', () => {
  describe('refresh lti apps', () => {
    it('resolves', () => {
      const lti = template.launchDefinition()
      const apps = [lti]
      const resolved = {
        type: refreshAccountExternalTools.toString(),
        payload: { result: { data: apps } },
      }

      expect(userInfo({ }, resolved)).toMatchObject({
        externalTools: [lti],
      })
    })
  })

  describe('matches gauge by launch url', () => {
    const gauge1 = template.launchDefinitionGlobalNavigationItem({
      url: 'https://test.gauge-edge.inseng.net/lti/launch',
    })
    const app1 = template.launchDefinition({
      placements: { global_navigation: gauge1 },
    })
    const gauge2 = template.launchDefinitionGlobalNavigationItem({
      url: 'https://gauge.docker/lti/launch',
    })
    const app2 = template.launchDefinition({
      domain: 'gauge.instructure.com',
      placements: { global_navigation: gauge2 },
    })
    const app3 = template.launchDefinition({ domain: null,
      placements: { global_navigation: template.launchDefinitionGlobalNavigationItem() },
    })
    const app4 = template.launchDefinition({
      domain: 'somewhere-else.com',
      placements: { global_navigation: gauge1 },
    })
    const gauge5 = template.launchDefinitionGlobalNavigationItem({
      url: 'https://usu.gauge-iad-prod.instructure.com/lti/launch',
    })
    const app5 = template.launchDefinition({
      placements: { global_navigation: gauge5 },
    })
    const app6 = template.launchDefinition({ domain: 'arc.instructure.com',
      name: 'Arc',
      description: 'Video',
      placements: { global_navigation: template.launchDefinitionGlobalNavigationItem({ title: 'Arc' }) },
    })
    const app7 = template.launchDefinition({ domain: null,
      name: 'Arc',
      description: 'Video',
      placements: { global_navigation: template.launchDefinitionGlobalNavigationItem({ title: 'Arc', url: 'https://usu.arc-iad-prod.instructure.com/lti/launch' }) },
    })
    const app8 = template.launchDefinition({ domain: 'commons.instructure.com',
      name: 'Commons',
      description: 'commons description',
      placements: { global_navigation: template.launchDefinitionGlobalNavigationItem({ title: 'Commons' }) },
    })
    const resolved = {
      type: refreshAccountExternalTools.toString(),
      payload: { result: { data: [ app1, app2, app3, app4, app5, app6, app7, app8 ] } },
    }

    expect(userInfo({ }, resolved)).toEqual({
      externalTools: [
        app1,
        app2,
        app5,
        app6,
        app7,
      ],
    })
  })

  describe('refreshCanMasquerade', () => {
    it('can because permissions', () => {
      const role = template.role()

      const resolved = {
        type: refreshCanMasquerade.toString(),
        payload: { result: { data: role } },
      }

      expect(userInfo({ canMasquerade: false }, resolved)).toMatchObject({
        canMasquerade: true,
      })
    })

    it('cant because permissions', () => {
      const role = template.role({
        become_user: false,
      })

      const resolved = {
        type: refreshCanMasquerade.toString(),
        payload: { result: { data: role } },
      }

      expect(userInfo({ canMasquerade: true }, resolved)).toMatchObject({
        canMasquerade: false,
      })
    })

    it('cant because rejected', () => {
      const rejected = {
        type: refreshCanMasquerade.toString(),
        error: true,
        payload: { error: template.error() },
      }

      expect(userInfo({ canMasquerade: true }, rejected)).toMatchObject({
        canMasquerade: false,
      })
    })
  })
})
