import { useState, useEffect } from "react";
import { DashboardLayout } from "@/components/dashboard/DashboardLayout";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Label } from "@/components/ui/label";
import { Brain, CheckCircle, XCircle } from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import { toast } from "sonner";

const Quiz = () => {
  const [category, setCategory] = useState("antigo_testamento");
  const [difficulty, setDifficulty] = useState("facil");
  const [questions, setQuestions] = useState<any[]>([]);
  const [currentQuestion, setCurrentQuestion] = useState(0);
  const [selectedAnswer, setSelectedAnswer] = useState<string | null>(null);
  const [showExplanation, setShowExplanation] = useState(false);
  const [score, setScore] = useState(0);
  const [quizStarted, setQuizStarted] = useState(false);

  const loadQuestions = async () => {
    try {
      const { data, error } = await supabase
        .from("quiz_questions")
        .select("*")
        .eq("category", category)
        .eq("difficulty", difficulty)
        .limit(10);

      if (error) throw error;

      setQuestions(data || []);
      setQuizStarted(true);
      setCurrentQuestion(0);
      setScore(0);
      setSelectedAnswer(null);
      setShowExplanation(false);
    } catch (error) {
      console.error("Error loading questions:", error);
      toast.error("Erro ao carregar perguntas");
    }
  };

  const handleAnswer = () => {
    if (!selectedAnswer) return;

    const question = questions[currentQuestion];
    const isCorrect = selectedAnswer === question.correct_answer;

    if (isCorrect) {
      setScore((prev) => prev + 1);
    }

    setShowExplanation(true);
  };

  const handleNext = () => {
    if (currentQuestion < questions.length - 1) {
      setCurrentQuestion((prev) => prev + 1);
      setSelectedAnswer(null);
      setShowExplanation(false);
    } else {
      toast.success(`Quiz finalizado! Pontuação: ${score + 1}/${questions.length}`);
      setQuizStarted(false);
    }
  };

  const currentQ = questions[currentQuestion];

  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold mb-2">Quiz Bíblico</h1>
          <p className="text-muted-foreground">
            Teste seus conhecimentos sobre as Escrituras
          </p>
        </div>

        {!quizStarted ? (
          <Card>
            <CardHeader>
              <CardTitle>Configurar Quiz</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label>Categoria</Label>
                <Select value={category} onValueChange={setCategory}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="antigo_testamento">Antigo Testamento</SelectItem>
                    <SelectItem value="novo_testamento">Novo Testamento</SelectItem>
                    <SelectItem value="personagens">Personagens</SelectItem>
                    <SelectItem value="doutrina">Doutrina</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label>Dificuldade</Label>
                <Select value={difficulty} onValueChange={setDifficulty}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="facil">Fácil</SelectItem>
                    <SelectItem value="medio">Médio</SelectItem>
                    <SelectItem value="dificil">Difícil</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <Button onClick={loadQuestions} className="w-full">
                <Brain className="mr-2 h-5 w-5" />
                Iniciar Quiz
              </Button>
            </CardContent>
          </Card>
        ) : (
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle>
                  Pergunta {currentQuestion + 1} de {questions.length}
                </CardTitle>
                <span className="text-sm text-muted-foreground">
                  Pontuação: {score}/{currentQuestion + (showExplanation ? 1 : 0)}
                </span>
              </div>
            </CardHeader>
            <CardContent className="space-y-6">
              <div>
                <h3 className="text-lg font-semibold mb-4">{currentQ?.question}</h3>
                <div className="space-y-2">
                  {currentQ?.options && JSON.parse(currentQ.options).map((option: string) => (
                    <Button
                      key={option}
                      variant={selectedAnswer === option ? "default" : "outline"}
                      className="w-full justify-start"
                      onClick={() => !showExplanation && setSelectedAnswer(option)}
                      disabled={showExplanation}
                    >
                      {option}
                      {showExplanation && option === currentQ.correct_answer && (
                        <CheckCircle className="ml-auto h-5 w-5 text-green-500" />
                      )}
                      {showExplanation && option === selectedAnswer && option !== currentQ.correct_answer && (
                        <XCircle className="ml-auto h-5 w-5 text-red-500" />
                      )}
                    </Button>
                  ))}
                </div>
              </div>

              {showExplanation && (
                <div className="p-4 bg-primary/5 rounded-lg">
                  <p className="text-sm font-semibold mb-2">Explicação:</p>
                  <p className="text-sm text-muted-foreground">{currentQ?.explanation}</p>
                </div>
              )}

              <div className="flex gap-2">
                {!showExplanation ? (
                  <Button onClick={handleAnswer} disabled={!selectedAnswer} className="w-full">
                    Confirmar Resposta
                  </Button>
                ) : (
                  <Button onClick={handleNext} className="w-full">
                    {currentQuestion < questions.length - 1 ? "Próxima Pergunta" : "Finalizar Quiz"}
                  </Button>
                )}
              </div>
            </CardContent>
          </Card>
        )}
      </div>
    </DashboardLayout>
  );
};

export default Quiz;
