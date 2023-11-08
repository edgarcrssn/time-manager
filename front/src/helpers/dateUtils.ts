export const formatDate = (dateString: string): string => {
  return new Date(dateString).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

export const getTimeElapsedSinceDate = (dateString: string): string => {
  const date = new Date(dateString).getTime()
  const now = new Date().getTime() - 3600000

  const timeElapsed = now - date

  const hours = Math.floor((timeElapsed % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
  const minutes = Math.floor((timeElapsed % (1000 * 60 * 60)) / (1000 * 60))
  const seconds = Math.floor((timeElapsed % (1000 * 60)) / 1000)

  return `${hours ? `${hours}h ` : ''}${minutes ? `${minutes}m ` : ''}${seconds}s`
}
