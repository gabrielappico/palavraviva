import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";

const firebaseConfig = {
  apiKey: "AIzaSyAMLirxi8acO-ZJIIkm39uJO_HNuKJWDWE",
  authDomain: "loginappi-35419.firebaseapp.com",
  projectId: "loginappi-35419",
  storageBucket: "loginappi-35419.firebasestorage.app",
  messagingSenderId: "141492883693",
  appId: "1:141492883693:web:8e417094041d221471bce4",
};

export const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
