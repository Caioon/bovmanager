# 1. Para executar os testes unitários:
flutter test

# 2. Para executar os testes de integração (repository + firbase emulator)

# 2.1 Inicia o Firebase Emulator (deixa rodando)
firebase emulators:start

# 2.2 Em outro terminal, inicia o Android emulador (se não estiver aberto)
flutter emulators --launch <emulator_id>

caso não saiba o emulador ou id, verifique com:

flutter doctor
flutter devices

# 2.3 Roda o teste

flutter test integration_test -d <emulator_id>


# Testes unitarios
Executam rápido, cerca de 1 minuto finaliza todos os testes.
Ao longo dos testes da tela de mapa, aparecem varias ClientExceptions do openstreetmap, por conta de que o teste não tem um user-agent definido.
Isso nao interfere nos testes, apenas joga logs no output do terminal.
Tentei omitir esses logs com arquivo de configuração do teste, mas não funcionou.

# Testes de integração
O primeiro flutter test demora ~40s pelo build do Gradle. As execuções seguintes são bem mais rápidas.
Os testes de integração são longos, quando testei demorou 5 minutos aproximadamente para finalizar todos os testes.

# Detalhe importante: configuração de tráfego de rede para testes com Firebase Emulator

A partir do Android API 28, o sistema operacional bloqueia requisições HTTP sem criptografia por padrão. 
Como os emuladores do Firebase se comunicam via HTTP puro na porta local, é necessário criar uma exceção explícita para o 
host 10.0.2.2 (endereço que o emulador Android usa para acessar o localhost da máquina host).

Isso é feito em dois passos: criando o arquivo android/app/src/main/res/xml/network_security_config.xml, que declara 10.0.2.2 
como domínio com tráfego HTTP permitido, e referenciando esse arquivo no AndroidManifest.xml via android:networkSecurityConfig. 
A configuração é cirúrgica — afeta apenas esse endereço, sem relaxar as restrições de segurança para o restante do tráfego do app.
