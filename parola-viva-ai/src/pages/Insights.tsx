import { useInsightsIA } from '@/hooks/useInsightsIA';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Bell, CheckCircle, AlertTriangle, TrendingUp, MessageSquare, LayoutDashboard } from 'lucide-react';

export default function InsightsPage() {
  const { insights, isLoading, marcarComoLido, countNovos } = useInsightsIA();

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
      </div>
    );
  }

  const tipoIcons = {
    recomendacao: TrendingUp,
    alerta: AlertTriangle,
    previsao: TrendingUp,
    chat: MessageSquare,
    dashboard: LayoutDashboard,
  };

  const statusColors = {
    novo: 'default',
    lido: 'secondary',
    aplicado: 'outline',
    descartado: 'outline',
    arquivado: 'outline',
  } as const;

  return (
    <div className="container mx-auto p-6 max-w-6xl">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-3xl font-bold">Central de Insights</h1>
          <p className="text-muted-foreground">Insights compartilhados entre todas as suas aplicações</p>
        </div>
        {countNovos > 0 && (
          <Badge variant="destructive" className="gap-2">
            <Bell className="h-4 w-4" />
            {countNovos} novos
          </Badge>
        )}
      </div>

      <Tabs defaultValue="todos" className="w-full">
        <TabsList className="grid w-full grid-cols-5">
          <TabsTrigger value="todos">Todos</TabsTrigger>
          <TabsTrigger value="novos">Novos</TabsTrigger>
          <TabsTrigger value="recomendacao">Recomendações</TabsTrigger>
          <TabsTrigger value="alerta">Alertas</TabsTrigger>
          <TabsTrigger value="previsao">Previsões</TabsTrigger>
        </TabsList>

        {['todos', 'novos', 'recomendacao', 'alerta', 'previsao'].map(tab => (
          <TabsContent key={tab} value={tab} className="space-y-4">
            {insights
              ?.filter(insight => {
                if (tab === 'todos') return true;
                if (tab === 'novos') return insight.status === 'novo';
                return insight.tipo === tab;
              })
              .map(insight => {
                const Icon = tipoIcons[insight.tipo];
                return (
                  <Card key={insight.id} className={insight.status === 'novo' ? 'border-primary' : ''}>
                    <CardHeader>
                      <div className="flex items-start justify-between gap-4">
                        <div className="flex items-center gap-2">
                          <Icon className="h-5 w-5 text-primary" />
                          <Badge variant={insight.tipo === 'alerta' ? 'destructive' : 'default'}>
                            {insight.tipo}
                          </Badge>
                          <Badge variant={statusColors[insight.status]}>
                            {insight.status}
                          </Badge>
                        </div>
                        <div className="flex items-center gap-2">
                          <Badge variant="outline">
                            {insight.relevancia_score}/10
                          </Badge>
                          <span className="text-xs text-muted-foreground">
                            {insight.aplicacao_origem}
                          </span>
                        </div>
                      </div>
                    </CardHeader>
                    <CardContent>
                      <div className="prose prose-sm max-w-none mb-4">
                        <p>{insight.conteudo}</p>
                      </div>
                      
                      {insight.tags && insight.tags.length > 0 && (
                        <div className="flex gap-2 mb-4">
                          {insight.tags.map((tag, idx) => (
                            <Badge key={idx} variant="outline" className="text-xs">
                              {tag}
                            </Badge>
                          ))}
                        </div>
                      )}

                      <div className="flex items-center justify-between text-xs text-muted-foreground">
                        <span>
                          {new Date(insight.created_at).toLocaleDateString('pt-BR', {
                            day: '2-digit',
                            month: 'short',
                            year: 'numeric',
                            hour: '2-digit',
                            minute: '2-digit',
                          })}
                        </span>
                        {insight.valido_ate && (
                          <span>Válido até: {new Date(insight.valido_ate).toLocaleDateString('pt-BR')}</span>
                        )}
                      </div>

                      {insight.status === 'novo' && (
                        <Button 
                          onClick={() => marcarComoLido(insight.id)}
                          className="mt-4 w-full"
                          variant="outline"
                        >
                          <CheckCircle className="h-4 w-4 mr-2" />
                          Marcar como Lido
                        </Button>
                      )}
                    </CardContent>
                  </Card>
                );
              })}
            
            {insights?.filter(insight => {
              if (tab === 'todos') return true;
              if (tab === 'novos') return insight.status === 'novo';
              return insight.tipo === tab;
            }).length === 0 && (
              <div className="text-center py-12 text-muted-foreground">
                Nenhum insight encontrado nesta categoria
              </div>
            )}
          </TabsContent>
        ))}
      </Tabs>
    </div>
  );
}
