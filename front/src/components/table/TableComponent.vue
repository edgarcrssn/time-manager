<template>
  <div class="rounded-xl overflow-hidden bg-black">
    <div class="rounded-xl bg-white">
      <table class="w-full text-center">
        <thead>
          <tr>
            <th
              v-for="thName in titleProperty"
              :key="thName"
            >
              {{ thName }}
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="donnee in data"
            v-if="typeTable == 'user'"
            :key="donnee"
          >
            <td>{{ donnee.username }}</td>
            <td>{{ donnee.email }}</td>
            <td>
              <button type="button" @click="$emit('itemDeleted', donnee.id)">
                <img
                  alt="delete"
                  src="../../assets/calendar_icon.svg"
                  class="w-5 h-5"
                >
              </button>
              <button
                type="button"
                @click="deleteUser(donnee.id)"
              >
                <img
                  alt="delete"
                  src="../../assets/delete_icon.svg"
                  class="w-5 h-5"
                >
              </button>
            </td>
          </tr>

          <tr
            v-for="(donnee, id) in data"
            v-if="typeTable == 'team'"
            :key="id"
          >
            <td>{{ donnee.name }}</td>
            <td>
              <button
                type="button"
                @click="deleteUser(id)"
              >
                <img
                  alt="delete"
                  src="../../assets/delete_icon.svg"
                  class="w-5 h-5"
                >
              </button>
            </td>
          </tr>

          <tr
            v-for="time in data"
            v-if="typeTable == 'workingTimes'"
            :key="time.id"
          >
            <td class="border p-2">
              {{ time.id }}
            </td>
            <td class="border p-2">
              {{ formatDate(time.start) }}
            </td>
            <td class="border p-2">
              {{ formatDate(time.end) }}
            </td>
            <td class="border p-2">
              {{ time.user_id }}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { formatDate } from '../../helpers/dateUtils'

const emit = defineEmits(['itemDeleted'])
defineProps({
  titleProperty: {
    required: true,
    type: Array as () => string[]
  },
  data: {
    required: true,
    type: Array as () => any[]
  },
  tableName: {
    required: true,
    type: String
  },
  typeTable: {
    required: true,
    type: String
  }
})
const deleteUser = (id: number) => {
  fetch(`${import.meta.env.VITE_API_URL}/api/users/${id}`, {
    method: 'DELETE',
    redirect: 'follow'
  })
    .then((response: Response) => {
      if (response.ok) {
        emit('itemDeleted', id)
      }
    })
    .catch((error: Error) => console.error('error', error))
}
</script>

<style scoped></style>
