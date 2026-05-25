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

# Como instalar o firestore

https://console.firebase.google.com/

Faça login e crie um novo projeto. Após isso, instale o firebase CLI no computador:

    - npm install -g firebase-tools

Uma alternativa se tiver WSL ou git bash:

    - curl -sL https://firebase.tools | bash

Após instalado, execute:
    - firebase login
    - dart pub global activate flutterfire_cli
    - flutterfire configure --project=nome-do-projeto

Siga as instruções dos comandos, e após isso o projeto estará sincronizado com o firestore na cloud.

# Como firestore funciona

Firestore é um backend as a service, você cria um projeto no site, conecta a aplicação a ele e pronto.
A unica coisa a ser configurada do backend são as regras de read/write.

Pra acessar o projeto ativo no site do firestore:

https://console.firebase.google.com/

- Faça login
- Acesse seu projeto
- Procure por "Project Shortcuts", onde terá "Firestore"
- Nele você pode configurar as collections existentes, as regras de read/write, entre outras coisas.
- Um detalhe importante: não é necessário criar as collections diretamente via site, é só criar no aplicativo,
e quando a aplicação acessar o backend via api a collection será criada.

# ATENÇÃO

- O firestore ja está em modo produção. Ou seja: por padrão ele não permite nenhum read/write:
    allow read, write: if false;

- A regra foi alterada para:
    allow read, write: if true;

- Para testar a aplicação não tem problema, mas jamais coloque isso em produção. Mude para alguma regra de autenticação. Exemplo:
    allow read, write: if request.auth.uid == resource.data.usuarioId;

# Como rodar o projeto

- Comando:

    1º Forma: Para debugar via navegador:
        flutter run -d web-server

    2º Forma: Ative o modo desenvolvedor no celular, e ative a depuração por wifi, e então execute:
        adb connect ip_do_celular
        flutter run

    3º Forma: Usando o emulador do android studio:
        Vá em Tools > Device Manager, crie um dispositivo virtual (AVD) e inicie o emulador.
        Após isso, encontre e execute o app com:
        flutter devices
        flutter run

# Detalhes sobre execução em modo debug e versão de release no celular

- Versão release e debug:
    Ao executar flutter run, estamos executando um app em modo debug. 
    Inicialmente é possível instalar a versão de release, pois o flutter configura o app pra usar a mesma chave de instalação do modo debug
    pra assinar o modo release, no arquivo android/app/build.gradle.kts:

        buildTypes {
            release {
                signingConfig = signingConfigs.getByName("debug")
            }

    Mas essa chave não deve ser usada pra lançar um app em produção na playstore. Para criar uma chave pra assinar o app execute:

    keytool -genkey -v -keystore nome-arquivo.jks -keyalg RSA -keysize 2048 -validity 10000 -alias alias-da-chave

    Esse comando cria um arquivo .jks que contém uma chave RSA de 2048 bits, válida por ~27 anos, com um nome interno (alias), usada para assinar seu app Android. 
    Esse arquivo NÃO DEVE ser enviado para o repositório.
    Podem existir varias chaves no mesmo arquivo, por isso o alias no final do comando.

    Mova-o para android/app/ e no arquivo do gitignore inclua:
        key.properties
        **/*.keystore
        **/*.jks

    Para usar a chave na hora de buildar o app, vá em android/app/build.gradle.kts e insira o seguinte trecho:

        signingConfigs {
            create("release") {
                if (keystorePropertiesFile.exists()) {
                    keyAlias = keystoreProperties["keyAlias"] as String
                    keyPassword = keystoreProperties["keyPassword"] as String
                    storeFile = file(keystoreProperties["storeFile"] as String)
                    storePassword = keystoreProperties["storePassword"] as String
                }
            }
        }

        buildTypes {
            getByName("release") {
                signingConfig = signingConfigs.getByName("release")
                resValue("string", "app_name", "Nome do seu app aqui")
            }

            getByName("debug") {
                applicationIdSuffix = ".debug"
                resValue("string", "app_name", "Nome do seu app Debug")
            }
        }

- Instalando versão de release e debug ao mesmo tempo:
    No celular normalmente só se pode instalar uma versão do app: release ou debug.
    Pra permitir instalação de ambas ao mesmo tempo, vá em android/app/build.gradle.kts e insira o seguinte trecho:

        buildTypes {
            release {
                signingConfig = signingConfigs.getByName("debug")
            }

           debug {
                applicationIdSuffix = ".debug"
            }
        }

- ATENÇÃO:
    No caso de um app com database local, não vai existir conflito algum, mas no caso do firestore (que é um backend online)
    é necessário criar dois Firebase Projects separados, um destinado ao dev/debug e outro para produção. Ao usar somente um,
    as alterações em modo debug IRÃO afetar o app em produção.

    📌 Isso é recomendado pela própria Firebase para evitar mistura de dados

# Como inserir método de sign in no firestore

https://console.firebase.google.com/

No menu lateral esquerdo
Security -> authentication -> get started -> escolha um método de sign in
