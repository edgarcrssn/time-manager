import { ref, watchEffect } from 'vue'

export interface EventBus {
  emitEvent: (eventName: string) => void
  onEvent: (callback: (eventName: string) => void) => void
}

const eventBus = ref<null | string>(null)

function emitEvent (eventName: string): void {
  eventBus.value = eventName
}

function onEvent (callback: (eventName: string) => void): void {
  watchEffect(() => {
    if (eventBus.value) {
      callback(eventBus.value)
      eventBus.value = null // Réinitialisez l'événement après l'avoir traité
    }
  })
}

export function provideEventBus (): EventBus {
  return {
    emitEvent,
    onEvent
  }
}
