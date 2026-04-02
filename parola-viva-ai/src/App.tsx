import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Index from "./pages/Index";
import Auth from "./pages/Auth";
import Insights from "./pages/Insights";
import Dashboard from "./pages/dashboard/Dashboard";
import PalavraViva from "./pages/dashboard/PalavraViva";
import Biblia from "./pages/dashboard/Biblia";
import Oracao from "./pages/dashboard/Oracao";
import Confessionario from "./pages/dashboard/Confessionario";
import Pregacoes from "./pages/dashboard/Pregacoes";
import Quiz from "./pages/dashboard/Quiz";
import Dinamicas from "./pages/dashboard/Dinamicas";
import Diario from "./pages/dashboard/Diario";
import NotFound from "./pages/NotFound";
import { ProtectedRoute } from "./components/ProtectedRoute";
import { FirebaseProvider } from "./providers/FirebaseProvider";
import { SharedAuthProvider } from "./hooks/useSharedAuth";

const queryClient = new QueryClient();

const App = () => (
  <QueryClientProvider client={queryClient}>
    <SharedAuthProvider>
      <FirebaseProvider>
        <TooltipProvider>
          <Toaster />
          <Sonner />
          <BrowserRouter>
            <Routes>
              <Route path="/" element={<Index />} />
              <Route path="/auth" element={<Auth />} />
              <Route
                path="/insights"
                element={
                  <ProtectedRoute>
                    <Insights />
                  </ProtectedRoute>
                }
              />
              <Route
                path="/dashboard"
                element={
                  <ProtectedRoute>
                    <Dashboard />
                  </ProtectedRoute>
                }
              />
              <Route
                path="/dashboard/biblia"
                element={
                  <ProtectedRoute>
                    <Biblia />
                  </ProtectedRoute>
                }
              />
              <Route
                path="/dashboard/oracao"
                element={
                  <ProtectedRoute>
                    <Oracao />
                  </ProtectedRoute>
                }
              />
              <Route
                path="/dashboard/palavra-viva"
                element={
                  <ProtectedRoute>
                    <PalavraViva />
                  </ProtectedRoute>
                }
              />
              <Route
                path="/dashboard/dinamicas"
                element={
                  <ProtectedRoute>
                    <Dinamicas />
                  </ProtectedRoute>
                }
              />
              <Route
                path="/dashboard/quiz"
                element={
                  <ProtectedRoute>
                    <Quiz />
                  </ProtectedRoute>
                }
              />
              <Route
                path="/dashboard/diario"
                element={
                  <ProtectedRoute>
                    <Diario />
                  </ProtectedRoute>
                }
              />
              <Route
                path="/dashboard/pregacoes"
                element={
                  <ProtectedRoute>
                    <Pregacoes />
                  </ProtectedRoute>
                }
              />
              <Route
                path="/dashboard/confessionario"
                element={
                  <ProtectedRoute>
                    <Confessionario />
                  </ProtectedRoute>
                }
              />
              <Route path="*" element={<NotFound />} />
            </Routes>
          </BrowserRouter>
        </TooltipProvider>
      </FirebaseProvider>
    </SharedAuthProvider>
  </QueryClientProvider>
);

export default App;
