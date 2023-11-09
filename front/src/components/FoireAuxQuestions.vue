<template>
  <div class="min-h-screen flex flex-col justify-center bg-gray-100 p-4">
    <router-link to="/" class="flex">
      <img alt="return" src="../assets/return_icon.svg" class="w-5 h-5 mb-10">
    </router-link>
    <h1 class="text-4xl font-semibold mb-10 self-center">
      Frequently Asked Questions
    </h1>
    <div class="w-full max-w-2xl self-center">
      <div v-for="item in questions" :key="item.question" class="question-item mb-6 bg-white p-4 rounded-lg shadow-md">
        <div class="question cursor-pointer text-lg hover:text-blue-600" @click="toggle(item)">
          {{ item.question }}
        </div>
        <div v-if="item.show" class="answer mt-2 text-gray-700">
          {{ item.answer }}
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { ref } from 'vue'

export default {
  setup () {
    const questions = ref([
      {
        question: 'Do we need to clock in during lunch break?',
        answer: 'Indeed, it is imperative to clock in during the lunch break.',
        show: false
      },
      {
        question: 'Do we need to clock in during commutes within our working hours?',
        answer: 'No, commutes made during your working hours are counted as working hours.',
        show: false
      },
      {
        question: 'I don’t have a computer, how do I clock in?',
        answer: 'Our application is available online. Thus, you can easily access it from a mobile device.',
        show: false
      },
      {
        question: 'Who can access my professional data?',
        answer:
          'Only the administrators and your supervisors have the privilege to access your professional information.',
        show: false
      },
      {
        question: 'How do I clock in using the application?',
        answer:
          'You simply log in using the credentials we provide to you via email. After this step, click on the "Clock-In" button when you start your work, and press it again to end your work period.',
        show: false
      },
      {
        question: 'Are overtime hours accounted for?',
        answer:
          'Yes, overtime hours are duly accounted for. They are clearly displayed in the app and are compensated at twice the standard hourly rate.',
        show: false
      },
      {
        question: 'Are daytime and nighttime working hours differentiated?',
        answer:
          'Indeed, hours worked during the day and night are treated differently. Moreover, the hourly rate is adjusted based on these periods. Please note that hours worked between 9:00 pm and 6:00 am are compensated at a rate 1.5 times higher than those worked during the day.',
        show: false
      },
      {
        question: 'I am visually impaired, how do I use the application?',
        answer:
          'We have considered the needs of all our users. Thus, our application has been optimized to be accessible to visually impaired individuals.',
        show: false
      },
      {
        question: 'Can I manage my leave and sick days directly on the app?',
        answer: "For now, the app doesn't allow that, but the feature should be released in 2024.",
        show: false
      },
      {
        question: 'I forgot to check in on the last day of the month, what should I do?',
        answer:
          'You can create, modify, and delete your working hours whenever you can. To avoid this, you can actually schedule your worked hours in advance.',
        show: false
      }
    ])

    const toggle = (item: { show: boolean }) => {
      item.show = !item.show
    }

    return {
      questions,
      toggle
    }
  }
}
</script>

<style></style>
