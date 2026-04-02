export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "13.0.5"
  }
  public: {
    Tables: {
      conversations: {
        Row: {
          created_at: string | null
          id: string
          title: string | null
          updated_at: string | null
          user_id: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          title?: string | null
          updated_at?: string | null
          user_id: string
        }
        Update: {
          created_at?: string | null
          id?: string
          title?: string | null
          updated_at?: string | null
          user_id?: string
        }
        Relationships: []
      }
      dynamics: {
        Row: {
          created_at: string | null
          dynamic_content: Json
          group_type: string
          id: string
          is_favorite: boolean | null
          theme: string
          user_id: string
        }
        Insert: {
          created_at?: string | null
          dynamic_content: Json
          group_type: string
          id?: string
          is_favorite?: boolean | null
          theme: string
          user_id: string
        }
        Update: {
          created_at?: string | null
          dynamic_content?: Json
          group_type?: string
          id?: string
          is_favorite?: boolean | null
          theme?: string
          user_id?: string
        }
        Relationships: []
      }
      favorite_verses: {
        Row: {
          created_at: string | null
          id: string
          note: string | null
          user_id: string
          verse_reference: string
          verse_text: string
          version: string | null
        }
        Insert: {
          created_at?: string | null
          id?: string
          note?: string | null
          user_id: string
          verse_reference: string
          verse_text: string
          version?: string | null
        }
        Update: {
          created_at?: string | null
          id?: string
          note?: string | null
          user_id?: string
          verse_reference?: string
          verse_text?: string
          version?: string | null
        }
        Relationships: []
      }
      messages: {
        Row: {
          content: string
          conversation_id: string
          created_at: string | null
          id: string
          role: string
        }
        Insert: {
          content: string
          conversation_id: string
          created_at?: string | null
          id?: string
          role: string
        }
        Update: {
          content?: string
          conversation_id?: string
          created_at?: string | null
          id?: string
          role?: string
        }
        Relationships: [
          {
            foreignKeyName: "messages_conversation_id_fkey"
            columns: ["conversation_id"]
            isOneToOne: false
            referencedRelation: "conversations"
            referencedColumns: ["id"]
          },
        ]
      }
      mood_check_ins: {
        Row: {
          context: string | null
          created_at: string | null
          id: string
          intensity: number
          mood: Database["public"]["Enums"]["mood_type"]
          notes: string | null
          user_id: string
        }
        Insert: {
          context?: string | null
          created_at?: string | null
          id?: string
          intensity: number
          mood: Database["public"]["Enums"]["mood_type"]
          notes?: string | null
          user_id: string
        }
        Update: {
          context?: string | null
          created_at?: string | null
          id?: string
          intensity?: number
          mood?: Database["public"]["Enums"]["mood_type"]
          notes?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "mood_check_ins_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      prayers: {
        Row: {
          created_at: string | null
          feeling: string | null
          id: string
          prayer_text: string
          user_id: string
        }
        Insert: {
          created_at?: string | null
          feeling?: string | null
          id?: string
          prayer_text: string
          user_id: string
        }
        Update: {
          created_at?: string | null
          feeling?: string | null
          id?: string
          prayer_text?: string
          user_id?: string
        }
        Relationships: []
      }
      profiles: {
        Row: {
          auth0_user_id: string | null
          avatar_url: string | null
          created_at: string | null
          email: string
          full_name: string | null
          id: string
          updated_at: string | null
        }
        Insert: {
          auth0_user_id?: string | null
          avatar_url?: string | null
          created_at?: string | null
          email: string
          full_name?: string | null
          id: string
          updated_at?: string | null
        }
        Update: {
          auth0_user_id?: string | null
          avatar_url?: string | null
          created_at?: string | null
          email?: string
          full_name?: string | null
          id?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      quiz_questions: {
        Row: {
          category: string
          correct_answer: string
          created_at: string | null
          difficulty: string
          explanation: string | null
          id: string
          options: Json
          question: string
        }
        Insert: {
          category: string
          correct_answer: string
          created_at?: string | null
          difficulty: string
          explanation?: string | null
          id?: string
          options: Json
          question: string
        }
        Update: {
          category?: string
          correct_answer?: string
          created_at?: string | null
          difficulty?: string
          explanation?: string | null
          id?: string
          options?: Json
          question?: string
        }
        Relationships: []
      }
      quiz_results: {
        Row: {
          category: string
          created_at: string | null
          difficulty: string
          id: string
          score: number
          total: number
          user_id: string
        }
        Insert: {
          category: string
          created_at?: string | null
          difficulty: string
          id?: string
          score: number
          total: number
          user_id: string
        }
        Update: {
          category?: string
          created_at?: string | null
          difficulty?: string
          id?: string
          score?: number
          total?: number
          user_id?: string
        }
        Relationships: []
      }
      sermons: {
        Row: {
          base_text: string | null
          created_at: string | null
          id: string
          sermon_content: Json
          target_audience: string | null
          theme: string
          user_id: string
        }
        Insert: {
          base_text?: string | null
          created_at?: string | null
          id?: string
          sermon_content: Json
          target_audience?: string | null
          theme: string
          user_id: string
        }
        Update: {
          base_text?: string | null
          created_at?: string | null
          id?: string
          sermon_content?: Json
          target_audience?: string | null
          theme?: string
          user_id?: string
        }
        Relationships: []
      }
      user_emotional_profile: {
        Row: {
          created_at: string | null
          current_mood: Database["public"]["Enums"]["mood_type"] | null
          engagement_time:
            | Database["public"]["Enums"]["time_of_day_type"]
            | null
          favorite_verse_themes: Json | null
          frequent_struggles: Json | null
          id: string
          interaction_frequency: string | null
          last_mood_check: string | null
          mood_intensity: number | null
          preferred_prayer_style:
            | Database["public"]["Enums"]["prayer_style_type"]
            | null
          preferred_topics: Json | null
          spiritual_stage:
            | Database["public"]["Enums"]["spiritual_stage_type"]
            | null
          updated_at: string | null
          user_id: string
        }
        Insert: {
          created_at?: string | null
          current_mood?: Database["public"]["Enums"]["mood_type"] | null
          engagement_time?:
            | Database["public"]["Enums"]["time_of_day_type"]
            | null
          favorite_verse_themes?: Json | null
          frequent_struggles?: Json | null
          id?: string
          interaction_frequency?: string | null
          last_mood_check?: string | null
          mood_intensity?: number | null
          preferred_prayer_style?:
            | Database["public"]["Enums"]["prayer_style_type"]
            | null
          preferred_topics?: Json | null
          spiritual_stage?:
            | Database["public"]["Enums"]["spiritual_stage_type"]
            | null
          updated_at?: string | null
          user_id: string
        }
        Update: {
          created_at?: string | null
          current_mood?: Database["public"]["Enums"]["mood_type"] | null
          engagement_time?:
            | Database["public"]["Enums"]["time_of_day_type"]
            | null
          favorite_verse_themes?: Json | null
          frequent_struggles?: Json | null
          id?: string
          interaction_frequency?: string | null
          last_mood_check?: string | null
          mood_intensity?: number | null
          preferred_prayer_style?:
            | Database["public"]["Enums"]["prayer_style_type"]
            | null
          preferred_topics?: Json | null
          spiritual_stage?:
            | Database["public"]["Enums"]["spiritual_stage_type"]
            | null
          updated_at?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_emotional_profile_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      mood_type:
        | "grato"
        | "triste"
        | "ansioso"
        | "tranquilo"
        | "confuso"
        | "cansado"
        | "alegre"
        | "esperancoso"
      prayer_style_type: "formal" | "conversacional" | "contemplativa"
      spiritual_stage_type: "iniciante" | "crescendo" | "maduro" | "em_duvida"
      time_of_day_type: "manha" | "tarde" | "noite" | "madrugada"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      mood_type: [
        "grato",
        "triste",
        "ansioso",
        "tranquilo",
        "confuso",
        "cansado",
        "alegre",
        "esperancoso",
      ],
      prayer_style_type: ["formal", "conversacional", "contemplativa"],
      spiritual_stage_type: ["iniciante", "crescendo", "maduro", "em_duvida"],
      time_of_day_type: ["manha", "tarde", "noite", "madrugada"],
    },
  },
} as const
