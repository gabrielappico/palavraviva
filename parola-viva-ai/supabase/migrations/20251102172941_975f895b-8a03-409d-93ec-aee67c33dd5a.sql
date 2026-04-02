-- Create profiles table
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create conversations table for chat history
CREATE TABLE IF NOT EXISTS public.conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT DEFAULT 'Nova Conversa',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create messages table
CREATE TABLE IF NOT EXISTS public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create favorite_verses table
CREATE TABLE IF NOT EXISTS public.favorite_verses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  verse_reference TEXT NOT NULL,
  verse_text TEXT NOT NULL,
  version TEXT DEFAULT 'NVI',
  note TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create prayers table
CREATE TABLE IF NOT EXISTS public.prayers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  feeling TEXT,
  prayer_text TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create sermons table for pregações
CREATE TABLE IF NOT EXISTS public.sermons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  theme TEXT NOT NULL,
  base_text TEXT,
  target_audience TEXT,
  sermon_content JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create quiz_questions table
CREATE TABLE IF NOT EXISTS public.quiz_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category TEXT NOT NULL CHECK (category IN ('antigo_testamento', 'novo_testamento', 'personagens', 'doutrina')),
  difficulty TEXT NOT NULL CHECK (difficulty IN ('facil', 'medio', 'dificil')),
  question TEXT NOT NULL,
  options JSONB NOT NULL,
  correct_answer TEXT NOT NULL,
  explanation TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create quiz_results table
CREATE TABLE IF NOT EXISTS public.quiz_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category TEXT NOT NULL,
  difficulty TEXT NOT NULL,
  score INTEGER NOT NULL,
  total INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create dynamics table for dinâmicas cristãs
CREATE TABLE IF NOT EXISTS public.dynamics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  group_type TEXT NOT NULL,
  theme TEXT NOT NULL,
  dynamic_content JSONB NOT NULL,
  is_favorite BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorite_verses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prayers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sermons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dynamics ENABLE ROW LEVEL SECURITY;

-- RLS Policies for profiles
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- RLS Policies for conversations
CREATE POLICY "Users can manage own conversations"
  ON public.conversations FOR ALL
  USING (auth.uid() = user_id);

-- RLS Policies for messages
CREATE POLICY "Users can view own messages"
  ON public.messages FOR SELECT
  USING (
    conversation_id IN (
      SELECT id FROM public.conversations WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own messages"
  ON public.messages FOR INSERT
  WITH CHECK (
    conversation_id IN (
      SELECT id FROM public.conversations WHERE user_id = auth.uid()
    )
  );

-- RLS Policies for favorite_verses
CREATE POLICY "Users can manage own favorite verses"
  ON public.favorite_verses FOR ALL
  USING (auth.uid() = user_id);

-- RLS Policies for prayers
CREATE POLICY "Users can manage own prayers"
  ON public.prayers FOR ALL
  USING (auth.uid() = user_id);

-- RLS Policies for sermons
CREATE POLICY "Users can manage own sermons"
  ON public.sermons FOR ALL
  USING (auth.uid() = user_id);

-- RLS Policies for quiz_questions (read-only for all authenticated users)
CREATE POLICY "Authenticated users can view quiz questions"
  ON public.quiz_questions FOR SELECT
  TO authenticated
  USING (true);

-- RLS Policies for quiz_results
CREATE POLICY "Users can manage own quiz results"
  ON public.quiz_results FOR ALL
  USING (auth.uid() = user_id);

-- RLS Policies for dynamics
CREATE POLICY "Users can manage own dynamics"
  ON public.dynamics FOR ALL
  USING (auth.uid() = user_id);

-- Function to automatically create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to call the function on user creation
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_conversations_updated_at
  BEFORE UPDATE ON public.conversations
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Seed some quiz questions
INSERT INTO public.quiz_questions (category, difficulty, question, options, correct_answer, explanation) VALUES
  ('antigo_testamento', 'facil', 'Quem foi o primeiro homem criado por Deus?', '["Adão", "Noé", "Abraão", "Moisés"]', 'Adão', 'Gênesis 2:7 relata a criação de Adão, o primeiro homem.'),
  ('antigo_testamento', 'facil', 'Quantos dias Deus levou para criar o mundo?', '["5 dias", "6 dias", "7 dias", "8 dias"]', '6 dias', 'Gênesis 1 descreve a criação em 6 dias, e Deus descansou no 7º dia.'),
  ('novo_testamento', 'facil', 'Onde Jesus nasceu?', '["Belém", "Nazaré", "Jerusalém", "Cafarnaum"]', 'Belém', 'Lucas 2:4-7 relata que Jesus nasceu em Belém da Judeia.'),
  ('novo_testamento', 'medio', 'Quantos apóstolos Jesus escolheu?', '["10", "11", "12", "13"]', '12', 'Jesus escolheu 12 apóstolos, conforme registrado em Mateus 10:1-4.'),
  ('personagens', 'medio', 'Quem foi engolido por um grande peixe?', '["Jonas", "Pedro", "Paulo", "João"]', 'Jonas', 'O livro de Jonas relata como ele foi engolido por um grande peixe.'),
  ('personagens', 'dificil', 'Quem foi o profeta que subiu ao céu em um redemoinho?', '["Elias", "Eliseu", "Isaías", "Jeremias"]', 'Elias', '2 Reis 2:11 descreve como Elias foi levado ao céu em um redemoinho.'),
  ('doutrina', 'medio', 'Qual é o primeiro mandamento?', '["Não matarás", "Amar a Deus sobre todas as coisas", "Não roubarás", "Honrar pai e mãe"]', 'Amar a Deus sobre todas as coisas', 'Jesus afirmou em Mateus 22:37-38 que o primeiro mandamento é amar a Deus.'),
  ('doutrina', 'dificil', 'Quantos livros tem a Bíblia?', '["66", "73", "77", "80"]', '66', 'A Bíblia protestante contém 66 livros: 39 no Antigo Testamento e 27 no Novo Testamento.')
ON CONFLICT DO NOTHING;