# Bov Manager

Aplicativo de gerenciamento de gado.
Devs: 
    - Caio Augusto Dürks
    - Matheus Iori Facina

# Bibliotecas
firebase_core – inicialização e integração com os serviços do Firebase.

firebase_auth – autenticação de usuários.

cloud_firestore – armazenamento e consulta de dados na nuvem.

flutter_riverpod – gerenciamento de estado reativo e injeção de dependências da aplicação.

riverpod_annotation / riverpod_generator – geração automática de código para providers e simplificação da arquitetura utilizando Riverpod.

shared_preferences – armazenamento local de configurações e preferências do usuário.

flutter_local_notifications – envio de notificações locais para lembrar o usuário sobre tarefas próximas.

fl_chart – geração de gráficos estatísticos, como evolução de peso e distribuição por raça.

image_picker – seleção e registro de fotos dos animais utilizando câmera ou galeria do dispositivo.

flutter_svg – renderização de imagens vetoriais SVG utilizadas na interface do sistema.

share_plus – compartilhamento e exportação de relatórios e documentos gerados pela aplicação.

intl / flutter_localizations – formatação de datas, internacionalização e localização da interface da aplicação.

package_info_plus – obtenção de informações da aplicação, como versão instalada e dados do pacote.

flutter_lints / riverpod_lint – padronização e análise estática do código-fonte, auxiliando na manutenção da qualidade do projeto.

build_runner – execução de processos de geração automática de código durante o desenvolvimento.


# Arquitetura geral do projeto

O projeto utiliza a arquitetura MVVM (Model-View-ViewModel) para separar responsabilidades entre interface, estado e lógica da aplicação. 

Os Models representam os dados, enquanto os ViewModels gerenciam estado, fluxo da UI e tratamento de erros. 

A camada Repository abstrai o acesso ao Firebase/Firestore, facilitando testes e desacoplamento da infraestrutura. 

Services centralizam regras de negócio e orquestram operações entre ViewModels e Repositories. 

O Riverpod 3.0 é utilizado para gerenciamento de estado e injeção de dependências através de Providers reativos e tipados.

# Como rodar o projeto

- Comando:

    1º Forma: Para debugar via navegador:
      - flutter run -d web-server

    2º Forma: Ative o modo desenvolvedor no celular, e ative a depuração por wifi, e então execute:
      - adb connect ip_do_celular
      - flutter run

    3º Forma: Usando o emulador do android studio:
        Vá em Tools > Device Manager, crie um dispositivo virtual (AVD) e inicie o emulador.
        Após isso, encontre e execute o app com:
      - flutter devices
      - flutter run
