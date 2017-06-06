/* @flow */
import { paginate } from '../utils/pagination'

export function getConversations (scope: InboxScope): Promise<ApiResponse<Conversation>> {
  const url = `conversations`
  const params: { [string]: any } = {
    per_page: 50,
  }

  if (scope !== 'all') {
    params.scope = scope
  }

  return paginate(url, { params })
}
