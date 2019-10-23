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
    cache: new InMemoryCache({ fragmentMatcher }),
  })

  return client
}

export function clearClient () {
  client = null
}
