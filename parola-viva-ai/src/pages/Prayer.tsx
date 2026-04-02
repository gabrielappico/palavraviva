import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Card } from "@/components/ui/card";
import { Heart, Sparkles, Loader2, Save } from "lucide-react";
import Navbar from "@/components/Navbar";
import { toast } from "sonner";

const Prayer = () => {
  const [feeling, setFeeling] = useState("");
  const [isGenerating, setIsGenerating] = useState(false);
  const [generatedPrayer, setGeneratedPrayer] = useState("");

  const handleGenerate = async () => {
    if (!feeling.trim()) {
      toast.error("Por favor, compartilhe seus sentimentos primeiro");
      return;
    }

    setIsGenerating(true);
    
    try {
      // TODO: Implement actual AI call via edge function
      // Simulating AI response
      setTimeout(() => {
        const prayer = `Senhor amado,

Venho até Ti com um coração que busca Tua presença. Neste momento, sinto ${feeling.toLowerCase()}, e sei que Tu conheces cada detalhe do meu coração.

Peço que me concedas paz e sabedoria para enfrentar este momento. Que Tua luz ilumine meu caminho e Teu amor me fortaleça.

Confio em Tuas promessas e sei que nunca me abandonarás. Obrigado por Teu amor incondicional e por estar sempre ao meu lado.

Em nome de Jesus, amém. 🙏`;

        setGeneratedPrayer(prayer);
        setIsGenerating(false);
        toast.success("Oração gerada com amor");
      }, 2000);
    } catch (error) {
      toast.error("Erro ao gerar oração. Tente novamente.");
      setIsGenerating(false);
    }
  };

  const handleSave = () => {
    toast.success("Oração salva no seu Diário Espiritual");
  };

  return (
    <div className="min-h-screen bg-gradient-celestial">
      <Navbar />
      
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 pt-24 pb-8">
        <div className="max-w-3xl mx-auto">
          {/* Header */}
          <div className="text-center mb-8 animate-fade-up">
            <div className="inline-flex items-center space-x-2 bg-primary/10 px-4 py-2 rounded-full border border-primary/20 mb-4">
              <Heart className="h-4 w-4 text-primary animate-glow" />
              <span className="text-sm font-medium text-primary">Oração Personalizada</span>
            </div>
            <h1 className="text-4xl font-bold mb-2">
              <span className="bg-gradient-divine bg-clip-text text-transparent">
                Eleve Seu Coração
              </span>
            </h1>
            <p className="text-muted-foreground">
              Compartilhe seus sentimentos e receba uma oração especial criada para você
            </p>
          </div>

          {/* Input Card */}
          <Card className="p-6 mb-6 animate-fade-up" style={{ animationDelay: "100ms" }}>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-2">
                  Como você está se sentindo hoje?
                </label>
                <Textarea
                  value={feeling}
                  onChange={(e) => setFeeling(e.target.value)}
                  placeholder="Compartilhe seus pensamentos, sentimentos ou situações que está enfrentando..."
                  className="min-h-[150px] resize-none"
                  disabled={isGenerating}
                />
              </div>

              <Button
                onClick={handleGenerate}
                disabled={isGenerating || !feeling.trim()}
                className="w-full bg-gradient-divine hover:opacity-90 transition-opacity"
                size="lg"
              >
                {isGenerating ? (
                  <>
                    <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                    Criando Oração...
                  </>
                ) : (
                  <>
                    <Sparkles className="mr-2 h-5 w-5" />
                    Gerar Oração Personalizada
                  </>
                )}
              </Button>
            </div>
          </Card>

          {/* Generated Prayer Card */}
          {generatedPrayer && (
            <Card className="p-8 animate-scale-in border-2 border-primary/20">
              <div className="space-y-6">
                <div className="flex items-center justify-between">
                  <h2 className="text-2xl font-bold text-primary flex items-center">
                    <Heart className="mr-2 h-6 w-6 animate-glow" />
                    Sua Oração
                  </h2>
                  <Button
                    onClick={handleSave}
                    variant="outline"
                    size="sm"
                  >
                    <Save className="mr-2 h-4 w-4" />
                    Salvar
                  </Button>
                </div>

                <div className="prose prose-lg max-w-none">
                  <p className="text-foreground leading-relaxed whitespace-pre-wrap italic">
                    {generatedPrayer}
                  </p>
                </div>

                <div className="border-t border-border pt-6">
                  <div className="flex items-start space-x-3">
                    <Sparkles className="h-5 w-5 text-primary mt-1 flex-shrink-0" />
                    <div className="space-y-2">
                      <h3 className="font-semibold text-primary">Reflexão</h3>
                      <p className="text-muted-foreground leading-relaxed">
                        Esta oração foi criada especialmente para você, baseada em seus sentimentos. 
                        Lembre-se que Deus está sempre ao seu lado, ouvindo cada palavra de seu coração.
                      </p>
                      <p className="text-sm text-muted-foreground italic">
                        "Não andeis ansiosos de coisa alguma; em tudo, porém, sejam conhecidos diante de Deus 
                        os vossos pedidos, pela oração e pela súplica, com ações de graças." - Filipenses 4:6
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </Card>
          )}

          {/* Info Box */}
          <div className="mt-6 p-4 bg-primary/5 border border-primary/20 rounded-lg">
            <p className="text-sm text-muted-foreground text-center">
              🕊️ <strong>Privacidade:</strong> Suas orações são pessoais e seguras. Você pode salvá-las no Diário Espiritual para revisitar quando quiser.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Prayer;
