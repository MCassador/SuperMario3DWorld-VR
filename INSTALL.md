# Instalação

## Antes de começar

- Configure o Cemu 2.6 e confirme que sua base europeia de Super Mario 3D World
  v0 roda normalmente com um gamepad.
- Escolha um runtime OpenXR para o seu headset. O runtime testado é o Virtual
  Desktop/VDXR.
- Para o preset padrão de 120 FPS, use uma taxa de atualização de headset de 120 Hz.
- Feche o Cemu antes de iniciar uma sessão VR.

## Instalar a Alpha 1.2

1. Extraia `SuperMario3DWorld-VR-Alpha-1.2-install.zip`.
2. Copie a pasta **`Mario3DWorld-VR`** para dentro da sua pasta do Cemu, ao lado do `Cemu.exe`.
3. Abra essa pasta e rode **`Start-VR.cmd`**. O jogo inicia no modo diorama.
4. Abra o jogo pela lista de jogos do Cemu.
5. Deixe a janela do launcher aberta. Feche o Cemu normalmente para encerrar a sessão.

Se o launcher não encontrar o Cemu, ele pede para você selecionar o `Cemu.exe` uma vez.
O ZIP de instalação já inclui a camada VR pronta; não é preciso compilar nada.

## Gráficos e taxa de quadros

O launcher ativa o Vulkan, o modo VR escolhido e o pacote de FPS. Ele usa sua
configuração e saves já existentes do Cemu; não cria um perfil de jogo separado.

Para uma imagem mais nítida, ative o pacote gráfico de resolução da comunidade no Cemu e
selecione **3840×2160**, se sua GPU aguentar. Esse pacote não vem incluído aqui.

O preset inicial de FPS é **120 FPS (jogo a 60 Hz)**. Para mudar, selecione outro
preset nas configurações de pacotes gráficos do Cemu durante uma sessão. Feche o
Cemu normalmente; o launcher lembra a escolha para o próximo início.
Os presets disponíveis são 60, 90, 120 e 144 FPS. Comece com 60 se o 120 estiver instável.

**Correção local - passos de jogo perdidos:** o pacote de FPS aplicava no máximo um passo de
jogo por quadro renderizado e descartava qualquer tempo sobrando quando os quadros eram
desiguais. A cerca de 70 quadros por segundo isso custava 8 dos 60 passos por segundo (medido:
52 de 60 - tudo em câmera lenta, inclusive os pulos). Agora ele guarda até um passo do tempo
sobrando e o paga de volta no quadro seguinte, então com a taxa de quadros acima de 60 o jogo
volta a rodar a 60 passos por segundo (numa simulação com tempos de quadro tipicamente
desiguais: 56 → 59,6). Abaixo de 60 quadros por segundo o jogo continua mais lento que o normal
- diminua o pacote gráfico de Resolução para isso.

## Controles

Os controles VR agem como o GamePad.

**Menu de opções VR:** aperte **B + Y juntos** para abrir (ou fechar) um menu na sua frente.
Enquanto ele está aberto o jogo não recebe os botões nem os analógicos (o Mario fica parado).
Analógico para cima/baixo escolhe a opção; **A** muda o valor (X volta um); B ou B + Y fecha.
No rodapé: "Feito por: MCassador". Opções: corpo na 1ª pessoa (a cabeça fica sempre
escondida), corpo gira com a visão, braços (do jogo ou
até as luvas), corpo acompanha a câmera, altura dos olhos, giro com o analógico (suave, 30°,
45°, 55°, 60°, 90°), afastamento máximo na 1ª pessoa, distância da câmera atrás, tamanho das
luvas e luvas VR ligadas/desligadas. Cada mudança vale na hora e fica salva em
`layer\vr-menu.ini` (só o que foi mudado pelo menu; apague o arquivo para voltar ao padrão do
patch). A distância da câmera atrás é guardada pelo launcher, como antes. O menu é desenhado
pela `cemuvr_layer.dll` e acha os ajustes do patch pela tabela `mtMenuTable` (marca `MVRM`).

- mão esquerda: X corre, Y arremessa, o gatilho é ZL, o grip é L, o botão de
  menu é Plus, o clique do analógico é Minus
- mão direita: A pula, B corre, o gatilho é B, o grip é R
- analógico esquerdo move, analógico direito olha
- segure o controle esquerdo perto da sua cabeça: enquanto ele estiver lá, o
  analógico direito age como a cruzeta (D-pad) e para de girar a visão, e um
  pulso curto nesse controle confirma o gesto

**Mudança local - giro em passos (snap turning):** em primeira pessoa o analógico direito
gira a visão em passos de 55 graus em vez de suavemente. Empurre para um lado para girar um
passo, depois deixe voltar ao centro antes do próximo. Para mudar o tamanho do passo ou
voltar ao giro suave, edite `mrSnapSin` / `mrSnapCos` em
`graphicPacks/Mario3DWorld_VR/patch_vr.asm` (os valores estão listados ao lado; um
seno de 0 significa giro suave). O original sem alteração está em `backup-original/`.

**Mudanças locais - experimentos em `patch_vr.asm`** (cada uma é um número; edite e
reinicie a sessão; `backup-snapturn/` guarda a versão anterior a cada uma). Estas são as
modificações feitas por **MCassador**:

- `mrLppNoCache` - `1` (agora) faz a pré-passada de luz do jogo redesenhar seu buffer de
  luz para cada olho em vez de reaproveitar um já calculado. É esse cache que deixa fases
  de câmera fixa iluminadas com um buffer feito para outro olho ou outra pose de cabeça;
  `0` é o comportamento original.
- `rrShadowBothEyes` - `1` faz o segundo olho desenhar seu próprio mapa de sombra, `0`
  (agora) reaproveita o do primeiro olho como o original fazia. `1` fazia o jogo fechar
  cerca de dez segundos depois de iniciar, mesmo com o pacote de Resolução de Sombra no
  padrão dele, então fica desligado. O `Start-VR.cmd` ainda roda a sessão com esse
  pacote no preset padrão dele e devolve sua escolha depois (defina a variável de
  ambiente `VR_KEEP_SHADOW_PRESET=1` para não mexer no pacote).
- Pacote Contrasty - ele substitui o shader final de composição do jogo por uma
  correção de cor, e o Cemu usa o shader do primeiro pacote que combinar, então ele
  também substitui a versão desse shader do pacote de Resolução. Os presets "High
  Contrasty" e "Neutral Contrasty" clareiam a imagem (gama 1,1 / 1,075, exposição
  1,05 / 1,01). O `Start-VR.cmd` roda a sessão com o preset neutro "Default" dele e
  devolve sua escolha depois (`VR_KEEP_CONTRAST_PRESET=1` não mexe nisso). Para deixar
  mais escuro que o neutro, diminua `$exposure` e `$gamma` no preset "Default" do
  pacote; o rules.txt dele diz que esse preset pode ser editado.
- `mtEyeBack` - o quanto a câmera de primeira pessoa fica atrás da cabeça, em unidades de
  jogo (float; 0 ao iniciar = nos olhos, a primeira pessoa original; o ciclo do R3 abaixo
  muda isso).
- `mtZoom` - no passo de câmera-atrás-do-Mario (200), o **analógico direito para
  trás/frente** move a câmera: puxado para trás ela vai mais para trás (campo de visão
  maior), empurrado para frente ela se aproxima. O lado esquerda/direita do mesmo
  analógico continua girando a visão em passos. Palavras de `mtZoom`: 0 o interruptor
  (1 = ligado), 4 (float) quanto por leitura do controle num empurrão total (1,5 unidades
  de jogo; 150 unidades são 1 m), 8 e 12 (floats) a distância mínima e máxima (80 e 600),
  16 (float) a zona morta (0,25). A distância escolhida fica lembrada: trocar para a primeira pessoa ou o diorama e voltar ao passo 200 volta nela, e o `Start-VR` a devolve na próxima sessão (arquivo `camera-distance.txt` ao lado dele; apague-o para voltar aos 200).
  Na primeira pessoa original o mesmo analógico **recua a visão** sem sair da primeira pessoa:
  o Mario continua invisível, as luvas continuam nas suas mãos e a bola de fogo sai da luva;
  empurrar pra frente até o fim volta exatamente para os olhos. O máximo é `mtFpBackMax`
  (float, padrão 150 = cerca de 1 m; 0 desliga) e o valor fica lembrado entre sessões no
  arquivo `fp-distance.txt` (apague para voltar aos olhos).
  A distância não acompanha a inclinação da sua visão (olhar para cima costumava jogar a
  câmera para baixo, em direção ao chão): ela vai reto para trás, nivelada, e a parte além
  de 200 também sobe. Na distância 0 (a primeira pessoa original) nada muda.
  `mtLift` define isso: palavra 0 (float) a distância básica, 200; palavra 4 (float) o
  quanto a câmera sobe por unidade de distância extra, 0,5 (`0x3F000000`); 0 mantém nivelado,
  1,0 sobe tanto quanto vai para trás.
- `mtEyeBackLock` - `1` (agora) mantém a câmera centralizada no Mario sempre que ela fica
  atrás da cabeça: ignora o quanto sua cabeça se afastou do ponto de recentralização e
  mantém só o deslocamento próprio de cada olho, então o estéreo não muda. `0` deixa o
  movimento da cabeça deslocar a câmera como antes.
- `mtEyeBackCtl` - as distâncias de câmera (0, 200; o passo intermediário de 160 foi
  removido). O botão de troca de câmera (R3 / clique do analógico direito) percorre elas:
  diorama → primeira pessoa como no mod original (câmera nos olhos, corpo escondido) → 200
  (corpo mostrado) → diorama. Trocar de distância não reseta o giro nem recentraliza a
  cabeça. O primeiro número é um botão extra opcional que só troca a distância (0 =
  desligado; 4 = Minus).
- `mtHandCtl` - as mãos na primeira pessoa original (o primeiro passo do ciclo do R3). O
  primeiro número é o interruptor: `1` (agora) mostra os dois modelos de luva do próprio
  personagem na posição e giro dos controles, e esconde o resto do corpo; `0` é a
  primeira pessoa original pura. Só um controle rastreado mostra uma luva. As luvas
  seguem a animação do próprio jogo para os dedos e para qualquer coisa segurada. No
  passo 200 são usados o corpo e as mãos normais.
  As duas partes da luva são encontradas pelas juntas delas, não pela posição na lista de
  partes do jogo, então isso funciona para todo personagem: Peach e Rosalina listam a
  saia primeiro (que antes aparecia como um anel rosa grande no controle esquerdo), e o
  traje de bumerangue da Peach lista olhos, rosto e cabelo antes das mãos.
  Calibração de orientação: o giro das luvas é um entre 24 predefinições. Uma luva que
  parece virada para trás (dedos para você, o punho para longe) está com a predefinição
  errada. Segure (não só toque) o **grip esquerdo e o clique do analógico esquerdo** (L +
  Minus) por cerca de um terço de segundo para avançar a luva esquerda pelas predefinições,
  e o **grip direito e o clique do analógico esquerdo** (R + Minus), do mesmo jeito, para a
  luva direita, até cada luva apontar do jeito certo. É preciso segurar de propósito - um
  toque rápido ou uma coincidência de um instante só (o grip e o clique do analógico são
  botões que a própria mão já usa para segurar o controle e para andar) não avança mais
  nada; solte e segure de novo para avançar outra predefinição. (Antes um único instante já
  bastava, e isso podia avançar a predefinição sem querer durante o jogo normal - foi assim
  que a luva do Mario apareceu virada, sem nenhum aviso, numa sessão.) Cada acerto do tempo
  de segurar avança uma predefinição (dá a volta depois de 23); o tempo de segurar é a
  palavra no offset 80 de `mtHandCtl` (inteiro, padrão 20 quadros de jogo seguidos, cerca
  de um terço de segundo a 60 leituras por segundo). Existem dois
  conjuntos, um para Mario, Luigi e Toad e outro para Peach e Rosalina (os acordes de botão
  trocam o conjunto do personagem que você está jogando), e cada mão tem seu próprio
  número. As
  predefinições em que você parar são salvas enquanto o jogo roda e devolvidas na próxima
  vez que você iniciar pelo `Start-VR` (arquivo `hand-presets.txt` ao lado dele; apague-o
  para voltar aos padrões: conjunto do Mario esquerda 11 e direita 8, calculados a partir
  dos modelos de luva - dedos para frente, polegar para cima, palma virada para dentro;
  conjunto da Peach 2 e 2, palma para baixo, porque as mãos dela são abertas e chatas e
  pareciam lâminas finas de perfil com o polegar para cima. Só as predefinições que você
  mudar durante uma sessão são salvas). Coloque o número no offset 32 de `mtHandCtl` em
  `0` para desligar os dois acordes.
- Luvas, deslocamento para a frente: a palavra no offset 44 de `mtHandCtl` é um float, o
  quanto as luvas ficam à frente na direção que o controle aponta, em unidades de jogo
  (cerca de 150 unidades são 1 m, então o padrão 20, `0x41A00000`, é cerca de 13 cm).
  `0x41F00000` = 30, `0x41700000` = 15, `0x41200000` = 10 (o padrão anterior), 0 = nenhum.
- Luvas, predição: uma luva é desenhada a partir de uma amostra do controle já um pouco
  velha, então ela fica atrasada numa mão rápida. A palavra no offset 48 de `mtHandCtl`
  (float, padrão 1,5 = `0x3FC00000`) move a mão à frente por essa quantidade de quadros do
  próprio movimento dela; 0 desliga, 1,0 = `0x3F800000`, 0,75 = `0x3F400000` (o primeiro
  padrão), 2,0 = `0x40000000` prediz mais. A palavra no offset 52 (float, padrão 40000) é o
  movimento por quadro, ao quadrado, acima do qual a predição é descartada, para um salto
  de rastreamento não jogar a luva para longe. Isso vale só para a posição; a orientação é
  a rastreada.
- Bola de fogo, ponto de saída: com a flor de fogo a bola de fogo começa na luva direita
  (o jogo pede a posição da junta da mão direita do Mario; a modificação responde com a
  posição da luva). Isso acontece antes da própria checagem de parede do jogo, então a
  checagem funciona sobre a luva: uma luva empurrada contra uma parede à sua frente faz a
  bola nascer do seu lado da parede, não dentro dela. A palavra no offset 104 de `mtHandW`
  é o interruptor (1 = luva, 0 = original). A bola de fogo sai do meio da palma, não do
  pulso (a origem da luva, que fica ao lado e atrás da palma como você a vê): a palavra no
  offset 76 de `mtHandCtl` (float, padrão 13 = `0x41500000`) é a distância do pulso ao
  longo dos dedos, em unidades da luva; 0 volta para o pulso, um número maior move para a
  ponta dos dedos.
- Bola de fogo, direção: a bola de fogo voa na direção que o controle direito aponta, no
  mundo do jogo, então segue sua mira de verdade mesmo depois de o Mario ter virado, em
  vez da direção que o Mario está olhando. A palavra no offset 108 de `mtHandW` é o modo: 2
  (padrão) usa só a direção no plano do chão (uma mão baixa, alta, ou um braço relaxado não
  joga a bola no chão), 1 usa a direção inteira, incluindo para cima e para baixo, 0 é a
  direção que o Mario está olhando. No modo 2, uma mão apontando quase reto para cima ou
  para baixo mantém a direção do próprio jogo. O jogo ainda soma sua própria velocidade de
  queda, então a bola sai em arco, como no original. Só na primeira pessoa original com o
  controle direito rastreado.
- `mtSwing` - gesto de ataque, **só o controle direito** (o esquerdo é ignorado). O modo 2
  (padrão) é um arremesso tipo "lançar a linha de pescar": puxe a mão direita para perto
  da sua cabeça, depois jogue-a para a frente (para longe da cabeça) - isso pressiona o
  **X** do jogo por algumas leituras. X é o botão de corrida/ataque, o mesmo que o B do
  controle direito envia, então ele joga a bola de fogo com a flor de fogo e faz o
  arranhão com o traje de gato (o próprio acerto é o ataque do Mario, não a luva tocando o
  inimigo). Não é o B do próprio jogo, que é um segundo botão de pulo. O que importa é a
  distância entre a mão direita e a cabeça: acenar de lado ou para cima e para baixo com o
  braço esticado não faz nada, e o movimento para a frente só conta durante cerca de 0,75 s
  depois de um puxão para trás. Palavras de `mtSwing`: offset 0 o modo (0 desligado, 1
  qualquer movimento rápido da mão direita, 2 o arremesso), 4 (float) a velocidade ao
  quadrado que o modo 1 precisa, 8 quantas leituras o X fica pressionado (4), 12 quantas
  leituras antes do próximo ataque poder disparar (24), 44 (float) a velocidade ao quadrado
  em direção à cabeça que conta como puxão para trás (64 = 8 unidades por leitura), 48
  (float) a velocidade ao quadrado para longe da cabeça que conta como o arremesso (400 =
  20 unidades por leitura), 52 (float) a menor distância mão-cabeça ao quadrado que é
  considerada (22500 = 150 unidades) e 56 quantas leituras o puxão para trás continua
  válido (45). As velocidades são em unidades de posição do controle por leitura: cerca de
  1500 unidades são 1 m e o jogo lê o controle uma vez por quadro de jogo, então 20
  unidades por leitura é cerca de 1,2 m/s a 60 leituras por segundo (0,6 m/s a 120);
  diminua os dois números de velocidade se o arremesso estiver difícil demais de acionar,
  aumente se ele disparar sem querer.
- `mtCam` - até onde o analógico direito pode girar a câmera do jogo (diorama). O jogo gira
  sua câmera em passos de 45 graus entre um mínimo e um máximo (normalmente -45 e +45, mais
  apertado ou mais largo em alguns lugares), então a visão para de um lado. A palavra 0 é o
  interruptor (1 = usa os limites abaixo, 0 = os do próprio jogo), as palavras 4 e 8 o
  mínimo e o máximo horizontais em graus (floats; -180 e +180 = `0xC3340000` e `0x43340000`,
  meia volta para cada lado). Áreas onde o jogo desliga o giro de câmera por completo
  continuam como estão.
- Tamanho da luva: as palavras 56 e 60 de `mtHandCtl` (floats) escalam as luvas - 56 para
  Mario, Luigi e Toad (0,7, `0x3F333333`; era 0,55 no início, o que ficou pequeno demais),
  60 para Peach e Rosalina (1,3, `0x3FA66666`: o modelo de mão dela é cerca de 40% menor
  que o do Mario, então isso deixa os dois do mesmo tamanho). 1,0 é o tamanho original do
  jogo; números menores deixam as luvas menores. A modificação diferencia os dois grupos
  pela posição da luva na lista de partes do personagem.
- `mtCineDist` - o quanto a câmera do diorama fica mais atrás nas cutscenes (as cenas tipo
  filme: abertura, final, game over, as cenas de história). Uma cutscene é uma cena de fase
  cuja câmera não está seguindo o jogador. Dois floats, o fator de distância (padrão 0,80,
  `0x3F4CCCCD`) e o fator de avanço (0,20, `0x3E4CCCCD`); os dois somam 1, e a câmera normal
  do diorama é 0,65 / 0,35, então um primeiro número maior é mais longe. Coloque de volta
  0,65 e 0,35 para desligar isso. Cenas que acontecem dentro de uma fase com o jogador ainda
  no controle (o mastro na chegada, a introdução de um chefe) não são pegas e mantêm a
  distância normal.
- `mtMic` - soprar no microfone do GamePad (fases do Capitão Toad e os inimigos e objetos
  que reagem a som). Segure a **mão esquerda perto da sua boca** - perto do ponto entre seus
  olhos e não acima dele - por um instante: o jogo é avisado de que um sopro forte está
  acontecendo (suas três perguntas de microfone, "há um som", "quão alto" e a segunda
  marcação de som, são respondidas por você), não importa o que o microfone de verdade
  ouça. Palavras de `mtMic`: offset 0 o interruptor (1 = ligado, 0 = desligado), 8 (float) o
  volume relatado (3000; a escala do próprio jogo vai até cerca de 4096 e o limite de "som"
  dele é 550), 12 (float) o quão perto a mão precisa estar, ao quadrado (160000 = 400
  unidades, cerca de 27 cm; era 62500 = 17 cm no início, o que ficou apertado demais para
  uma mão de verdade na boca), 16 (float) o quanto acima do ponto da cabeça a mão pode estar
  (30 unidades), 56 qual controle sopra (16 = esquerdo, agora; 88 = direito), 24 e 28 quantas leituras ela precisa ficar ali (3) e o teto do contador (8,
  que também define por quanto tempo continua ligado depois que a mão sai). Ainda não
  testado numa fase do Capitão Toad. Como alternativa que não precisa do gesto: no Cemu, em
  Opções > Áudio > Dispositivo de entrada, escolha o microfone do headset (no Virtual
  Desktop chama-se "Microfone (Virtual Desktop Audio)") e sopre de verdade; o jogo então
  ouve pelo caminho normal dele.
- Contadores para o launcher: `mtFireStat` (bola de fogo) e o fim de `mtMic` (soprar)
  guardam alguns números que nada no jogo lê: quantas bolas de fogo foram criadas, quantas
  usaram a luva e a direção da mão, por que a última não usou, quantos quadros de atraso
  tinha a última atualização da luva, quantos quadros passaram entre apertar X e a bola
  aparecer, e quantas vezes o jogo perguntou sobre o microfone. O `Watch-Perf.ps1` lê isso a
  cada segundo e, quando o Cemu fecha, o `Start-VR.ps1` mostra (linhas começando com
  `Fireball:` e `Blow:`) e salva como `session-logs\<hora>-diag.txt`. Servem só para
  descobrir por que algo não funcionou.
- `mtHideMask` - quais partes do Mario ficam escondidas quando a câmera está atrás da
  cabeça. `0` (agora) desenha o corpo inteiro, `0xFFFFFFFF` esconde tudo como o original
  fazia. Cada bit esconde uma forma (bit 0 = primeira capturada, até 17).
- `mtFpBody` - corpo do jogador na primeira pessoa (olhando para baixo). Primeira palavra:
  cada bit desenha uma forma do modelo do corpo (bit 0 = primeira; Mario tem 5, Peach 6);
  `0xFFFFFFFF` (agora) desenha o corpo todo, `0` esconde como o original. Olhos, rosto e
  outras partes continuam escondidos; as luvas seguem os controles. Segunda palavra: o corpo
  só aparece enquanto o afastamento do analógico (`mtFpBack`) for no máximo esse valor
  (float; `0x44160000` = 600 = sempre, agora; `0x41200000` = 10 o corpo some ao afastar).
  Terceira palavra: `1` (agora) tira a cabeça do corpo (boné, cabelo, rosto), `0` desenha a
  cabeça. Quarta palavra: `1` (agora) o corpo gira junto com a visão quando você vira com o
  analógico direito (a direção "para frente" do espaço do VR, não o giro da sua cabeça),
  `0` o corpo fica virado para onde o jogo deixa. Quinta palavra: `1` (agora) cada braço
  (manga) vai do ombro até a luva do VR, esticando junto (no máximo 4x); se o controle não
  estiver rastreado, o braço encolhe para dentro do ombro; `0` desenha os braços do jogo. As
  partes que ficam penduradas no corpo (saia da Peach e da Rosalina, rabo das roupas) são
  desenhadas e giram junto com o corpo; rosto, olhos e cabelo continuam escondidos. Sexta palavra:
  largura da "tampa" achatada que sobra da cabeça em cima da gola (float; `0`, agora, encolhe
  a cabeça até um ponto; `0x3EB33333` = 0.35 deixa uma tampa). Sétima palavra: `1` (agora) o
  corpo fica embaixo da visão: afastando a câmera com o analógico (ou andando na sala) o corpo
  vai junto; `0` o corpo fica onde o jogo põe o Mario. A sombra do jogador (as "máscaras de
  sombra" elípticas e cilíndricas presas nas juntas) gira e anda junto com o corpo: ganchos
  `mtShEll` (`0x0245A8EC`) e `mtShCyl` (`0x0245A2E0`) trocam, só para as máscaras da categoria
  Jogador cujo dono é o personagem (ou uma parte capturada dele), a matriz entregue ao desenho
  por uma cópia virada/movida como o corpo; `mtShStat` conta quantas passaram. Tudo isso muda as matrizes dos ossos
  só para o desenho, no passo de matrizes do esqueleto (gancho `0x023DAD0C`, `mtHeadWrap`;
  a cabeça é o osso `Head`, 13 em todos os personagens); as matrizes voltam ao normal logo
  depois, então sombra, rosto e resto do jogo não mudam.
- `mtEyeFit` - altura dos olhos na primeira pessoa conforme o personagem: a altura do pescoço
  (osso `Head` menos a raiz) vezes o fator (`0x3FBA885D` = 145 / 99.5), indo aos poucos
  (`0.05` por passo), entre 50 e 250. Mario ~145, Luigi ~153, Peach/Rosalina ~175, Toad ~84,
  Mario pequeno ~76. Última palavra `0` = sempre 145 (o original).

O GamePad continua funcionando ao mesmo tempo, botão por botão. Não é preciso mapear
nada no Cemu para os controles - mas o controle emulado 1 precisa ser um
**Wii U GamePad**, porque é esse o caminho por onde os controles chegam.

## Trocando entre diorama e primeira pessoa

Clique o analógico do controle direito, ou **R3** no pad. O mesmo clique
reseta o giro da câmera e recentraliza a posição da cabeça. A introdução e o mapa do
mundo usam a visão diorama.

O botão do pad é selecionável nas configurações do Cemu para o pacote gráfico VR:
clique do analógico direito (o padrão), clique do analógico esquerdo, qualquer um dos
dois, ZL e ZR juntos, L e R juntos, ou Minus. Escolha outro se o clique do analógico não
estiver mapeado nas suas configurações de gamepad do Cemu.

`Start-VR.cmd` é o único launcher.

## O que o launcher muda

Durante a sessão, ele copia os pacotes gráficos incluídos para a pasta de dados do Cemu,
ativa os pacotes escolhidos, troca para Vulkan e carrega a camada VR para o processo do
Cemu. O log de depuração detalhado do Cemu fica desligado durante a sessão.
Outras camadas Vulkan implícitas (outra camada VR do Cemu, overlays de tela) são
desligadas para esse processo (`VR_KEEP_OTHER_LAYERS=1` mantém elas). Outros pacotes
gráficos já ativados continuam ativos, exceto que os pacotes Shadow Resolution e
Contrasty rodam em presets seguros durante a sessão (veja acima).
O preset de botão de troca de modo escolhido no Cemu é lembrado em `vr-preset.txt`
e o preset de FPS em `fps-preset.txt`.

Depois que o Cemu fecha, o launcher salva o que a sessão deixou em `session-logs` ao
lado dele: quanto tempo o Cemu rodou, o código com que saiu (0 = fechamento normal;
qualquer outro valor significa que travou ou foi encerrado à força), uma cópia do
`log.txt` do Cemu e uma cópia do `cemuvr_layer.log` da camada VR. Os dois logs são
sobrescritos no próximo início, então sem isso um travamento não deixaria nada para ler.
As últimas 12 sessões são mantidas. Se o jogo fechar sozinho, envie os arquivos mais
novos dessa pasta.

Enquanto o Cemu roda, um pequeno auxiliar (`Watch-Perf.ps1`, iniciado pelo launcher,
só leitura) conta a cada segundo quantos quadros foram renderizados e quantos passos de
jogo o jogo deu. Quando o Cemu fecha, o launcher mostra, para diorama e primeira pessoa:
os quadros por segundo, os passos de jogo por segundo dos normais 60, e quanto tempo
ficou abaixo de 55. Menos de 60 passos significa que o próprio jogo está rodando mais
devagar que o normal (o Mario pulando em câmera lenta): a imagem não conseguiu
acompanhar, então diminua o pacote gráfico de Resolução no Cemu (3840x2160 ou 3200x1800;
5120x2880 é mais do que a maioria das GPUs aguenta duas vezes por quadro) ou use o preset
de 60 FPS. Os números segundo a segundo são salvos como `session-logs\<data>-perf.csv`.

O launcher também mostra, quando há algo a relatar, linhas `Fireball:` (quantas bolas de
fogo saíram da luva e na direção da mão, e por que a última não saiu assim) e `Blow:`
(quantas vezes o gesto de soprar ligou e quantas o jogo perguntou pelo microfone) - veja
os detalhes em `mtFireStat` e `mtMic` acima. Também ficam salvas em
`session-logs\<hora>-diag.txt`.

Backups das configurações ficam em `Mario3DWorld-VR-backups` dentro da pasta de dados do
Cemu. Depois de um fechamento normal, o launcher desativa seus pacotes e restaura a API
gráfica anterior, as configurações de log de depuração e os dois presets de pacote. Os
arquivos de pacote copiados continuam instalados. Com `VR_KEEP_PACKS=1` os pacotes
continuam ativos e nada disso é restaurado.

Se a janela do launcher for fechada ou encerrada antes do Cemu ter terminado, ele deixa
`session-state.json` ao lado dele; o próximo `Start-VR.cmd` restaura as configurações
originais antes de fazer qualquer outra coisa. Até lá, confira os pacotes gráficos
ativados, a API gráfica e os dois presets antes de voltar ao jogo comum em 2D. Nenhuma
camada Vulkan de sistema é instalada.
