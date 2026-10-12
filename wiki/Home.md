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

<!-- Copie o bloco acima para cada nova funcionalidade -->

---

## 3. Responsáveis por Funcionalidade e Velocity

| Funcionalidade | História de usuário | Responsável | Pontos |
|---|---|---|---|
| F01 | Como *[perfil]*, quero *[ação]* para *[benefício]* | Nome | 3 |
| F02 | Como *[perfil]*, quero *[ação]* para *[benefício]* | Nome | 5 |
| | | **Total (Velocity da Sprint)** | **0** |

> **Velocity** = soma dos pontos das histórias de usuário concluídas na sprint.

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
