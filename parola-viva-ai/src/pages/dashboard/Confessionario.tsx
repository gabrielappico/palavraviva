import { useState } from "react";
import { DashboardLayout } from "@/components/dashboard/DashboardLayout";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Heart, Lock, Loader2, Shield } from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import { toast } from "sonner";

const Confessionario = () => {
  const [confession, setConfession] = useState("");
  const [counsel, setCounsel] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async () => {
    if (!confession.trim()) {
      toast.error("Por favor, compartilhe o que está em seu coração");
      return;
    }

    if (confession.length > 5000) {
      toast.error("Texto muito longo. Por favor, seja mais conciso.");
      return;
    }

    setLoading(true);
    try {
      const { data, error } = await supabase.functions.invoke("confession-counsel", {
        body: { confession },
      });

      if (error) throw error;

      setCounsel(data.counsel);
      toast.success("Orientação recebida com amor e compaixão");
    } catch (error) {
      console.error("Error getting counsel:", error);
      toast.error("Erro ao processar confissão");
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    setConfession("");
    setCounsel("");
  };

  return (
    <DashboardLayout>
      <div className="space-y-6 max-w-4xl mx-auto">
        <div>
          <h1 className="text-3xl font-bold mb-2">Confessionário Espiritual</h1>
          <p className="text-muted-foreground">
            Um espaço seguro para compartilhar, refletir e receber orientação espiritual
          </p>
        </div>

        {/* Privacy Notice */}
        <Alert className="border-primary/20 bg-primary/5">
          <Shield className="h-5 w-5 text-primary" />
          <AlertDescription className="ml-2">
            <strong>Sua privacidade é sagrada.</strong> Suas confissões são processadas com
            total confidencialidade e não são armazenadas permanentemente. Este é um espaço
            seguro para buscar orientação espiritual.
          </AlertDescription>
        </Alert>

        {/* Confession Input */}
        {!counsel && (
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Heart className="h-5 w-5 text-primary" />
                Compartilhe o que está em seu coração
              </CardTitle>
              <CardDescription>
                Seja sincero e aberto. Deus conhece seu coração e está pronto para perdoar.
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <Textarea
                placeholder="Compartilhe suas lutas, pecados ou preocupações espirituais. Não há julgamento aqui, apenas compaixão e orientação..."
                value={confession}
                onChange={(e) => setConfession(e.target.value)}
                rows={8}
                className="resize-none"
                maxLength={5000}
              />
              <div className="flex items-center justify-between">
                <p className="text-xs text-muted-foreground flex items-center gap-1">
                  <Lock className="h-3 w-3" />
                  Confidencial • {confession.length}/5000 caracteres
                </p>
                <Button onClick={handleSubmit} disabled={loading || !confession.trim()}>
                  {loading ? (
                    <>
                      <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                      Processando...
                    </>
                  ) : (
                    <>
                      <Heart className="mr-2 h-5 w-5" />
                      Receber Orientação
                    </>
                  )}
                </Button>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Counsel Display */}
        {counsel && (
          <Card className="bg-gradient-to-br from-primary/5 to-accent/5 border-primary/20 animate-fade-in">
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle>Orientação Espiritual</CardTitle>
                <Button variant="ghost" size="sm" onClick={handleReset}>
                  Nova Confissão
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              <div className="prose prose-sm max-w-none">
                <div className="whitespace-pre-wrap leading-relaxed">
                  {counsel}
                </div>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Guidance */}
        <Card>
          <CardContent className="pt-6 space-y-4">
            <div>
              <h3 className="font-semibold mb-2">Como usar o Confessionário:</h3>
              <ul className="text-sm text-muted-foreground space-y-1 list-disc list-inside">
                <li>Seja honesto e específico sobre suas lutas espirituais</li>
                <li>Não há pecado grande demais para o perdão de Deus</li>
                <li>A orientação é baseada na Bíblia Sagrada</li>
                <li>Use este espaço sempre que precisar de direção espiritual</li>
                <li>Combine com oração pessoal e leitura da Palavra</li>
              </ul>
            </div>
            <div className="p-4 bg-muted/50 rounded-lg">
              <p className="text-sm italic">
                "Portanto, agora já não há condenação para os que estão em Cristo Jesus."
              </p>
              <p className="text-xs text-muted-foreground mt-1">Romanos 8:1</p>
            </div>
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  );
};

export default Confessionario;