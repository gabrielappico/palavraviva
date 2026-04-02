-- Criar enum para moods
CREATE TYPE public.mood_type AS ENUM ('grato', 'triste', 'ansioso', 'tranquilo', 'confuso', 'cansado', 'alegre', 'esperancoso');

-- Criar enum para estágio espiritual
CREATE TYPE public.spiritual_stage_type AS ENUM ('iniciante', 'crescendo', 'maduro', 'em_duvida');

-- Criar enum para estilo de oração
CREATE TYPE public.prayer_style_type AS ENUM ('formal', 'conversacional', 'contemplativa');

-- Criar enum para período do dia
CREATE TYPE public.time_of_day_type AS ENUM ('manha', 'tarde', 'noite', 'madrugada');

-- Criar tabela de perfil emocional do usuário
CREATE TABLE public.user_emotional_profile (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE UNIQUE,
  
  -- Estado emocional atual
  current_mood mood_type,
  mood_intensity INTEGER CHECK (mood_intensity BETWEEN 1 AND 5),
  
  -- Preferências identificadas
  preferred_topics JSONB DEFAULT '[]'::jsonb,
  frequent_struggles JSONB DEFAULT '[]'::jsonb,
  favorite_verse_themes JSONB DEFAULT '[]'::jsonb,
  
  -- Padrões de uso
  preferred_prayer_style prayer_style_type DEFAULT 'conversacional',
  engagement_time time_of_day_type,
  interaction_frequency TEXT DEFAULT 'ocasional',
  
  -- Jornada espiritual
  spiritual_stage spiritual_stage_type DEFAULT 'iniciante',
  last_mood_check TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Criar tabela de check-ins emocionais
CREATE TABLE public.mood_check_ins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  
  mood mood_type NOT NULL,
  intensity INTEGER NOT NULL CHECK (intensity BETWEEN 1 AND 5),
  context TEXT,
  notes TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Habilitar RLS
ALTER TABLE public.user_emotional_profile ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mood_check_ins ENABLE ROW LEVEL SECURITY;

-- Políticas RLS para user_emotional_profile
CREATE POLICY "Usuários gerenciam próprio perfil emocional"
  ON public.user_emotional_profile FOR ALL
  USING (auth.uid() = user_id);

-- Políticas RLS para mood_check_ins
CREATE POLICY "Usuários gerenciam próprios check-ins"
  ON public.mood_check_ins FOR ALL
  USING (auth.uid() = user_id);

-- Trigger para atualizar updated_at
CREATE TRIGGER update_user_emotional_profile_updated_at
  BEFORE UPDATE ON public.user_emotional_profile
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Função para criar perfil emocional automaticamente
CREATE OR REPLACE FUNCTION public.create_emotional_profile()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.user_emotional_profile (user_id)
  VALUES (NEW.id);
  RETURN NEW;
END;
$$;

-- Trigger para criar perfil emocional ao criar perfil
CREATE TRIGGER on_profile_created
  AFTER INSERT ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.create_emotional_profile();