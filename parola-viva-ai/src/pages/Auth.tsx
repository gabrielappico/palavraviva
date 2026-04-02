import { useState } from "react";
import { Link } from "react-router-dom";
import { Sparkles } from "lucide-react";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { LoginForm } from "@/components/auth/LoginForm";
import { RegisterForm } from "@/components/auth/RegisterForm";

const Auth = () => {
  const [activeTab, setActiveTab] = useState<string>("login");

  return (
    <div className="min-h-screen flex flex-col bg-gradient-celestial">
      {/* Header */}
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-6">
        <Link to="/" className="flex items-center gap-2 w-fit">
          <div className="relative">
            <Sparkles className="h-8 w-8 text-primary" />
            <Sparkles className="h-4 w-4 text-accent absolute -top-1 -right-1 animate-pulse" />
          </div>
          <span className="text-2xl font-bold bg-gradient-divine bg-clip-text text-transparent">
            Appi Palavra.AI
          </span>
        </Link>
      </div>

      {/* Auth Content */}
      <div className="flex-1 flex items-center justify-center px-4 py-12">
        <div className="w-full max-w-md">
          <div className="text-center mb-8">
            <h1 className="text-3xl font-bold text-foreground mb-2">
              {activeTab === "login" ? "Bem-vindo de volta" : "Comece sua jornada"}
            </h1>
            <p className="text-muted-foreground">
              {activeTab === "login"
                ? "Entre para continuar sua jornada espiritual"
                : "Crie sua conta e transforme sua experiência com a Palavra"}
            </p>
          </div>

          <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
            <TabsList className="grid w-full grid-cols-2 mb-8">
              <TabsTrigger value="login">Entrar</TabsTrigger>
              <TabsTrigger value="register">Criar Conta</TabsTrigger>
            </TabsList>

            <TabsContent value="login">
              <LoginForm />
            </TabsContent>

            <TabsContent value="register">
              <RegisterForm />
            </TabsContent>
          </Tabs>

          <div className="mt-8 text-center text-sm text-muted-foreground">
            <Link to="/" className="hover:text-primary transition-colors">
              ← Voltar para o início
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Auth;
