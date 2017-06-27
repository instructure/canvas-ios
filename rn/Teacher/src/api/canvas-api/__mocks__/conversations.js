// @flow

const { apiResponse } = require.requireActual('../../../../test/helpers/apiMock')
const template = require('../__templates__/conversations')

export let createConversationMock: Function
export function createConversation (conversation: CreateConversationParameters): Promise<ApiResponse<Conversation>> {
  createConversationMock = apiResponse(template.conversation(conversation))
  return createConversationMock(conversation)
}

export let addMessageMock: Function
export function addMessage (conversationID: string, message: CreateConversationParameters): Promise<ApiResponse<Conversation>> {
  addMessageMock = apiResponse(template.conversation(message))
  return addMessageMock(conversationID, message)
}
