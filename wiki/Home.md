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

### F01 — Cadastro de usuário

**Descrição:** Permite o usuário se cadastrar no sistema utilizando a sua matrícula para ter acesso a conta do RU.

**Regras de negócio:**

- **RN01.1:** Matrícula deve ser de 9 números e ativo.
- **RN01.2:** Deve ser informado um email e de formato válido.
- **RN01.3:** A senha deve conter no mínimo 8 caracteres.
- **RN01.4:** O email informado pelo usuário deve ter o domínio da faculdade.
- **RN01.5:** O cadastro deve ser concluído após o preenchimento correto da matrícula e da senha.

### F02 — Recarga de Saldo ([#2](https://github.com/neatzzy/UnB_RU/issues/2))

**Descrição:** Permite que o estudante adicione créditos à sua conta do RU comprando pacotes de refeições ou quantidades personalizadas, com opções de pagamento via PIX ou Cartão de Crédito.

**Regras de negócio:**

- **RN02.1:** O valor de recarga é padronizado pelo valor das refeições, o usuário escolhe se quer café da manhã e/ou almoço/jantar e escolhe a quantidade.
- **RN02.2:** O saldo só deve ser efetivamente atualizado após a confirmação da transação de pagamento.
- **RN02.3:** Os métodos de pagamento aceitos são PIX Instantâneo e Cartão de Crédito. Para PIX, o sistema deve gerar um QR Code e código Copia e Cola.
- **RN02.4:** O código e QR Code do PIX ficam disponiveis por 10 min antes de expirar.
- **RN02.5:** O valor total da recarga é calculado somando o subtotal de Almoços/Jantares com o subtotal de Cafés da Manhã.
- **RN02.6:** Não é possível gerar uma cobrança zerada.

### F10 — Cardápio da refeição atual

**Descrição:** Permite o estudante ver o cardápio da refeição que está sendo servida no momento, incluindo as opções padrão, ovolactovegetariano e vegetariano estrito.

**Regras de negócio:**

- **RN10.1:** O cardápio exibido deve corresponder à refeição em andamento no horário da consulta (café, almoço ou jantar).
- **RN10.2:** O cardápio deve apresentar separadamente as opções padrão, ovolactovegetariano e vegetariano estrito.
- **RN10.3:** Caso não haja refeição sendo servida no horário da consulta, o sistema deve informar que não há cardápio disponível no momento.
- **RN10.4:** Caso alguma das opções (padrão, ovolactovegetariano ou vegetariano estrito) não tenha itens cadastrados, o sistema deve indicar que essa opção não está disponível.

### F03 — Extrato e recargas

**Descrição:** Permite o usuário de ver o seu extrato de recargas e histórico de refeições.

**Regras de negócio:**

- **RN03.1:** O usuário só pode ver o extrato de recargas e o histórico de refeições da própria conta.
- **RN03.2:** O histórico deve exibir data, horário e tipo de refeição de cada acesso registrado.
- **RN03.3:** O extrato deve exibir o saldo atual e as últimas recargas realizadas.
- **RN03.4:** Caso não haja registros de recarga ou de refeição, o sistema deve exibir uma mensagem informando a ausência de histórico.

### F04 — Autenticação do Funcionário ([#4](https://github.com/neatzzy/UnB_RU/issues/4))

**Descrição:** Permite que o funcionário do restaurante faça login na aplicação de controle para autenticar sua sessão e operar o sistema de forma segura.

**Regras de negócio:**

- **RN04.1:** A identificação e a senha são obrigatórias para o login; campos vazios devem ser indicados ao usuário.
- **RN04.2:** Somente funcionários cadastrados e ativos, com identificação e senha corretas, podem autenticar uma sessão na aplicação de controle.
- **RN04.3:** Senha incorreta, identificação não cadastrada ou funcionário inativo devem resultar em falha de autenticação, sem criar uma sessão e mantendo a tela de login.
- **RN04.4:** Uma conta exclusivamente de estudante não permite acesso à aplicação de controle.
- **RN04.5:** Após o login válido, o sistema deve autenticar a sessão e apresentar a escolha do restaurante e da catraca do ponto de acesso, conforme a [F05](https://github.com/neatzzy/UnB_RU/issues/5).
- **RN04.6:** As funções de controle exigem uma sessão autenticada de funcionário; sem sessão ou com sessão expirada, o sistema deve exigir login e impedir a execução da função solicitada.
- **RN04.7:** Ao sair da aplicação, a sessão deve ser encerrada, a tela de login deve ser exibida e o acesso às funções de controle deve exigir novo login.

**Premissas de especificação:** identificação e senha, situação ativa do funcionário, encerramento e expiração da sessão detalham a autenticação segura para os cenários de aceitação e devem ser revisados pela equipe. Não se define um formato para a identificação nem um prazo de expiração nesta história.

**Cenários BDD:** [features/autenticacao_funcionario.feature](../features/autenticacao_funcionario.feature).

<!-- Copie o bloco acima para cada nova funcionalidade -->

---

## 3. Responsáveis por Funcionalidade e Velocity

| Funcionalidade | História de usuário | Responsável | Pontos |
|---|---|---|---|
| F01 | Como estudante, eu quero me cadastrar no sistema utilizando minha matrícula, para que eu possa criar minha conta de acesso ao RU. | Leonardo Tomé Sampaio | 3 |
| F02 | Como *[perfil]*, quero *[ação]* para *[benefício]* | Nome | 5 |
| F03 | Como estudante, eu quero visualizar meu extrato de recargas e histórico de refeições, para ter controle sobre meus gastos e utilizações | Leonardo Tomé Sampaio | 5 |
| F04 | Como funcionário do restaurante, quero fazer login na aplicação de controle para autenticar minha sessão e operar o sistema de forma segura. | Daniel Dezan Baby | 3 |
| F10 | Como estudante, eu quero poder ver o cardápio da refeição que esteja sendo servida agora. Incluindo as opções padrão, ovolactovegetariano e vegetariano estrito. | Leonardo Tomé Sampaio | 5 |
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

- A especificação F04 (descrição, regras de negócio, história e cenários de `features/autenticacao_funcionario.feature`) foi produzida com apoio do **OpenAI Codex**. Estratégia: leitura das issues e das instruções da sprint, comparação com as branches dos colegas, divisão da análise e da redação entre agentes, revisão cruzada de consistência e validação da sintaxe com o parser Gherkin. As premissas que detalham a história estão indicadas na seção da funcionalidade para revisão pelo grupo.
