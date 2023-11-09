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

export const formatStringToCreateDate = (date: Date, time: string): string => {
  let month = date.getMonth().toString()
  let day = date.getDate().toString()
  if (date.getDate() < 10) {
    day = '0' + date.getDate().toString()
  }
  if (date.getMonth() < 10) {
    month = '0' + date.getMonth().toString()
  }

  return `${date.getFullYear().toString()}-${month}-${day}T${time}`
}
