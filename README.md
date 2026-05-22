======================================================================
NOMOS FINANCE - DOCUMENTAÇÃO DE DEPENDÊNCIAS E INSTALAÇÃO
======================================================================

Este ficheiro contém todas as instruções e a lista de dependências externas
necessárias para configurar e executar o projeto Nomos Finance em qualquer
computador de desenvolvimento.

----------------------------------------------------------------------
1. COMO EXECUTAR O PROJETO LOCALMENTE
----------------------------------------------------------------------

Passo 1: Clonar o repositório do GitHub
Abra o terminal/prompt de comando e execute:
   git clone https://github.com/SEU_USUARIO/nomosfinance.git

Passo 2: Entrar na pasta do projeto
   cd nomosfinance

Passo 3: Instalar todas as dependências externas automaticamente
O Flutter lerá o arquivo 'pubspec.yaml' e baixará os pacotes corretos:
   flutter pub get

Passo 4: Executar o aplicativo
   flutter run


----------------------------------------------------------------------
2. PRINCIPAIS DEPENDÊNCIAS EXTERNAS (PACOTES)
----------------------------------------------------------------------

Estas são as bibliotecas externas adicionadas ao projeto através do 'pubspec.yaml':

* http
  - Propósito: Comunicação HTTP/REST com o backend construído em Laravel.
  - Link: https://pub.dev/packages/http

* image_picker
  - Propósito: Permite capturar fotos com a câmera ou selecionar imagens da galeria do dispositivo para os comprovantes.
  - Link: https://pub.dev/packages/image_picker

* table_calendar
  - Propósito: Fornece o widget de calendário interativo para visualização de anotações e lançamentos diários.
  - Link: https://pub.dev/packages/table_calendar

* flutter_local_notifications
  - Propósito: Controla e exibe notificações nativas do sistema operacional no dispositivo móvel (Android e iOS).
  - Link: https://pub.dev/packages/flutter_local_notifications

* reorderable_grid_view
  - Propósito: Implementa o comportamento de arrastar e soltar (drag-and-drop) na grade 2D de comprovantes.
  - Link: https://pub.dev/packages/reorderable_grid_view


----------------------------------------------------------------------
3. NOTAS IMPORTANTES PARA AMBIENTE WINDOWS (DESKTOP DEVELOPMENT)
----------------------------------------------------------------------

Se estiver compilando o aplicativo nativamente para Windows (Desktop),
é obrigatório instalar a biblioteca nativa C++ ATL através do 
Visual Studio Installer. Caso contrário, o pacote de notificações
locais falhará na compilação do plugin cpp.

Componente a marcar no Visual Studio Installer:
-> "C++ ATL para ferramentas de build v143 mais recentes (x86 e x64)"

Após a instalação do componente C++, limbre-se de rodar no terminal:
   flutter clean
   flutter pub get

======================================================================