import { ReactNode } from "react";
import { app } from "@/config/firebase";

interface FirebaseProviderProps {
  children: ReactNode;
}

export const FirebaseProvider = ({ children }: FirebaseProviderProps) => {
  // Firebase app is initialized in config
  // This provider ensures Firebase is initialized before the app renders
  if (!app) {
    throw new Error("Firebase failed to initialize");
  }

  return <>{children}</>;
};
