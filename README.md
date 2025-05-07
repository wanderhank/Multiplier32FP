# Multiplier32FP

# 🧮 multiplier32FP – Multiplicador de Ponto Flutuante IEEE 754 (32 bits)

Este repositório contém um módulo Verilog que implementa um **multiplicador de ponto flutuante de 32 bits**, compatível com o padrão **IEEE 754**. O projeto é controlado por uma máquina de estados finitos (FSM) e inclui tratamento completo de casos especiais como **NaN**, **infinito**, **overflow**, **underflow** e **zero**.

---

## 📌 Visão Geral

O módulo `multiplier32FP` realiza a multiplicação de dois operandos de 32 bits em ponto flutuante (formato IEEE 754) de forma sequencial. A operação é iniciada via um sinal de controle (`start_i`) e os resultados são disponibilizados após a conclusão com um pulso em `done_o`.

---

## ⚙️ Interface

### Entradas:
- `clk`: Clock global do circuito
- `rst_n`: Reset assíncrono ativo em nível baixo
- `start_i`: Inicia uma nova operação de multiplicação
- `a_i [31:0]`: Operando A (IEEE 754)
- `b_i [31:0]`: Operando B (IEEE 754)

### Saídas:
- `done_o`: Sinaliza fim da operação (1 ciclo ativo)
- `nan_o`: Flag para entrada ou resultado "Not a Number" (2 ciclos ativos)
- `infinit_o`: Flag para operandos ou resultado infinitos (2 ciclos ativos)
- `overflow_o`: Resultado com overflow (2 ciclos ativos)
- `underflow_o`: Resultado com underflow (2 ciclos ativos)
- `product_o [31:0]`: Resultado da multiplicação (IEEE 754)

---

## 🔁 Máquina de Estados Finita (FSM)

O controle do módulo é feito por uma FSM com os seguintes estados:

| Estado                     | Função                                                           |
|----------------------------|------------------------------------------------------------------|
| `IDLE`                     | Aguardando início de operação (`start_i`)                       |
| `EXPONENT`                 | Processa os expoentes e detecta operandos denormalizados        |
| `MULTIPLY`                 | Realiza multiplicação das mantissas e ajusta sinal e expoente   |
| `CHECK_INPUTS`             | Verifica operandos inválidos, infinitos ou NaN                  |
| `CHECK_OVERFLOW_UNDERFLOW`| Avalia se o resultado causou overflow ou underflow              |
| `DONE`                     | Emite o resultado final e retorna ao estado `IDLE`              |

---
