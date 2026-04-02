import { useState } from "react";
import { DashboardLayout } from "@/components/dashboard/DashboardLayout";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Users, Loader2, Star } from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import { toast } from "sonner";

const Dinamicas = () => {
  const [groupType, setGroupType] = useState("");
  const [theme, setTheme] = useState("");
  const [dynamic, setDynamic] = useState<any>(null);
  const [loading, setLoading] = useState(false);

  const handleGenerate = async () => {
    if (!groupType.trim() || !theme.trim()) {
      toast.error("Por favor, preencha o tipo de grupo e o tema");
      return;
    }

    setLoading(true);
    try {
      const { data, error } = await supabase.functions.invoke("generate-dynamic", {
        body: { groupType, theme },
      });

      if (error) throw error;

      setDynamic(data.dynamic);
      toast.success("Dinâmica gerada com sucesso!");
    } catch (error) {
      console.error("Error generating dynamic:", error);
      toast.error("Erro ao gerar dinâmica");
    } finally {
      setLoading(false);
    }
  };

  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold mb-2">Dinâmicas Cristãs</h1>
          <p className="text-muted-foreground">
            Atividades espirituais para grupos e ministérios
          </p>
        </div>

        {/* Input Form */}
        <Card>
          <CardHeader>
            <CardTitle>Informações do Grupo</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="groupType">Tipo de Grupo *</Label>
              <Input
                id="groupType"
                placeholder="Ex: Jovens, casais, crianças, células"
                value={groupType}
                onChange={(e) => setGroupType(e.target.value)}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="theme">Tema *</Label>
              <Input
                id="theme"
                placeholder="Ex: Gratidão, comunhão, serviço"
                value={theme}
                onChange={(e) => setTheme(e.target.value)}
              />
            </div>

            <Button onClick={handleGenerate} disabled={loading} className="w-full">
              {loading ? (
                <>
                  <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                  Gerando Dinâmica...
                </>
              ) : (
                <>
                  <Users className="mr-2 h-5 w-5" />
                  Gerar Dinâmica
                </>
              )}
            </Button>
          </CardContent>
        </Card>

        {/* Dynamic Display */}
        {dynamic && (
          <Card className="bg-gradient-to-br from-primary/5 to-accent/5 border-primary/20">
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle>{dynamic.title}</CardTitle>
                <Button variant="ghost" size="icon">
                  <Star className="h-5 w-5" />
                </Button>
              </div>
            </CardHeader>
            <CardContent className="space-y-6">
              {dynamic.objective && (
                <div>
                  <h3 className="font-semibold text-lg mb-2">Objetivo</h3>
                  <p className="text-muted-foreground">{dynamic.objective}</p>
                </div>
              )}

              {dynamic.estimatedTime && (
                <div>
                  <h3 className="font-semibold text-lg mb-2">Tempo Estimado</h3>
                  <p className="text-muted-foreground">{dynamic.estimatedTime}</p>
                </div>
              )}

              {dynamic.materials && dynamic.materials.length > 0 && (
                <div>
                  <h3 className="font-semibold text-lg mb-2">Materiais Necessários</h3>
                  <ul className="list-disc list-inside space-y-1">
                    {dynamic.materials.map((material: string, idx: number) => (
                      <li key={idx} className="text-muted-foreground">{material}</li>
                    ))}
                  </ul>
                </div>
              )}

              {dynamic.steps && dynamic.steps.length > 0 && (
                <div>
                  <h3 className="font-semibold text-lg mb-2">Passo a Passo</h3>
                  <ol className="list-decimal list-inside space-y-2">
                    {dynamic.steps.map((step: string, idx: number) => (
                      <li key={idx} className="text-muted-foreground">{step}</li>
                    ))}
                  </ol>
                </div>
              )}

              {dynamic.biblicalLesson && (
                <div className="p-4 bg-background/50 rounded-lg">
                  <h3 className="font-semibold text-lg mb-2">Lição Bíblica</h3>
                  <p className="text-muted-foreground">{dynamic.biblicalLesson}</p>
                </div>
              )}

              {dynamic.facilitatorTips && (
                <div>
                  <h3 className="font-semibold text-lg mb-2">Dicas para o Facilitador</h3>
                  <p className="text-muted-foreground">{dynamic.facilitatorTips}</p>
                </div>
              )}
            </CardContent>
          </Card>
        )}
      </div>
    </DashboardLayout>
  );
};

export default Dinamicas;
