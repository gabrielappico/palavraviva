import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Slider } from "@/components/ui/slider";
import { supabase } from "@/integrations/supabase/client";
import { useToast } from "@/hooks/use-toast";
import { Heart, Sparkles } from "lucide-react";

interface MoodOption {
  emoji: string;
  label: string;
  value: string;
  color: string;
}

const moods: MoodOption[] = [
  { emoji: "😊", label: "Grato", value: "grato", color: "text-yellow-500" },
  { emoji: "😔", label: "Triste", value: "triste", color: "text-blue-500" },
  { emoji: "😰", label: "Ansioso", value: "ansioso", color: "text-orange-500" },
  { emoji: "😌", label: "Tranquilo", value: "tranquilo", color: "text-green-500" },
  { emoji: "🤔", label: "Confuso", value: "confuso", color: "text-purple-500" },
  { emoji: "😴", label: "Cansado", value: "cansado", color: "text-gray-500" },
  { emoji: "😄", label: "Alegre", value: "alegre", color: "text-pink-500" },
  { emoji: "🙏", label: "Esperançoso", value: "esperancoso", color: "text-indigo-500" },
];

interface MoodCheckInProps {
  context?: string;
  onComplete?: () => void;
  compact?: boolean;
}

export const MoodCheckIn = ({ context, onComplete, compact = false }: MoodCheckInProps) => {
  const [selectedMood, setSelectedMood] = useState<string | null>(null);
  const [intensity, setIntensity] = useState([3]);
  const [notes, setNotes] = useState("");
  const [loading, setLoading] = useState(false);
  const { toast } = useToast();

  const handleSubmit = async () => {
    if (!selectedMood) {
      toast({
        title: "Selecione um humor",
        description: "Por favor, escolha como você está se sentindo.",
        variant: "destructive",
      });
      return;
    }

    setLoading(true);
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) throw new Error("Usuário não autenticado");

      // Salvar check-in
      const { error: checkInError } = await supabase.from("mood_check_ins").insert({
        user_id: user.id,
        mood: selectedMood as any,
        intensity: intensity[0],
        context: context || undefined,
        notes: notes || undefined,
      });

      if (checkInError) throw checkInError;

      // Atualizar perfil emocional
      const { error: profileError } = await supabase
        .from("user_emotional_profile")
        .upsert({
          user_id: user.id,
          current_mood: selectedMood as any,
          mood_intensity: intensity[0],
          last_mood_check: new Date().toISOString(),
        });

      if (profileError) throw profileError;

      toast({
        title: "Obrigado por compartilhar! 💙",
        description: "Vamos personalizar sua experiência com base em como você está se sentindo.",
      });

      if (onComplete) onComplete();
    } catch (error) {
      console.error("Error saving mood check-in:", error);
      toast({
        title: "Erro ao salvar",
        description: "Não foi possível registrar seu humor. Tente novamente.",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  if (compact) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Heart className="h-5 w-5 text-primary" />
            Como você está?
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-4 gap-2">
            {moods.map((mood) => (
              <Button
                key={mood.value}
                variant={selectedMood === mood.value ? "default" : "outline"}
                className="flex flex-col items-center gap-1 h-auto py-3"
                onClick={() => {
                  setSelectedMood(mood.value);
                  setTimeout(() => handleSubmit(), 100);
                }}
                disabled={loading}
              >
                <span className="text-2xl">{mood.emoji}</span>
                <span className="text-xs">{mood.label}</span>
              </Button>
            ))}
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className="border-2 border-primary/20">
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Sparkles className="h-6 w-6 text-primary" />
          Como você está se sentindo?
        </CardTitle>
        <CardDescription>
          Compartilhe seu estado emocional para recebermos mensagens e versículos personalizados
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-6">
        <div>
          <p className="text-sm font-medium mb-3">Selecione seu humor:</p>
          <div className="grid grid-cols-4 gap-3">
            {moods.map((mood) => (
              <Button
                key={mood.value}
                variant={selectedMood === mood.value ? "default" : "outline"}
                className="flex flex-col items-center gap-2 h-auto py-4"
                onClick={() => setSelectedMood(mood.value)}
              >
                <span className="text-3xl">{mood.emoji}</span>
                <span className="text-xs">{mood.label}</span>
              </Button>
            ))}
          </div>
        </div>

        {selectedMood && (
          <div className="space-y-4 animate-fade-in">
            <div>
              <p className="text-sm font-medium mb-2">
                Intensidade: {intensity[0]}/5
              </p>
              <Slider
                value={intensity}
                onValueChange={setIntensity}
                max={5}
                min={1}
                step={1}
                className="w-full"
              />
              <div className="flex justify-between text-xs text-muted-foreground mt-1">
                <span>Leve</span>
                <span>Intenso</span>
              </div>
            </div>

            <div>
              <p className="text-sm font-medium mb-2">
                O que está em seu coração? (opcional)
              </p>
              <Textarea
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                placeholder="Compartilhe seus pensamentos ou preocupações..."
                className="min-h-[100px]"
              />
            </div>

            <Button onClick={handleSubmit} disabled={loading} className="w-full">
              {loading ? "Salvando..." : "Compartilhar"}
            </Button>
          </div>
        )}
      </CardContent>
    </Card>
  );
};