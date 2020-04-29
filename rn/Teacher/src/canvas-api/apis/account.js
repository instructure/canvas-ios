//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow

import httpClient from '../httpClient'
import { paginate, exhaust } from '../utils/pagination'

export function getAccountNotifications (): ApiPromise<AccountNotification[]> {
  const groups = paginate(`accounts/self/users/self/account_notifications`, {
    params: {
      per_page: 100,
    },
  })
  return exhaust(groups)
}

export function deleteAccountNotification (id: string): ApiPromise<null> {
  return httpClient.delete(`accounts/self/users/self/account_notifications/${id}`)
}

export function getLiveConferences () {
  return httpClient.get(`conferences?state=live`)
}

export function getTermsOfService (): ApiPromise<TermsOfService> {
  return httpClient.get(`accounts/self/terms_of_service`)
}

export function getHelpLinks (): ApiResponse<HelpLink[]> {
  return httpClient.get('accounts/self/help_links')
}
