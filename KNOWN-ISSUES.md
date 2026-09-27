# Problemas conhecidos

A **Version 1** ainda é para testes. Uma jogatina completa ainda não foi
validada, e os testes de compatibilidade cobrem uma única combinação de Windows/Cemu/VDXR.

As modificações locais (feitas por **MCassador**, veja o resumo no README.md e o detalhe
em INSTALL.md) já corrigiram vários problemas que apareciam durante os testes — o
travamento do jogo depois de alguns minutos, os passos de jogo perdidos em câmera lenta,
o giro da câmera do diorama que travava de um lado, a luva errada aparecendo na Peach, o
tamanho das mãos, entre outros. O que segue é o que ainda falta ou não foi confirmado.

## Iluminação e sombras

- **Luz de lâmpada aparecendo em um olho só (corrigido e confirmado no headset).** A função que
  prepara a iluminação de cada vista (0x022D76EC) ainda lia, num 4º ponto (0x022D78FC), a câmera
  única do jogo em vez da câmera do olho — os outros 3 pontos já tinham sido trocados pelo autor
  original. A luz das lâmpadas na parede caía no lugar certo num olho e errado no outro.
- A iluminação ainda pode variar entre os dois olhos em outros casos, mais visível em fases
  pequenas e fechadas.
- Sombras podem aparecer fora do lugar ou com perspectiva errada.
- **Brilho especular estourado (branco) em superfícies reflexivas (gelo/água), em investigação.**
  Confirmado que não é o pacote de Resolução (persiste em resoluções mais baixas) nem o cache de
  iluminação entre os olhos que o `mrLppNoCache` já corrige (rastreado e confirmado que esse
  caminho já força o recálculo certo). Pelo visto é o próprio termo especular do shader do jogo,
  que soma brilho em cima da cor difusa e pode passar de branco puro num ângulo de câmera que a
  câmera original (fixa) nunca alcançava, mas a cabeça em VR alcança. Fiz um pacote gráfico
  **experimental**, `graphicPacks\Mario3DWorld_ReduceShine`, que reduz a intensidade desse termo
  num shader específico (achado despejando os shaders do Cemu - Depuração > Despejar > Shaders -
  no exato momento em que o brilho apareceu). Já instalado nos pacotes gráficos do Cemu; ative-o
  em Opções > Pacotes gráficos (pode precisar reiniciar o Cemu para aparecer na lista) e escolha
  um preset (35% de brilho é o padrão; há opções de 60%, 15%, 0% e "sem alteração" para comparar).
  Não confirmado ainda se é exatamente esse shader que causa o brilho visto no gelo - só sabemos
  que ele compilou bem na hora certa. Se não mudar nada visível, me avise para tentarmos outro dos
  shaders despejados no mesmo instante.

## Renderização e desempenho

- Geometria fora da visão de câmera original pode faltar, ficar exposta ou visivelmente
  incompleta. Alguns efeitos, partículas e transições de visibilidade podem parecer
  errados.
- O plano de corte próximo (near clip) mais fechado em primeira pessoa é uma solução de
  compromisso. As passadas de leitura de profundidade do próprio jogo trabalham a partir
  do plano original, então a profundidade delas fica um pouco errada.
- O enquadramento de cinemáticas tem pouco teste, principalmente no modo diorama.
- Taxas de renderização mais altas não interpolam a animação entre as atualizações de
  60 Hz do jogo. Os presets de 90 e 144 FPS continuam experimentais.
- Morte, reaparecimento e transições de cena ainda podem causar instabilidade a 120 FPS.
  Se ocorrer uma queda (crash), tente o preset de referência de 60 FPS e relate o local e
  os passos que causaram o problema.

## Controles

- **A luva podia virar sozinha durante o jogo (corrigido).** O gesto de calibração (segurar o
  grip + clicar o analógico) avançava a predefinição de giro com um único instante de
  coincidência, e o grip e o clique do analógico são botões que a mesma mão já usa para
  segurar o controle e para andar - então bastava um toque acidental para desviar a
  orientação aos poucos, sem nenhum aviso, até a luva parecer "virada para trás". Foi visto
  numa sessão real (as duas mãos do Mario desviaram +2 predefinições cada uma em poucos
  minutos de jogo normal). Agora é preciso segurar o gesto de propósito por cerca de um
  terço de segundo (veja `mtHandCtl`+80 em INSTALL.md) para ele valer. Se sua luva já estiver
  desviada, apague `hand-presets.txt` (ou edite para os valores corretos: Mario esquerda 11 /
  direita 8, Peach esquerda 2 / direita 2) e reinicie pelo `Start-VR`.
- A tela de toque do GamePad não tem equivalente num controle VR e não pode ser alcançada
  por um. O microfone pode ser simulado: levar a mão esquerda perto da boca para "soprar"
  (veja `mtMic` em INSTALL.md; ainda não testado numa fase do Capitão Toad), ou escolher o
  microfone do headset como entrada de áudio do Cemu.
- A bola de fogo sai da luva direita e voa na direção que o controle direito aponta (veja
  INSTALL.md). Havia um relato de que ela saía deslocada da mão da Peach; a causa
  encontrada foi que a bola nascia na origem da luva (o pulso), que fica atrás e ao lado
  da palma — agora ela nasce no meio da palma. Ainda não confirmado em jogo. O launcher
  agora mostra uma linha `Fireball:` ao fim de cada sessão com o que o jogo pediu e o que
  a modificação respondeu (também salva em `session-logs\<hora>-diag.txt`), e o mesmo para
  `Blow:` (o gesto de soprar).
- O controle emulado 1 precisa ser um Wii U GamePad. Com um perfil de Pro Controller ou de
  Wii Remote o jogo lê a entrada por um caminho diferente, que os controles VR não alcançam.
- Em controles Oculus Touch o botão de menu existe só no controle esquerdo, então o Plus
  vem de lá.

## Primeira pessoa

- Elementos do HUD ficam ancorados na sala e podem sair do campo de visão ao girar a cabeça.
- A introdução e o mapa do mundo usam a visão diorama. Um modo de primeira pessoa
  selecionado volta a valer nas cenas de jogo com suporte.
- Câmeras fixas e cinemáticas podem produzir enquadramentos estranhos.

## Compatibilidade

Só foram validados o Cemu 2.6, a base europeia v0 do jogo e o Virtual Desktop/VDXR.
Outras versões de jogo, do emulador, outros runtimes e outro hardware podem se comportar
de forma diferente.

## Relatando um problema

Inclua o modo, a fase, a versão do jogo, a versão do Cemu, a GPU, o runtime OpenXR, o
preset de FPS e os passos para reproduzir o problema. Screenshots ou uma gravação curta
ajudam a explicar problemas de câmera e renderização. Remova caminhos pessoais ou
informações de conta antes de compartilhar logs. Não anexe arquivos do jogo nem chaves.

## Encontrado numa revisão local de código (corrigido na fonte, recompilado; ainda não testado no headset)

Estes quatro problemas estavam em `cemuvr_layer.dll` e foram confirmados lendo o
código-fonte da camada (`core/src/cemu_layer.cpp` e
`xr_core.cpp`. As ferramentas de build (Visual Studio Build Tools com C++, CMake, o SDK
Vulkan e o SDK OpenXR, compilado localmente como biblioteca estática) foram instaladas e
os quatro foram corrigidos diretamente no `.cpp` e recompilados - não são mais remendos no
binário. **A camada em `layer\cemuvr_layer.dll` já é essa versão recompilada, mas nenhuma
delas foi confirmada dentro do headset ainda**; teste e relate qualquer comportamento
estranho (veja "Relatando um problema" acima).

- **O rastreamento de cabeça parava depois de cerca de 9 minutos no preset de 120 FPS.**
  `publishReferencePose` se recusava a publicar quando `sequence >= 131070` (65.535
  pacotes de pose) e registrava `token_limit_restart_required=1`. Publica uma vez por par
  estéreo, então eram cerca de 9 minutos a 120 FPS, 12 a 90, 18 a 60; o jogo (guest)
  mantinha a última pose e só reiniciar o Cemu resolvia. O limite existia porque o lado do
  jogo só carrega um token de 16 bits; reaproveitar tokens é seguro porque o histórico
  circular guarda só os 2048 mais novos. **Correção:** em vez de parar de vez, o contador
  agora volta a 0 nesse ponto (`sequence = 0`) e continua publicando normalmente; um aviso
  `token_wrapped=1 count=N` fica no log a cada volta, só para acompanhar. (Uma versão
  anterior desta correção só remendava 4 bytes do binário compilado, sem tocar a fonte;
  esta veio do `.cpp` recompilado e a substitui.)
- **Uma falha passageira de cópia ou timeout de mutex desligava o VR pelo resto do
  processo.** `pairs.failed`, uma vez ligado por qualquer falha assim, nunca voltava a
  `false` - só `g.failed` era resetado quando o swapchain da TV era destruído (redimensionar
  a janela, tela cheia, trocar o vsync). Depois disso, toda apresentação ia direto para o
  Cemu sem passar pelo transporte estéreo, para sempre. **Correção:** esse mesmo momento de
  reset agora também limpa `referencePairImages` e `referenceHud` (e libera as imagens de
  GPU deles antes), então uma falha passageira não desativa mais o VR de vez.
- **A interoperação do HUD não era desmontada quando o swapchain da TV era recriado.** O
  reset acima destrói `g.interop` e reinicia `g.xr` (o que, por baixo, recria o dispositivo
  D3D11), mas `dd->hudInterop` não era tocado, e ficava com a textura e o tamanho de antes
  do redimensionamento - presos a um dispositivo D3D11 que estava para deixar de existir.
  **Correção:** o mesmo reset agora também desmonta e limpa `dd->hudInterop`, então ele é
  recriado do zero no tamanho e no dispositivo novos na próxima vez que o HUD for copiado.
- **Esperas sem limite na thread de renderização.** `xrWaitSwapchainImage` usava
  `XR_INFINITE_DURATION`, e `presentReferencePair` segura `g_mtx` (um lock global) enquanto
  espera. Se o runtime parasse de liberar imagens (queda de stream, headset dormindo), a
  thread de renderização do Cemu - e qualquer outra thread esperando o mesmo lock -
  travava para sempre. **Correção:** as duas esperas agora têm um limite de 2 segundos; ao
  vencer o prazo, o código já tratava isso como uma falha normal (descarta aquele quadro do
  HUD ou daquele olho e segue), então nada mudou no caminho de sucesso.
