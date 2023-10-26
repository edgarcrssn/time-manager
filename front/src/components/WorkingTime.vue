<script lang="ts">
import { onMounted } from 'vue'

export default {
  props: {
    workingTime: {
      type: Object,
      required: true
    }
  },
  setup (props) {
    console.log(props)

    onMounted(() => {
      console.log('mounted')
    })

    return {
      props
    }
  }
}
</script>

<template>
  <ul>
    <li>
      id: {{ props.workingTime.id }}
    </li>
    <li>
      start: {{ props.workingTime.start }}
    </li>
    <li>
      end: {{ props.workingTime.end }}
    </li>
    <li>
      user_id: {{ props.workingTime.user_id }}
    </li>
  </ul>
</template>
