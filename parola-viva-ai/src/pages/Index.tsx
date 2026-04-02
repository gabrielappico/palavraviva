import { Link } from "react-router-dom";
import { Sparkles, MessageCircle, BookOpen, Heart, ChevronRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import HeroSection from "@/components/HeroSection";
import FeaturesSection from "@/components/FeaturesSection";

const Index = () => {
  return (
    <div className="min-h-screen bg-gradient-celestial">
      {/* Navbar simplificada */}
      <nav className="fixed top-0 w-full z-50 bg-background/80 backdrop-blur-md border-b border-border">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <Link to="/" className="flex items-center gap-2">
              <div className="relative">
                <Sparkles className="h-8 w-8 text-primary" />
                <Sparkles className="h-4 w-4 text-accent absolute -top-1 -right-1 animate-pulse" />
              </div>
              <span className="text-xl font-bold bg-gradient-divine bg-clip-text text-transparent">
                Appi Palavra.AI
              </span>
            </Link>

            <div className="flex items-center gap-4">
              <Link to="/auth">
                <Button variant="ghost">Entrar</Button>
              </Link>
              <Link to="/auth">
                <Button className="bg-gradient-divine">
                  Começar Agora
                  <ChevronRight className="ml-2 h-4 w-4" />
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </nav>

      {/* Espaçamento para navbar fixa */}
      <div className="h-16" />

      <HeroSection />
      
      {/* Seção de Problemas e Soluções */}
      <section className="py-20 bg-background/50">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="max-w-3xl mx-auto text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold mb-4">
              Transforme sua experiência com a Palavra
            </h2>
            <p className="text-lg text-muted-foreground">
              Da dificuldade de compreensão à sabedoria aplicável
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-8 max-w-5xl mx-auto">
            <Card className="bg-card/50 border-border/50">
              <CardContent className="pt-6">
                <div className="text-red-500 mb-4">❌</div>
                <h3 className="text-xl font-semibold mb-3">Antes</h3>
                <ul className="space-y-2 text-muted-foreground">
                  <li>• Dificuldade em entender contextos bíblicos</li>
                  <li>• Falta de tempo para estudos profundos</li>
                  <li>• Preparação de mensagens demorada</li>
                  <li>• Orações genéricas e distantes</li>
                </ul>
              </CardContent>
            </Card>

            <Card className="bg-gradient-to-br from-primary/10 to-accent/10 border-primary/20">
              <CardContent className="pt-6">
                <div className="text-green-500 mb-4">✓</div>
                <h3 className="text-xl font-semibold mb-3">Depois</h3>
                <ul className="space-y-2 text-foreground">
                  <li>• IA explica versículos com clareza</li>
                  <li>• Estudos profundos em minutos</li>
                  <li>• Sermões completos gerados por IA</li>
                  <li>• Orações personalizadas e profundas</li>
                </ul>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      <FeaturesSection />

      {/* Seção de Preço */}
      <section className="py-20">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="max-w-2xl mx-auto">
            <Card className="bg-gradient-to-br from-primary/5 to-accent/5 border-primary/20">
              <CardContent className="pt-8">
                <div className="text-center mb-8">
                  <h3 className="text-3xl font-bold mb-2">Plano Completo</h3>
                  <div className="flex items-baseline justify-center gap-2 mb-4">
                    <span className="text-5xl font-bold bg-gradient-divine bg-clip-text text-transparent">
                      R$ 89,90
                    </span>
                    <span className="text-muted-foreground">/mês</span>
                  </div>
                  <p className="text-muted-foreground">
                    Acesso ilimitado a todas as funcionalidades
                  </p>
                </div>

                <div className="space-y-3 mb-8">
                  <div className="flex items-center gap-3">
                    <MessageCircle className="h-5 w-5 text-primary" />
                    <span>Chat ilimitado com IA teológica</span>
                  </div>
                  <div className="flex items-center gap-3">
                    <BookOpen className="h-5 w-5 text-primary" />
                    <span>Bíblia completa com interpretações</span>
                  </div>
                  <div className="flex items-center gap-3">
                    <Heart className="h-5 w-5 text-primary" />
                    <span>Orações e sermões personalizados</span>
                  </div>
                  <div className="flex items-center gap-3">
                    <Sparkles className="h-5 w-5 text-primary" />
                    <span>Quiz e dinâmicas cristãs</span>
                  </div>
                </div>

                <Link to="/auth" className="block">
                  <Button className="w-full bg-gradient-divine text-lg py-6">
                    Começar Agora
                    <ChevronRight className="ml-2 h-5 w-5" />
                  </Button>
                </Link>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-border py-12 bg-background/50">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center space-y-4">
            <p className="text-lg font-semibold bg-gradient-divine bg-clip-text text-transparent">
              Appi Palavra.AI
            </p>
            <p className="text-sm text-muted-foreground">
              Onde a fé encontra a tecnologia
            </p>
            <p className="text-xs text-muted-foreground">
              © 2025 Appi Palavra.AI. Todos os direitos reservados.
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default Index;
