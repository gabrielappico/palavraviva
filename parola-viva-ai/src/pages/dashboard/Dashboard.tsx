import { useState } from "react";
import { DashboardLayout } from "@/components/dashboard/DashboardLayout";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Link } from "react-router-dom";
import { MessageCircle, BookOpen, Heart, Mic, Brain, Users, ArrowRight, Shield } from "lucide-react";
import { PersonalizedMessage } from "@/components/mood/PersonalizedMessage";
import { MoodCheckIn } from "@/components/mood/MoodCheckIn";

const Dashboard = () => {
  const [refreshKey, setRefreshKey] = useState(0);
  const quickActions = [
    {
      icon: MessageCircle,
      title: "Palavra Viva",
      description: "Converse com a IA teológica",
      path: "/dashboard/palavra-viva",
      gradient: "from-blue-500 to-cyan-500",
    },
    {
      icon: BookOpen,
      title: "Bíblia",
      description: "Explore as Escrituras",
      path: "/dashboard/biblia",
      gradient: "from-purple-500 to-pink-500",
    },
    {
      icon: Heart,
      title: "Oração",
      description: "Gere orações personalizadas",
      path: "/dashboard/oracao",
      gradient: "from-red-500 to-orange-500",
    },
    {
      icon: Shield,
      title: "Confessionário",
      description: "Espaço seguro e confidencial",
      path: "/dashboard/confessionario",
      gradient: "from-emerald-500 to-teal-500",
    },
    {
      icon: Mic,
      title: "Pregações",
      description: "Crie sermões completos",
      path: "/dashboard/pregacoes",
      gradient: "from-green-500 to-emerald-500",
    },
    {
      icon: Brain,
      title: "Quiz",
      description: "Teste seus conhecimentos",
      path: "/dashboard/quiz",
      gradient: "from-yellow-500 to-amber-500",
    },
    {
      icon: Users,
      title: "Dinâmicas",
      description: "Atividades para grupos",
      path: "/dashboard/dinamicas",
      gradient: "from-indigo-500 to-blue-500",
    },
  ];

  return (
    <DashboardLayout>
      <div className="space-y-8">
        {/* Welcome Section */}
        <div>
          <h1 className="text-3xl font-bold mb-2">Bem-vindo de volta! ✨</h1>
          <p className="text-muted-foreground">
            Continue sua jornada espiritual
          </p>
        </div>

        {/* Personalized Content */}
        <div className="grid gap-6 md:grid-cols-2">
          <PersonalizedMessage key={refreshKey} />
          <MoodCheckIn 
            compact 
            onComplete={() => setRefreshKey(prev => prev + 1)} 
          />
        </div>

        {/* Quick Actions */}
        <div>
          <h2 className="text-2xl font-bold mb-6">Acesso Rápido</h2>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {quickActions.map((action) => {
              const Icon = action.icon;
              return (
                <Link key={action.path} to={action.path}>
                  <Card className="hover:shadow-lg transition-all hover:-translate-y-1 cursor-pointer h-full">
                    <CardContent className="pt-6">
                      <div className={`w-12 h-12 rounded-lg bg-gradient-to-br ${action.gradient} flex items-center justify-center mb-4`}>
                        <Icon className="h-6 w-6 text-white" />
                      </div>
                      <h3 className="text-lg font-semibold mb-2">{action.title}</h3>
                      <p className="text-muted-foreground text-sm mb-4">
                        {action.description}
                      </p>
                      <Button variant="ghost" size="sm" className="group">
                        Acessar
                        <ArrowRight className="ml-2 h-4 w-4 group-hover:translate-x-1 transition-transform" />
                      </Button>
                    </CardContent>
                  </Card>
                </Link>
              );
            })}
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
};

export default Dashboard;
