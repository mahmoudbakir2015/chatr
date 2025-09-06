importScripts('https://www.gstatic.com/firebasejs/10.4.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.4.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyDQWBy-5T12kkzmsw_cKPo-dntnLsYVcMs",
  authDomain: "chatr-dd82f.firebaseapp.com",
  projectId: "chatr-dd82f",
  storageBucket: "chatr-dd82f.firebasestorage.app",
  messagingSenderId: "590015773117",
  appId: "1:590015773117:web:d52bb5218822210b19bad4",
  measurementId: "G-GH0LE3PEY1"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/favicon.png'
  };
  self.registration.showNotification(notificationTitle, notificationOptions);
});
