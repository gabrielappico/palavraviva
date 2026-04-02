import { useState, useEffect } from "react";
import { DashboardLayout } from "@/components/dashboard/DashboardLayout";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Heart, Loader2, Save } from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import { toast } from "sonner";
import { MoodCheckIn } from "@/components/mood/MoodCheckIn";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog";

const Oracao = () => {
  const [feeling, setFeeling] = useState("");
  const [prayer, setPrayer] = useState("");
  const [loading, setLoading] = useState(false);
  const [showMoodCheck, setShowMoodCheck] = useState(false);
  const [hasCheckedMood, setHasCheckedMood] = useState(false);

  useEffect(() => {
    checkMoodToday();
  }, []);

  const checkMoodToday = async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const { data } = await supabase
        .from("mood_check_ins")
        .select("*")
        .eq("user_id", user.id)
        .gte("created_at", today.toISOString())
        .single();

      setHasCheckedMood(!!data);
    } catch (error) {
      // Silently fail - user hasn't checked mood today
      setHasCheckedMood(false);
    }
  };

  const handleGenerate = async () => {
    if (!hasCheckedMood) {
      setShowMoodCheck(true);
      return;
    }

    if (!feeling.trim()) {
      toast.error("Por favor, descreva como você está se sentindo");
      return;
    }

    await generatePrayer();
  };

  const generatePrayer = async () => {
    setLoading(true);
    try {
      const { data, error } = await supabase.functions.invoke("generate-prayer", {
        body: { feeling },
      });

      if (error) throw error;

      setPrayer(data.prayer);
      toast.success("Oração gerada com sucesso!");
    } catch (error) {
      console.error("Error generating prayer:", error);
      toast.error("Erro ao gerar oração");
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async () => {
    if (!prayer) return;

    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        toast.error("Você precisa estar logado");
        return;
      }

      const { error } = await supabase.from("prayers").insert({
        user_id: user.id,
        feeling,
        prayer_text: prayer,
      });

      if (error) throw error;

      toast.success("Oração salva no Diário Espiritual!");
    } catch (error) {
      console.error("Error saving prayer:", error);
      toast.error("Erro ao salvar oração");
    }
  };

  return (
    <DashboardLayout>
      <Dialog open={showMoodCheck} onOpenChange={setShowMoodCheck}>
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle>Como você está se sentindo?</DialogTitle>
            <DialogDescription>
              Compartilhe seu humor antes de gerar uma oração personalizada
            </DialogDescription>
          </DialogHeader>
          <MoodCheckIn
            context="antes_oracao"
            onComplete={() => {
              setShowMoodCheck(false);
              setHasCheckedMood(true);
              if (feeling.trim()) {
                generatePrayer();
              }
            }}
          />
        </DialogContent>
      </Dialog>

      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold mb-2">Oração Personalizada</h1>
          <p className="text-muted-foreground">
            Expresse seus sentimentos e receba uma oração personalizada
          </p>
        </div>

        {/* Input Card */}
        <Card>
          <CardHeader>
            <CardTitle>Como você está se sentindo?</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <Textarea
              placeholder="Descreva seus sentimentos, preocupações ou motivos de gratidão..."
              value={feeling}
              onChange={(e) => setFeeling(e.target.value)}
              rows={4}
            />
            <Button onClick={handleGenerate} disabled={loading} className="w-full">
              {loading ? (
                <>
                  <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                  Gerando Oração...
                </>
              ) : (
                <>
                  <Heart className="mr-2 h-5 w-5" />
                  Gerar Oração
                </>
              )}
            </Button>
          </CardContent>
        </Card>

        {/* Prayer Display */}
        {prayer && (
          <Card className="bg-gradient-to-br from-primary/5 to-accent/5 border-primary/20">
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle>Sua Oração Personalizada</CardTitle>
                <Button variant="ghost" size="icon" onClick={handleSave}>
                  <Save className="h-5 w-5" />
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              <div className="p-6 bg-background/50 rounded-lg">
                <p className="text-lg leading-relaxed whitespace-pre-wrap">{prayer}</p>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Info */}
        <Card>
          <CardContent className="pt-6">
            <p className="text-sm text-muted-foreground mb-2">
              <strong>Reflexão:</strong> A oração é uma conversa íntima com Deus.
            </p>
            <p className="text-sm text-muted-foreground italic">
              "Não andeis ansiosos de coisa alguma; em tudo, porém, sejam conhecidas, diante de Deus,
              as vossas petições, pela oração e pela súplica, com ações de graças." - Filipenses 4:6
            </p>
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  );
};

export default Oracao;
