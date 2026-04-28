importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({  
  apiKey: "AIzaSyD10DkYE6_oIlownkgMq-qU8tYG3WUbWgw",
  authDomain: "jamochi-app.firebaseapp.com",
  projectId: "jamochi-app",
  storageBucket: "jamochi-app.appspot.com",
  messagingSenderId: "506767058306", 
  appId: "1:506767058306:web:58cdb55dc1912f04ed9b9b" 
});

const messaging = firebase.messaging();