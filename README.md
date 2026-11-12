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

## 📁 Estrutura

```
rtl/      Descrição de hardware (sintetizável)
sim/      Testbenches, modelo comportamental da memória e scripts de simulação
mif/      Programas de teste (inicialização da memória)
quartus/  Projeto Quartus (DE2-115, EP4CE115F29C7)
```

## ⚙️ Convenções da ISA

| Tipo | Formato | Instruções |
|---|---|---|
| R | `op[15:12] Ri[11:9] Rj[8:6] Rk[5:3] 000` | ADD, SUB, AND, OR, SLT: `Ri ← Rj op Rk` |
| I | `op[15:12] Ri[11:9] Rj[8:6] imm[5:0]` | ADDI `Ri ← Rj + imm` · LD `Ri ← M[Rj + imm]` · ST `M[Rj + imm] ← Ri` · BEQ/BNE `Ri, Rj` |
| J | `op[15:12] addr[11:0]` | JMP `PC ← 0000 & addr` |

* `R0` é fixo em zero.
* O PC é incrementado no `FETCH`. O alvo dos desvios é `endereço do branch + 1 + imm`.
* Memória unificada de 256 × 16 bits.

## ▶️ Simulação

* **macOS/Linux (nvc):** `./sim/run_nvc.sh`, usando `sim/memory_sim.vhd` no lugar do `altsyncram`.
* **ModelSim/Questa Intel:** dentro de `sim/`, `do cpu_tb.do`.

## 🔌 Placa (DE2-115)

| Entrada/Saída | Função |
|---|---|
| `KEY0` | Avança um estado da FSM |
| `KEY1` | Reset |
| `SW17` | `HEX7–4`: 0 = RDM, 1 = RegULA |
| `HEX3–0` | PC |
| `LEDG[3:0]` / `LEDR[13:0]` | Estado da FSM (binário / one-hot) |

O programa carregado é definido por `set_parameter -name INIT_FILE` em `quartus/cpu_top.qsf`.
