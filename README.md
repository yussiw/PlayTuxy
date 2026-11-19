# PlayTuxy

Projeto de um console compacto baseado em PC, conectado à TV por HDMI e projetado para executar jogos de PC.

## Primeira versão

Esta primeira etapa contém um kernel mínimo x86_64 inicializável, carregado pelo GRUB através do protocolo Multiboot2. Ele inicializa a comunicação serial e exibe uma mensagem de inicialização.

Ainda não é um sistema operacional completo e ainda não possui interface gráfica, áudio, USB, rede ou suporte a jogos. Essas partes serão desenvolvidas gradualmente.

## Compilação

O GitHub Actions compila o kernel e gera `PlayTuxy.iso` a cada push ou execução manual do workflow.

O artefato `PlayTuxy-ISO` pode ser baixado na página da execução do Actions.
