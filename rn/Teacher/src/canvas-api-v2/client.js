//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import { getSession } from '../canvas-api/session'
import { InMemoryCache, IntrospectionFragmentMatcher } from 'apollo-cache-inmemory'
import { ApolloClient } from 'apollo-client'
import { HttpLink } from 'apollo-link-http'
import graphqlSchema from './schema.json'

let client

export function getURI () {
  const session = getSession()
  return `${session.baseURL.replace(/\/?$/, '')}/api/graphql`
}

export default function getClient () {
  if (client != null) return client

  const uri = getURI()
  const headers = {
    'GraphQL-Metrics': true,
  }

  let fragmentMatcher = new IntrospectionFragmentMatcher({
    introspectionQueryResultData: graphqlSchema,
  })

  client = new ApolloClient({
    link: new HttpLink({ uri, headers }),
    cache: new InMemoryCache({ addTypename: false, fragmentMatcher }),
  })

  return client
}

export function clearClient () {
  client = null
}
