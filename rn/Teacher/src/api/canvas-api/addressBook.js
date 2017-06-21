// @flow
import httpClient from './httpClient'
import { CancelToken } from 'axios'

// Return type differs than other api requests because this is a cancellable request
export function searchAddressBook (searchString?: ?string, courseID?: ?string, groupID?: ?string): { promise: Promise<ApiResponse<AddressBookResult>>, cancel: Function } {
  const url = 'search/recipients'
  const params: { [string]: any } = {}

  if (searchString) {
    params.search = searchString
  }

  if (courseID) {
    params.context = `course_${courseID}`
  }

  if (groupID) {
    params.context = `group_${groupID}`
  }

  let cancel = () => {}
  const options: { [string]: any} = {
    params,
    cancelToken: new CancelToken((c) => {
      cancel = c
    }),
  }

  const promise = httpClient().get(url, options)
  return {
    promise,
    cancel,
  }
}
