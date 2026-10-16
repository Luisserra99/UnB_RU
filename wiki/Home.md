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

### F05 — Configuração de Ponto de Acesso ([#5](https://github.com/neatzzy/UnB_RU/issues/5))

**Descrição:** permite que o funcionário autenticado selecione, logo após o login, o restaurante e uma de suas catracas para gerenciar. O ponto de acesso definido na sessão direciona as regras do restaurante e identifica corretamente os registros das operações.

**Regras de negócio:**

- **RN05.1:** somente um funcionário com sessão autenticada ativa pode configurar um ponto de acesso. Após cada login, o sistema deve solicitar a seleção de restaurante e catraca antes de permitir operações que dependam desse contexto.
- **RN05.2:** a seleção deve utilizar os restaurantes e as catracas cadastrados na gestão de restaurantes e catracas ([#8](https://github.com/neatzzy/UnB_RU/issues/8)). Apenas cadastros existentes e ativos podem ser confirmados; a disponibilidade deve ser verificada novamente na confirmação.
- **RN05.3:** a catraca selecionada deve pertencer ao restaurante selecionado. A lista de catracas deve apresentar somente as catracas disponíveis daquele restaurante.
- **RN05.4:** um ponto de acesso somente está configurado após a confirmação de restaurante e catraca válidos. Sem essa confirmação, as operações de controle e a consulta ao histórico da catraca atual devem permanecer indisponíveis.
- **RN05.5:** ao iniciar a alteração do ponto de acesso, as operações que dependem desse contexto devem ficar indisponíveis enquanto a reconfiguração estiver pendente. Selecionar outro restaurante válido deve remover a catraca selecionada no formulário de alteração, mantendo o ponto de acesso confirmado na sessão até uma nova confirmação válida. Após essa confirmação, o novo ponto de acesso deve ser ativado e suas operações podem ser retomadas.
- **RN05.6:** uma tentativa de seleção inválida não deve substituir o ponto de acesso anteriormente confirmado nem ser registrada como configuração concluída. O sistema deve informar o motivo da rejeição e manter a reconfiguração pendente, com as operações que dependem do ponto de acesso indisponíveis até uma nova confirmação válida.
- **RN05.7:** a confirmação do ponto de acesso e os registros das operações realizadas nele devem identificar o funcionário, o restaurante, a catraca, a data e a hora. Uma troca de ponto de acesso deve afetar somente os novos registros, preservando a identificação dos anteriores.
- **RN05.8:** quando não houver restaurantes disponíveis ou o restaurante selecionado não possuir catracas disponíveis, o sistema deve informar essa ausência e impedir a confirmação de um ponto de acesso incompleto.
- **RN05.9:** o ponto de acesso pertence à sessão autenticada atual. Logout ou expiração devem remover esse contexto; um novo login deve exigir uma nova seleção e confirmação.

**Premissas de especificação:** a seleção de catraca complementa a seleção de restaurante a partir das histórias de histórico local da catraca ([#7](https://github.com/neatzzy/UnB_RU/issues/7)) e de gestão de restaurantes e catracas ([#8](https://github.com/neatzzy/UnB_RU/issues/8)). O status ativo dos cadastros, as mensagens apresentadas e as regras de troca de ponto de acesso detalham a história e devem ser revisados pela equipe.

**Cenários BDD:** [features/configuracao_ponto_acesso.feature](../features/configuracao_ponto_acesso.feature).

<!-- Copie o bloco acima para cada nova funcionalidade -->

---

## 3. Responsáveis por Funcionalidade e Velocity

| Funcionalidade | História de usuário | Responsável | Pontos |
|---|---|---|---|
| F01 | Como estudante, eu quero me cadastrar no sistema utilizando minha matrícula, para que eu possa criar minha conta de acesso ao RU. | Leonardo Tomé Sampaio | 3 |
| F02 | Como *[perfil]*, quero *[ação]* para *[benefício]* | Nome | 5 |
| F05 | Como funcionário do restaurante, quero selecionar o restaurante e a catraca após o login para aplicar as regras e registrar os logs no ponto de acesso correto. | Daniel Dezan Baby | 3 |
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

- A especificação F05 (descrição, regras de negócio, história e cenários de `features/configuracao_ponto_acesso.feature`) foi produzida com apoio do **OpenAI Codex**. Estratégia: leitura das issues e das instruções da sprint, comparação com as branches dos colegas, divisão da análise e da redação entre agentes, revisão cruzada de consistência e validação da sintaxe com o parser Gherkin. As premissas que detalham a história estão indicadas na seção da funcionalidade para revisão pelo grupo.
- A especificação F04 (descrição, regras de negócio, história e cenários de `features/autenticacao_funcionario.feature`) foi produzida com apoio do **OpenAI Codex**. Estratégia: leitura das issues e das instruções da sprint, comparação com as branches dos colegas, divisão da análise e da redação entre agentes, revisão cruzada de consistência e validação da sintaxe com o parser Gherkin. As premissas que detalham a história estão indicadas na seção da funcionalidade para revisão pelo grupo.
