# Processador de 16-bits em VHDL

Repositório dedicado ao desenvolvimento e implementação de uma Unidade Central de Processamento (CPU) de 16 bits, descrita inteiramente em VHDL para execução em placas FPGA. Este projeto explora o desenho de circuitos lógicos, o encaminhamento de dados (*datapath*) e o controlo de hardware de baixo nível.

## 📌 Características do Projeto

* **Arquitetura de 16 bits:** Operações lógicas/aritméticas, barramentos e um banco de 8 registadores concebidos para trabalhar com palavras de 16 bits.
* **Conjunto de Instruções (ISA):** Suporte para 11 instruções fundamentais divididas em três formatos (Tipo R, Tipo I com extensor de sinal e Tipo J), cobrindo operações matemáticas, acesso à memória e saltos.
* **Unidade de Controlo (FSM):** Máquina de Estados Finitos que orquestra os ciclos de busca (*fetch*), decodificação (*decode*) e execução das instruções.
* **Interface Física:** 
  * Tratamento de ruído mecânico através de um circuito *debouncer* para o sinal de relógio (*clock*).
  * Multiplexação de dados nos displays de 7 segmentos (HEX0 a HEX7) para exibir o estado do *Program Counter* (PC), a saída da ULA ou os dados da memória.
  * Mapeamento de LEDs verdes para a sinalização visual dos estados da Unidade de Controlo.

## 🎓 Contexto Académico
Este projeto foi desenvolvido como requisito de avaliação laboratorial para o curso de Engenharia de Computação (PUC-Campinas), aplicando na prática os conceitos de Arquitetura de Computadores e Sistemas Digitais.
