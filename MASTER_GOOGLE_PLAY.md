# 🏆 Documento Master: Lançamento no Google Play Console

Este documento contém EXATAMENTE os textos, opções e configurações que você precisa copiar e colar para publicar o **Palavra Viva**. Tudo adaptado para garantir a aprovação.

## 1. Presença na Loja (Metadata)

* **Nome do App:** 
  > Palavra Viva - Devocionais
  
* **Descrição Curta:** 
  > Receba mensagens diárias de fé, versículos bíblicos e fortaleça o seu espírito.

* **Descrição Completa:** 
  *(Copie exatamente o texto abaixo)*
  
  > Encontre inspiração, sabedoria e paz para o seu dia a dia com o aplicativo Palavra Viva. Criado para aproximar você da presença de Deus, nosso app traz diariamente reflexões poderosas e versículos bíblicos selecionados para edificar a sua fé.
  > 
  > Por que usar o Palavra Viva?
  > ✅ **Devocional Diário:** Receba todos os dias uma nova palavra de encorajamento para direcionar sua jornada.
  > ✅ **Versículo do Dia:** Comece sua manhã lendo as passagens bíblicas mais inspiradoras.
  > ✅ **Design Premium e Imersivo:** Experiência de uso fluida com o "Modo Celestial" (escuro), com detalhes em dourado metálico para uma leitura confortável em qualquer ambiente.
  > ✅ **Lembretes Personalizados:** Configure notificações para o seu momento a sós com a Palavra e não perca nenhum devocional.
  > ✅ **Seguro e Privativo:** Mantemos seus dados e seu histórico espiritual protegidos na nuvem de maneira particular.
  > 
  > Desenvolvido com excelência pela Appi Company. Baixe agora e traga uma nova chama para a sua vida espiritual! 

## 2. Recursos Gráficos
Respeitar estas dimensões é estritamente OBRIGATÓRIO. *(Já criamos pelo Flutter os ícones do app, então aqui são só as imagens vitrine pro site).*

* **Ícone da Loja:** 
  O logo (letra dourada, fundo `#141B2D`) redimensionado exatamente para **512x512px**, arquivo `.png` (peso até 1MB).
* **Imagem de Recurso (Feature Graphic):** 
  Um banner lindo com a logo no meio, sem transparências, no tamanho exato de **1024x500px**, formato JPEG ou PNG.
* **Capturas de Tela (Screenshots - Telefones):** 
  De 2 a 8 prints das melhores telas do app (ex: Tela Home, Tela de Configurações, Tela do Devocional aberto). Use o tamanho **1080x1920px**. Tente colocar os prints dentro de molduras ("Mockups") de celular ou só envie os prints crus do aparelho caso precise agilizar.

## 3. Classificação e Categorização
* **Tipo de App:** `App`
* **Categoria:** `Estilo de vida` (Recomendado) ou `Educação`
* **Tags (Marcar estas):** 
  - Religião e espiritualidade
  - Autocuidado
  - Estilo de Vida
* **Questionário IARC:** Preencha **"NÃO"** para absolutamente tudo (violência, medo, sangue, comunicação descontrolada, jogo de azar). O resultado será Classificação "**Livre**".

## 4. Políticas e Privacidade
Cole exatamente isso lá:

* **URL da Política de Privacidade:** `[Colevação o link do Notion/Docs da sua Política se tiver, ou crie uma similar a debaixo]`
* **URL de Exclusão de Conta:** `[Pegue o link público do documento "Política de Exclusão" que criamos na conversa anterior]`
* **Declaração de Anúncios:** Marque **"NÃO"** (pois o app não contém banners de admob ou publicidade agressiva).
* **Apps de Notícias:** Marque **"NÃO"** (o app não é um jornal).
* **Covid-19:** Marque **"Meu app não é publicamente sobre Covid-19"**.
  
**Seção Segurança de Dados (Data Safety):**
Marque exatamente isto:
* Você coleta ou compartilha dados? **Sim** (Coleta).
* Os dados são criptografados em trânsito? **Sim** (Usamos HTTPS/Supabase).
* Há uma forma dos usuários excluírem os dados? **Sim**.
* Marque apenas os seguintes dados:
  1. **Informações Pessoais:** `E-mail` -> Para "Acesso/Gerenciamento da Conta". (Obrigatório e Coletado).
  2. **Identificadores:** `ID de Usuário / Outros` -> Para Funcionalidade.
  *(Atenção: Apenas marque que coleta os dados que o usuário DE FATO digita ou usa no Supabase).*

## 5. Acesso ao App (App Access)
O app tem login, então o Google não consegue testar se você não mandar um usuário!
* Escolha **"Todas as partes ou algumas partes do meu app são restritas"**.
* Clique em "Adicionar Instruções".
* **Nome de Usuário:** `googleplay@appicompany.com`
* **Senha:** `palavraviva123`
* **Instruções adicionais:** "Este é um aplicativo diário devocional. Criei esta conta de teste sem autenticação de dois fatores, basta fazer o login com estas credenciais para acessar a Home e verificar as funcionalidades."

**ATENÇÃO:** Lembre-se de ir no painel do seu banco de dados e **criar** manualmente essa conta `googleplay@appicompany.com` com senha `palavraviva123` para que a tela não dê erro na hora que avaliador testar.

## 6. Detalhes de Contato e Suporte
Dados que ficarão escancarados para qualquer um na Play Store:
* **Website:** Deixe vazio (ou o link da empresa).
* **E-mail de suporte:** `contato@appicompany.com` (OBRIGATÓRIO)
* **Telefone:** Deixe vazio.

## 7. Configurações Técnicas
Informações sobre como a engenharia estruturou o app (apenas cheque se está certo na hora de puxar os dados).
* **Application ID/Package Name:** `com.palavraviva.app`
* **Arquivo para envio da Versão:** Só será aceito o arquivo Bundle em formato **`.aab`** com menos de 150mb (já verificamos que vocês já o geraram e assinaram).

## 8. Público-Alvo e "Programa Familiar"
* **Faixa etária ("Target Audience"):** Marque apenas `[X] 13 a 15` / `[X] 16 a 17` / `[X] De 18 anos ou mais`.
* **Crianças abaixo de 13 anos:** NÃO marque idades inferiores a 13.
* **Apelo Direcionado a Crianças?** O Google perguntará "As imagens ou o design do seu app focam primariamente em atrair a atenção de crianças menores (ex: desenhos fofos, mascotes de brinquedo)?". Marque **NÃO**.

***

## ✅ CHECKLIST FINAL DE ENVIO (Para você confirmar):

- [ ] Criei a conta de teste (`googleplay@appicompany.com`) no meu servidor.
- [ ] Copiei o Nome completo e a Descrição redigidos acima pro Console.
- [ ] Subi um ícone .PNG 512x512 lá no campo gráfico (não o favicon, o grandão).
- [ ] Subi um banner .JPG/PNG 1024x500 como Feature Graphic.
- [ ] Subi meus prints de celular e tablet.
- [ ] Respondi as respostas "Chatas" (Anúncios = Não, Notícias = Não, Covid = Não).
- [ ] Colei os links públicos dos nossos relatórios de Privacidade e Exclusão.
- [ ] Terminei as regras de Data Safety listadas acima.
- [ ] Feito upload do arquivo `.aab`. (Review and Rollout!).
