// @flow

export type AxiosRequestConfig = {
  url?: string,
  method?: string,
  baseURL?: string,
  transformRequest?: Function,
  transformResponse?: Function,
  headers?: any,
  params?: any,
  paramsSerializer: Function,
  data?: any,
  timeout?: number,
  withCredentials?: boolean,
  adapter?: Function,
  auth?: any,
  responseType?: 'arraybuffer' | 'blob' | 'document' | 'json' | 'text' | 'stream',
  xsrfCookieName?: string,
  xsrfHeaderName?: string,
  onUploadProgress?: Function,
  onDownloadProgress?: Function,
  maxContentLength?: number,
  validateStatus?: Function,
  maxRedirects?: number,
  httpAgent?: any,
  httpsAgent?: any,
  proxy?: any,
  cancelToken?: any,
}

export type AxiosResponse = {
  data: T,
  status: number,
  headers: {
    link: ?string,
  },
}
