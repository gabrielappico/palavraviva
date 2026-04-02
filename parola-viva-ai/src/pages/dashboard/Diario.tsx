import { useState, useEffect } from "react";
import { DashboardLayout } from "@/components/dashboard/DashboardLayout";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { BookMarked, Heart, BookOpen } from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import { toast } from "sonner";

const Diario = () => {
  const [prayers, setPrayers] = useState<any[]>([]);
  const [favorites, setFavorites] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      const [prayersRes, favoritesRes] = await Promise.all([
        supabase.from("prayers").select("*").order("created_at", { ascending: false }),
        supabase.from("favorite_verses").select("*").order("created_at", { ascending: false }),
      ]);

      if (prayersRes.error) throw prayersRes.error;
      if (favoritesRes.error) throw favoritesRes.error;

      setPrayers(prayersRes.data || []);
      setFavorites(favoritesRes.data || []);
    } catch (error) {
      console.error("Error loading data:", error);
      toast.error("Erro ao carregar dados");
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString("pt-BR", {
      day: "2-digit",
      month: "long",
      year: "numeric",
    });
  };

  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold mb-2">Diário Espiritual</h1>
          <p className="text-muted-foreground">
            Suas orações, versículos e reflexões em um só lugar
          </p>
        </div>

        <Tabs defaultValue="prayers" className="w-full">
          <TabsList className="grid w-full grid-cols-2">
            <TabsTrigger value="prayers" className="flex items-center gap-2">
              <Heart className="h-4 w-4" />
              Orações
            </TabsTrigger>
            <TabsTrigger value="verses" className="flex items-center gap-2">
              <BookOpen className="h-4 w-4" />
              Versículos Favoritos
            </TabsTrigger>
          </TabsList>

          <TabsContent value="prayers" className="space-y-4">
            {loading ? (
              <Card>
                <CardContent className="pt-6">
                  <p className="text-center text-muted-foreground">Carregando...</p>
                </CardContent>
              </Card>
            ) : prayers.length === 0 ? (
              <Card>
                <CardContent className="pt-6">
                  <p className="text-center text-muted-foreground">
                    Nenhuma oração salva ainda. Visite a página de Oração para criar uma.
                  </p>
                </CardContent>
              </Card>
            ) : (
              prayers.map((prayer) => (
                <Card key={prayer.id}>
                  <CardHeader>
                    <div className="flex items-start justify-between">
                      <div>
                        <CardTitle className="text-lg">Oração</CardTitle>
                        <p className="text-sm text-muted-foreground mt-1">
                          {formatDate(prayer.created_at)}
                        </p>
                      </div>
                      <Heart className="h-5 w-5 text-primary" />
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-3">
                    {prayer.feeling && (
                      <div>
                        <p className="text-sm font-semibold mb-1">Sentimento:</p>
                        <p className="text-sm text-muted-foreground">{prayer.feeling}</p>
                      </div>
                    )}
                    <div>
                      <p className="text-sm font-semibold mb-1">Oração:</p>
                      <p className="text-sm text-muted-foreground whitespace-pre-wrap">
                        {prayer.prayer_text}
                      </p>
                    </div>
                  </CardContent>
                </Card>
              ))
            )}
          </TabsContent>

          <TabsContent value="verses" className="space-y-4">
            {loading ? (
              <Card>
                <CardContent className="pt-6">
                  <p className="text-center text-muted-foreground">Carregando...</p>
                </CardContent>
              </Card>
            ) : favorites.length === 0 ? (
              <Card>
                <CardContent className="pt-6">
                  <p className="text-center text-muted-foreground">
                    Nenhum versículo favorito salvo ainda. Visite a Bíblia para adicionar favoritos.
                  </p>
                </CardContent>
              </Card>
            ) : (
              favorites.map((verse) => (
                <Card key={verse.id}>
                  <CardHeader>
                    <div className="flex items-start justify-between">
                      <div>
                        <CardTitle className="text-lg">{verse.verse_reference}</CardTitle>
                        <p className="text-sm text-muted-foreground mt-1">
                          {verse.version} • {formatDate(verse.created_at)}
                        </p>
                      </div>
                      <BookOpen className="h-5 w-5 text-primary" />
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-3">
                    <div className="p-3 bg-primary/5 rounded-lg">
                      <p className="text-sm leading-relaxed">{verse.verse_text}</p>
                    </div>
                    {verse.note && (
                      <div>
                        <p className="text-sm font-semibold mb-1">Nota:</p>
                        <p className="text-sm text-muted-foreground">{verse.note}</p>
                      </div>
                    )}
                  </CardContent>
                </Card>
              ))
            )}
          </TabsContent>
        </Tabs>
      </div>
    </DashboardLayout>
  );
};

export default Diario;
