import { MessageCircle, BookOpen, Heart, Sparkles, Search, Users } from "lucide-react";
import { Card } from "@/components/ui/card";

const features = [
  {
    icon: MessageCircle,
    title: "Palavra Viva",
    description: "Converse com a Bíblia em linguagem natural. IA teológica responde suas dúvidas com versículos e explicações profundas.",
    gradient: "from-primary/20 to-primary/5",
  },
  {
    icon: BookOpen,
    title: "Bíblia Interativa",
    description: "Explore versões NVI, ARC, ARA e NVT. Busque por palavra, tema ou versículo com interpretações contextuais da IA.",
    gradient: "from-secondary/20 to-secondary/5",
  },
  {
    icon: Heart,
    title: "Orações Personalizadas",
    description: "Compartilhe seus sentimentos e receba orações criadas especialmente para você, com opção de áudio e salvamento.",
    gradient: "from-accent/20 to-accent/5",
  },
  {
    icon: Sparkles,
    title: "Auxílio para Pregações",
    description: "Gere sermões completos com tema, tópicos, aplicação prática e oração final baseados nas Escrituras.",
    gradient: "from-primary/20 to-primary/5",
  },
  {
    icon: Search,
    title: "Quiz Bíblico",
    description: "Teste seus conhecimentos com perguntas categorizadas e níveis de dificuldade. IA explica cada resposta.",
    gradient: "from-secondary/20 to-secondary/5",
  },
  {
    icon: Users,
    title: "Dinâmicas Cristãs",
    description: "Receba sugestões de dinâmicas e atividades espirituais personalizadas para seu grupo ou ministério.",
    gradient: "from-accent/20 to-accent/5",
  },
];

const FeaturesSection = () => {
  return (
    <section className="py-24 relative">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center space-y-4 mb-16 animate-fade-up">
          <h2 className="text-4xl sm:text-5xl font-bold">
            <span className="bg-gradient-divine bg-clip-text text-transparent">
              Recursos Poderosos
            </span>
          </h2>
          <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
            Tudo que você precisa para aprofundar sua jornada espiritual
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6 max-w-7xl mx-auto">
          {features.map((feature, index) => (
            <Card
              key={index}
              className="relative overflow-hidden group hover:shadow-lg transition-all duration-300 border-2 animate-fade-up"
              style={{ animationDelay: `${index * 100}ms` }}
            >
              <div className={`absolute inset-0 bg-gradient-to-br ${feature.gradient} opacity-0 group-hover:opacity-100 transition-opacity duration-300`} />
              
              <div className="relative p-6 space-y-4">
                <div className="w-12 h-12 rounded-xl bg-gradient-divine flex items-center justify-center group-hover:scale-110 transition-transform duration-300">
                  <feature.icon className="h-6 w-6 text-primary-foreground" />
                </div>
                
                <h3 className="text-xl font-bold text-foreground group-hover:text-primary transition-colors">
                  {feature.title}
                </h3>
                
                <p className="text-muted-foreground leading-relaxed">
                  {feature.description}
                </p>
              </div>
            </Card>
          ))}
        </div>
      </div>
    </section>
  );
};

export default FeaturesSection;
