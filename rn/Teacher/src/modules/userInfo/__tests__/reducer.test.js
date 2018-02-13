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
      const apps = [template.launchDefinition()]
      const resolved = {
        type: refreshAccountExternalTools.toString(),
        payload: { result: { data: apps } },
      }

      expect(userInfo({ }, resolved)).toMatchObject({
        externalTools: [template.launchDefinitionGlobalNavigationItem()],
      })
    })
  })

  describe('refreshCanMasquerade', () => {
    it('can because permissions', () => {
      const roles = [
        template.role({
          permissions: {
            become_user: template.rolePermissions({ enabled: true }),
          },
        }),
      ]
      const resolved = {
        type: refreshCanMasquerade.toString(),
        payload: { result: { data: roles } },
      }

      expect(userInfo({ canMasquerade: false }, resolved)).toMatchObject({
        canMasquerade: true,
      })
    })

    it('cant because permissions', () => {
      const roles = [
        template.role({
          permissions: {
            become_user: template.rolePermissions({ enabled: false }),
          },
        }),
      ]
      const resolved = {
        type: refreshCanMasquerade.toString(),
        payload: { result: { data: roles } },
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
