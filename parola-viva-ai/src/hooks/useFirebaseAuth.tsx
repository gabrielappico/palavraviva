import { useEffect, useState } from "react";
import {
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut as firebaseSignOut,
  onAuthStateChanged,
  User as FirebaseUser,
  GoogleAuthProvider,
  signInWithPopup,
  updateProfile,
} from "firebase/auth";
import { auth } from "@/config/firebase";
import { supabase } from "@/integrations/supabase/client";

export const useFirebaseAuth = () => {
  const [firebaseUser, setFirebaseUser] = useState<FirebaseUser | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      setFirebaseUser(user);
      
      if (user) {
        // Sync user profile with Supabase (deferred to avoid blocking)
        setTimeout(() => {
          syncUserProfile(user);
        }, 0);
      }
      
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const syncUserProfile = async (user: FirebaseUser) => {
    try {
      const { data: existingProfile } = await supabase
        .from("profiles")
        .select("*")
        .eq("id", user.uid)
        .single();

      if (!existingProfile) {
        // Create profile if it doesn't exist
        await supabase.from("profiles").insert({
          id: user.uid,
          email: user.email || "",
          full_name: user.displayName || "",
          avatar_url: user.photoURL || null,
        });
      } else {
        // Update profile if it exists
        await supabase
          .from("profiles")
          .update({
            email: user.email || "",
            full_name: user.displayName || existingProfile.full_name,
            avatar_url: user.photoURL || existingProfile.avatar_url,
          })
          .eq("id", user.uid);
      }
    } catch (error) {
      console.error("Error syncing user profile:", error);
    }
  };

  const signIn = async (email: string, password: string) => {
    try {
      const result = await signInWithEmailAndPassword(auth, email, password);
      return { data: result, error: null };
    } catch (error: any) {
      return { data: null, error };
    }
  };

  const signUp = async (email: string, password: string, fullName: string) => {
    try {
      const result = await createUserWithEmailAndPassword(auth, email, password);
      
      // Update profile with full name
      if (result.user) {
        await updateProfile(result.user, {
          displayName: fullName,
        });
      }
      
      return { data: result, error: null };
    } catch (error: any) {
      return { data: null, error };
    }
  };

  const signInWithGoogle = async () => {
    try {
      const provider = new GoogleAuthProvider();
      const result = await signInWithPopup(auth, provider);
      return { data: result, error: null };
    } catch (error: any) {
      return { data: null, error };
    }
  };

  const signOut = async () => {
    try {
      await firebaseSignOut(auth);
      return { error: null };
    } catch (error: any) {
      return { error };
    }
  };

  return {
    user: firebaseUser,
    loading,
    signIn,
    signUp,
    signInWithGoogle,
    signOut,
  };
};
