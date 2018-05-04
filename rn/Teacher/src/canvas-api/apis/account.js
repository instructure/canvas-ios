//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow

import httpClient from '../httpClient'
import { paginate, exhaust } from '../utils/pagination'

export function getAccountNotifications (): ApiPromise<AccountNotification[]> {
  const groups = paginate(`accounts/self/users/self/account_notifications`, {
    params: {
      per_page: 99,
    },
  })
  return exhaust(groups)
}

export function deleteAccountNotification (id: string): ApiPromise<null> {
  return httpClient().delete(`accounts/self/users/self/account_notifications/${id}`)
}

export function getTermsOfService (): ApiPromise<TermsOfService> {
  return httpClient().get(`accounts/self/terms_of_service`)
}
