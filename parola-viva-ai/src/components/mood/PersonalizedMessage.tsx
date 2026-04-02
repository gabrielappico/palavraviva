import { useEffect, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { supabase } from "@/integrations/supabase/client";
import { useSharedAuth } from "@/hooks/useSharedAuth";
import { useToast } from "@/hooks/use-toast";
import { Sparkles, ArrowRight } from "lucide-react";
import { useNavigate } from "react-router-dom";

interface Recommendation {
  verse: {
    reference: string;
    text: string;
    reason: string;
  };
  message: string;
  prayer_suggestion: string;
  recommended_action: {
    type: string;
    label: string;
    path: string;
  };
}

export const PersonalizedMessage = () => {
  const [recommendation, setRecommendation] = useState<Recommendation | null>(null);
  const [loading, setLoading] = useState(true);
  const { user } = useSharedAuth();
  const { toast } = useToast();
  const navigate = useNavigate();

  useEffect(() => {
    if (!user) return;
    
    // Pequeno delay para garantir que os dados foram salvos no banco
    const timer = setTimeout(() => {
      loadRecommendation();
    }, 300);
    
    return () => clearTimeout(timer);
  }, [user]);

  const loadRecommendation = async () => {
    if (!user) return;
    
    setLoading(true);
    try {
      const { data, error } = await supabase.functions.invoke("recommend-content", {
        body: { user_id: user.id }
      });

      if (error) throw error;

      setRecommendation(data.recommendation);
    } catch (error) {
      console.error("Error loading recommendation:", error);
      // Fallback silencioso - não mostrar erro ao usuário
      setRecommendation(null);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <Card className="bg-gradient-to-br from-primary/10 to-accent/10">
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Sparkles className="h-5 w-5" />
            Mensagem para Você Hoje
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          <Skeleton className="h-20 w-full" />
          <Skeleton className="h-4 w-3/4" />
          <Skeleton className="h-16 w-full" />
        </CardContent>
      </Card>
    );
  }

  if (!recommendation) {
    return (
      <Card className="bg-gradient-to-br from-primary/10 to-accent/10">
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Sparkles className="h-5 w-5" />
            Bem-vindo de volta!
          </CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-muted-foreground mb-4">
            Compartilhe como você está se sentindo para receber mensagens personalizadas.
          </p>
          <Button onClick={loadRecommendation} variant="outline">
            Atualizar mensagem
          </Button>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className="bg-gradient-to-br from-primary/10 to-accent/10 border-primary/20 animate-fade-in">
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Sparkles className="h-5 w-5 text-primary animate-pulse" />
          Mensagem para Você Hoje
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div>
          <p className="text-lg mb-2 italic leading-relaxed">
            "{recommendation.verse.text}"
          </p>
          <p className="text-sm font-semibold text-primary mb-1">
            {recommendation.verse.reference}
          </p>
          <p className="text-xs text-muted-foreground">
            {recommendation.verse.reason}
          </p>
        </div>

        <div className="p-4 bg-background/50 rounded-lg">
          <p className="text-sm leading-relaxed">{recommendation.message}</p>
        </div>

        {recommendation.prayer_suggestion && (
          <div className="space-y-2">
            <p className="text-sm text-muted-foreground">
              💭 {recommendation.prayer_suggestion}
            </p>
            <Button
              onClick={() => navigate(recommendation.recommended_action.path)}
              className="w-full"
              variant="default"
            >
              {recommendation.recommended_action.label}
              <ArrowRight className="ml-2 h-4 w-4" />
            </Button>
          </div>
        )}
      </CardContent>
    </Card>
  );
};