<template>
    <div>
      <button @click="showModal = true">Afficher la pop-up</button>
  
      <div v-if="showModal" class="modal">
        <div class="modal-content">
          <span class="close" @click="showModal = false">&times;</span>
          <p>Contenu de la pop-up ici</p>
        </div>
      </div>
    </div>
  </template>
  
  <script setup lang="ts">
  import { ref } from "vue";
  
  const showModal = ref(false);
  </script>
  
  <style>
  /* Style pour la modal */
  .modal {
    display: block;
    position: fixed;
    z-index: 1;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    overflow: auto;
    background-color: rgba(0, 0, 0, 0.5);
  }
  
  .modal-content {
    background-color: #fefefe;
    margin: 15% auto;
    padding: 20px;
    border: 1px solid #888;
    width: 80%;
  }
  
  .close {
    color: #aaa;
    float: right;
    font-size: 28px;
    font-weight: bold;
  }
  
  .close:hover,
  .close:focus {
    color: black;
    text-decoration: none;
    cursor: pointer;
  }
  </style>
  