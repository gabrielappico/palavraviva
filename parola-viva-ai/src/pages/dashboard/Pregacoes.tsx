import { useState } from "react";
import { DashboardLayout } from "@/components/dashboard/DashboardLayout";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Mic, Loader2, Download } from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import { toast } from "sonner";

const Pregacoes = () => {
  const [theme, setTheme] = useState("");
  const [baseText, setBaseText] = useState("");
  const [targetAudience, setTargetAudience] = useState("");
  const [sermon, setSermon] = useState<any>(null);
  const [loading, setLoading] = useState(false);

  const handleGenerate = async () => {
    if (!theme.trim()) {
      toast.error("Por favor, informe o tema da mensagem");
      return;
    }

    setLoading(true);
    try {
      const { data, error } = await supabase.functions.invoke("generate-sermon", {
        body: { theme, baseText, targetAudience },
      });

      if (error) throw error;

      setSermon(data.sermon);
      toast.success("Mensagem gerada com sucesso!");
    } catch (error) {
      console.error("Error generating sermon:", error);
      toast.error("Erro ao gerar mensagem");
    } finally {
      setLoading(false);
    }
  };

  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold mb-2">Auxílio para Pregações</h1>
          <p className="text-muted-foreground">
            Gere sermões e mensagens completas com IA
          </p>
        </div>

        {/* Input Form */}
        <Card>
          <CardHeader>
            <CardTitle>Informações da Mensagem</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="theme">Tema *</Label>
              <Input
                id="theme"
                placeholder="Ex: O amor de Deus"
                value={theme}
                onChange={(e) => setTheme(e.target.value)}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="baseText">Texto Base (opcional)</Label>
              <Input
                id="baseText"
                placeholder="Ex: João 3:16"
                value={baseText}
                onChange={(e) => setBaseText(e.target.value)}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="audience">Público-Alvo (opcional)</Label>
              <Input
                id="audience"
                placeholder="Ex: Jovens, casais, congregação geral"
                value={targetAudience}
                onChange={(e) => setTargetAudience(e.target.value)}
              />
            </div>

            <Button onClick={handleGenerate} disabled={loading} className="w-full">
              {loading ? (
                <>
                  <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                  Gerando Mensagem...
                </>
              ) : (
                <>
                  <Mic className="mr-2 h-5 w-5" />
                  Gerar Mensagem
                </>
              )}
            </Button>
          </CardContent>
        </Card>

        {/* Sermon Display */}
        {sermon && (
          <Card className="bg-gradient-to-br from-primary/5 to-accent/5 border-primary/20">
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle>Mensagem Gerada</CardTitle>
                <Button variant="ghost" size="icon">
                  <Download className="h-5 w-5" />
                </Button>
              </div>
            </CardHeader>
            <CardContent className="space-y-6">
              {sermon.introduction && (
                <div>
                  <h3 className="font-semibold text-lg mb-2">Introdução</h3>
                  <p className="text-muted-foreground">{sermon.introduction}</p>
                </div>
              )}

              {sermon.context && (
                <div>
                  <h3 className="font-semibold text-lg mb-2">Contexto Bíblico</h3>
                  <p className="text-muted-foreground">{sermon.context}</p>
                </div>
              )}

              {sermon.mainPoints && sermon.mainPoints.length > 0 && (
                <div>
                  <h3 className="font-semibold text-lg mb-2">Pontos Principais</h3>
                  <ol className="list-decimal list-inside space-y-2">
                    {sermon.mainPoints.map((point: string, idx: number) => (
                      <li key={idx} className="text-muted-foreground">{point}</li>
                    ))}
                  </ol>
                </div>
              )}

              {sermon.application && (
                <div>
                  <h3 className="font-semibold text-lg mb-2">Aplicação Prática</h3>
                  <p className="text-muted-foreground">{sermon.application}</p>
                </div>
              )}

              {sermon.closingPrayer && (
                <div>
                  <h3 className="font-semibold text-lg mb-2">Oração Final</h3>
                  <p className="text-muted-foreground italic">{sermon.closingPrayer}</p>
                </div>
              )}
            </CardContent>
          </Card>
        )}
      </div>
    </DashboardLayout>
  );
};

export default Pregacoes;
