# UnB RU — Wiki

## Identificação

| | |
|---|---|
| **Projeto** | UnB RU |
| **Sprint entregue** | Sprint 1 |
| **Período entrega 1** | 09/10/2026 a 16/10/2026 |
| **Período entrega 2** | 16/10/2026 a 23/10/2026 |

### Integrantes

| Nome | Matrícula | Papel |
|---|---|---|
| Daniel Dezan Baby | 232046097 | Scrum Master |
| Leonardo Tome Sampaio | 222005448 | Product Owner |
| Luis Eduardo Curi Serra | 251033574 | Desenvolvedor(a) |
| Tarsila Marques de Oliveira Alves | 242012029 | Desenvolvedor(a) |
| Weldo Gonçalves da Silva Junior | 222014133 | Desenvolvedor(a) |


---

## 1. Papéis Scrum

| Papel | Responsável |
|---|---|
| **Scrum Master** | Daniel Dezan Baby |
| **Product Owner** | Leonardo Tome Sampaio |

---

## 2. Funcionalidades e Regras de Negócio

### F01 — Nome da funcionalidade

**Descrição:** breve descrição do que a funcionalidade faz.

**Regras de negócio:**

- **RN01.1:** …
- **RN01.2:** …

### F02 — Nome da funcionalidade

**Descrição:** …

**Regras de negócio:**

- **RN02.1:** …
- **RN02.2:** …

### F12 — Exportação em PDF do Relatório de Operação ([#12](https://github.com/neatzzy/UnB_RU/issues/12))

**Descrição:** permite que o administrador geral exporte o Relatório Global de Operação em PDF para auditoria interna, respeitando os filtros e agrupamentos aplicados ao histórico de acessos da issue [#9](https://github.com/neatzzy/UnB_RU/issues/9).

**Regras de negócio:**

- **RN12.1:** somente o administrador geral com sessão válida pode exportar o relatório; funcionários e estudantes não têm permissão, inclusive por acesso direto à exportação.
- **RN12.2:** o PDF deve conter todos os acessos que correspondem aos filtros de período, restaurante e catraca aplicados no relatório, inclusive os que estejam em outras páginas da listagem. Os limites do período são inclusivos.
- **RN12.3:** cada acesso exportado deve identificar data e hora, matrícula do estudante, restaurante, catraca, refeição e valor debitado; o relatório deve apresentar a quantidade de acessos e o total debitado correspondentes aos registros exportados.
- **RN12.4:** o PDF deve identificar o administrador responsável pela emissão, a data e hora da emissão, os filtros e os agrupamentos aplicados, permitindo conferir o contexto da auditoria.
- **RN12.5:** os agrupamentos por restaurante e por catraca devem preservar seus vínculos e apresentar subtotais de acessos e valores, sem misturar catracas de mesmo nome em restaurantes diferentes.
- **RN12.6:** filtros sem resultados devem produzir a mensagem "Não há acessos para os filtros selecionados", sem download de arquivo.
- **RN12.7:** um período com data inicial posterior à final deve ser rejeitado com a mensagem "A data inicial deve ser anterior ou igual à data final", sem gerar arquivo.
- **RN12.8:** em caso de falha na geração, o sistema deve informar "Não foi possível gerar o PDF. Tente novamente" e permitir nova tentativa, sem disponibilizar arquivo incompleto nem alterar os acessos registrados.

**Premissas de especificação:** os campos, mensagens, subtotais e o comportamento sem resultados acima detalham a história para os cenários de aceitação e devem ser revisados pela equipe. Os valores monetários nos cenários são dados de exemplo, não uma definição de preço das refeições.

**Cenários BDD:** [features/exportacao_pdf_relatorio_operacao.feature](../features/exportacao_pdf_relatorio_operacao.feature).

<!-- Copie o bloco acima para cada nova funcionalidade -->

---

## 3. Responsáveis por Funcionalidade e Velocity

| Funcionalidade | História de usuário | Responsável | Pontos |
|---|---|---|---|
| F01 | Como *[perfil]*, quero *[ação]* para *[benefício]* | Nome | 3 |
| F02 | Como *[perfil]*, quero *[ação]* para *[benefício]* | Nome | 5 |
| F12 | Como administrador geral, quero exportar o Relatório Global de Operação em PDF para realizar auditorias internas. | Daniel Dezan Baby | 5 |
| | | **Total (Velocity da Sprint)** | **0** |

> **Velocity** = soma dos pontos das histórias de usuário concluídas na sprint.

> Os pontos das histórias de Daniel são estimativas de planejamento para revisão pelo grupo. A Velocity será atualizada após a conclusão e a revisão das histórias na sprint.

### 3.1 Divisão das issues

| Responsável | Issues | MVP |
|---|---|---|
| Leonardo Tome Sampaio | [#1](https://github.com/neatzzy/UnB_RU/issues/1) Cadastro de Usuário, [#3](https://github.com/neatzzy/UnB_RU/issues/3) Extrato e Histórico, [#10](https://github.com/neatzzy/UnB_RU/issues/10) Cardápio da refeição atual | #1 |
| Tarsila Marques de Oliveira Alves | [#2](https://github.com/neatzzy/UnB_RU/issues/2) Recarga de Saldo, [#9](https://github.com/neatzzy/UnB_RU/issues/9) Relatório Global de Acessos | #2 |
| Daniel Dezan Baby | [#4](https://github.com/neatzzy/UnB_RU/issues/4) Autenticação do Funcionário, [#5](https://github.com/neatzzy/UnB_RU/issues/5) Configuração de Ponto de Acesso, [#12](https://github.com/neatzzy/UnB_RU/issues/12) Exportação em PDF do Relatório de Operação | #4 |
| Luis Eduardo Curi Serra | [#6](https://github.com/neatzzy/UnB_RU/issues/6) Validação de Entrada, [#7](https://github.com/neatzzy/UnB_RU/issues/7) Histórico Local da Catraca | #6 |
| Weldo Gonçalves da Silva Junior | [#8](https://github.com/neatzzy/UnB_RU/issues/8) Gestão de Restaurantes e Catracas, [#11](https://github.com/neatzzy/UnB_RU/issues/11) Exportação em PDF do Histórico do Estudante | #8 |

---

## 4. Padrões do Grupo

### 4.1 Padrão de commits

Formato adotado: **Conventional Commits**

```
<tipo>(<escopo opcional>): <descrição curta no imperativo>

<corpo opcional>
```

| Tipo | Uso |
|---|---|
| `feat` | Nova funcionalidade |
| `fix` | Correção de bug |
| `docs` | Documentação |
| `style` | Formatação, sem mudança de lógica |
| `test` | Testes |

Exemplo: `feat(cardapio): adiciona listagem do cardápio do dia`

### 4.2 Política de branching

- `main`: código estável, só recebe merge via Pull Request no final da sprint.
- `sprint-N`: branch de integração da sprint.
- `sprint-N-feature-usuario/<nome-curto>`: uma branch por funcionalidade/história, criada a partir de `sprint-N`, `usuario` é o integrante.
- `sprint-N-fix-usuario/<nome-curto>`: correções, criada a partir de `sprint-N`, `usuario` é o integrante.

### 4.3 Política de revisão

- Todo merge é feito via **Pull Request**.
- Mínimo de **1 aprovação** de outro integrante (nunca o próprio autor).
- O PR deve referenciar a história/issue correspondente.
- Conflitos são resolvidos pelo autor do PR antes da revisão.

---

## 5. Links úteis

- [issues-sprint1](https://github.com/neatzzy/UnB_RU/issues)
  
## 6. Uso de IA na sprint

- Tempalte da wiki montado pelo Claude Code Sonnet 5.5 Medium

- A especificação F12 (descrição, regras de negócio, história e cenários de `features/exportacao_pdf_relatorio_operacao.feature`) foi produzida com apoio do **OpenAI Codex**. Estratégia: leitura das issues e das instruções da sprint, comparação com as branches dos colegas, divisão da análise e da redação entre agentes, revisão cruzada de consistência e validação da sintaxe com o parser Gherkin. As premissas que detalham a história estão indicadas na seção da funcionalidade para revisão pelo grupo.
