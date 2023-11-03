export const getCsrfToken = (): string | null => {
  return sessionStorage.getItem('csrf_token')
}

export const createHeaders = (): HeadersInit => {
  const csrfToken = getCsrfToken()
  return {
    'Content-Type': 'application/json',
    'x-csrf-token': csrfToken || ''
  }
}

export const fetchData = async (url: string, method: string = 'GET', data?: object) => {
  const headers = createHeaders()
  const body = data ? JSON.stringify(data) : undefined

  const response = await fetch(url, {
    method: method,
    headers: headers,
    credentials: 'include',
    body: body
  })

  if (!response.ok) {
    const errorBody = await response.text()
    const error = new Error(`Fetch failed: ${errorBody}`)
    error.status = response.status
    throw error
  }

  if (response.status === 204 || response.headers.get('content-length') === '0') {
    return null
  }

  return response.json()
}