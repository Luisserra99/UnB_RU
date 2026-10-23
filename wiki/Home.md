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

### F06 — Validação de Entrada ([#6](https://github.com/neatzzy/UnB_RU/issues/6))

**Descrição:** como aplicação de controle, ler a identificação do aluno na catraca, verificar se há saldo suficiente, liberar a catraca e efetuar o débito do valor da refeição no momento em que o aluno efetivamente passa.

**Regras de negócio:**

- **RN06.1:** a identificação deve corresponder a uma matrícula cadastrada; identificações vazias, não numéricas ou com formato inválido são rejeitadas com a mensagem "Identificação desconhecida".
- **RN06.2:** a catraca só é liberada se o saldo do aluno for maior ou igual ao valor da refeição.
- **RN06.3:** se o saldo for insuficiente, a catraca permanece bloqueada e é exibida a mensagem "Saldo insuficiente", sem débito.
- **RN06.4:** o débito do valor da refeição só ocorre quando o aluno efetivamente passa pela catraca, nunca no momento da liberação.
- **RN06.5:** se a catraca for liberada e o aluno não passar dentro do tempo limite (5 segundos), o acesso é cancelado, a catraca é bloqueada novamente e nenhum débito é realizado.

### F07 — Histórico Local da Catraca ([#7](https://github.com/neatzzy/UnB_RU/issues/7))

**Descrição:** como funcionário, visualizar na aplicação de controle o histórico de todos os acessos registrados apenas na catraca que está gerenciando, para auditorias e conferências locais de fluxo.

**Regras de negócio:**

- **RN07.1:** o histórico só é exibido após validação da credencial do funcionário (matrícula e senha); credenciais vazias, incorretas, não cadastradas ou de funcionário que não gerencia a catraca são rejeitadas com a mensagem "Credencial inválida".
- **RN07.2:** são exibidos apenas os registros da catraca gerenciada pelo funcionário; registros de outras catracas nunca aparecem.
- **RN07.3:** se não houver registros na catraca, é exibida a mensagem "Nenhum acesso registrado nesta catraca".
- **RN07.4:** toda leitura de identificação gera um registro com: identificação, data, hora, saldo lido, catraca liberada (S/N), acesso realizado (S/N), timestamp de liberação e timestamp de bloqueio.
- **RN07.5:** leituras com saldo insuficiente são registradas com catraca liberada e acesso realizado como "N", sem timestamps.
- **RN07.6:** se a catraca for liberada e o aluno não passar em até 5 segundos, o registro tem catraca liberada "S", acesso realizado "N" e timestamp de bloqueio no fim do tempo limite.
- **RN07.7:** identificações inválidas ou desconhecidas também são registradas, sem saldo lido, com catraca liberada e acesso realizado como "N".

### F09 — Relatório Global de Acessos ([#9](https://github.com/neatzzy/UnB_RU/issues/9))

**Descrição:** Permite ao administrador visualizar a consolidação operacional de todos os restaurantes do campus. O relatório traz refeições servidas, arrecadação, métodos de liquidação e distribuição por refeição. Pode ser filtrado por data contábil, turno e unidade gestora, e exportado em CSV e PDF oficial.

**Regras de negócio:**

- **RN09.1:** Somente usuários autenticados com perfil de administrador podem acessar o relatório. Qualquer outro perfil ou usuário não autenticado deve ter o acesso negado.
- **RN09.2:** O relatório é somente leitura. Nenhum dado operacional pode ser editado ou excluído por essa tela.
- **RN09.3:** Ao abrir o relatório, os filtros iniciam com data contábil = hoje, janela de serviço = "Todos os Turnos (Café, Almoço, Jantar)" e unidade gestora = "Campus Darcy Ribeiro".
- **RN09.4:** Todos os filtros atuam em conjunto e recalculam os cards, a tabela, os métodos de liquidação e a distribuição por refeição.
- **RN09.5:** O indicador "Catracas Online" exibe a quantidade de catracas online sobre o total de catracas cadastradas na unidade gestora (ex.: 6/6), conforme o cadastro de Restaurantes e Catracas.
- **RN09.6:** O card "Arrecadação Global" exibe a soma da arrecadação de todos os restaurantes.
- **RN09.7:** A tabela "Consolidação Operacional dos Restaurantes" lista uma linha por restaurante da unidade gestora, ordenada pela numeração do restaurante, com: acessos e arrecadação bruta.
- **RN09.8:** A arrecadação bruta de cada restaurante é seus acessos × tarifa aplicada. O restaurante sem acessos no filtro continua listado, com valores zerados.
- **RN09.9:** A linha "Total Consolidado" soma os acessos e a arrecadação de todos os restaurantes.
- **RN09.10:** O painel "Métodos de Liquidação" exibe, para PIX Institucional Instantâneo e Cartão de Crédito/Débito, o valor liquidado e o percentual sobre a arrecadação global. A soma dos métodos deve ser igual à arrecadação global.
- **RN09.11:** O painel de liquidação exibe também: ticket médio por estudante (arrecadação ÷ refeições servidas), transações validadas (quantidade de operações) e divergências contábeis.
- **RN09.12:** O botão "Exportar CSV" gera um arquivo com os dados do relatório conforme os filtros aplicados.
- **RN09.13:** O botão "Exportar PDF Oficial" gera um documento com os mesmos dados exibidos, os filtros aplicados, a data e hora de emissão e o usuário emissor.
- **RN09.14:** Quando nenhum acesso corresponde aos filtros, o sistema exibe a mensagem "Nenhum acesso encontrado" e todos os totais são zerados.

### F10 — Cardápio da refeição atual

**Descrição:** Permite o estudante ver o cardápio da refeição que está sendo servida no momento, incluindo as opções padrão, ovolactovegetariano e vegetariano estrito.

**Regras de negócio:**

- **RN10.1:** O cardápio exibido deve corresponder à refeição em andamento no horário da consulta (café, almoço ou jantar).
- **RN10.2:** O cardápio deve apresentar separadamente as opções padrão, ovolactovegetariano e vegetariano estrito.
- **RN10.3:** Caso não haja refeição sendo servida no horário da consulta, o sistema deve informar que não há cardápio disponível no momento.
- **RN10.4:** Caso alguma das opções (padrão, ovolactovegetariano ou vegetariano estrito) não tenha itens cadastrados, o sistema deve indicar que essa opção não está disponível.

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
| F01 | Como estudante, quero me cadastrar no sistema utilizando minha matrícula para acessar minha conta do RU. | Leonardo Tome Sampaio | 3 |
| F02 | Como estudante, quero comprar créditos para Café da Manhã e Almoço/Jantar para ter saldo para acessar os restaurantes. | Tarsila Marques de Oliveira Alves | — |
| F03 | Como estudante, quero visualizar meu extrato de recargas e histórico de refeições para ter controle sobre meus gastos e utilizações. | Leonardo Tome Sampaio | 5 |
| F04 | Como funcionário do restaurante, quero fazer login na aplicação de controle para autenticar minha sessão e operar o sistema de forma segura. | Daniel Dezan Baby | 3 |
| F05 | Como funcionário do restaurante, quero selecionar o restaurante e a catraca após o login para aplicar as regras e registrar os logs no ponto de acesso correto. | Daniel Dezan Baby | 3 |
| F06 | Como aplicação de controle, quero ler a identificação do aluno, verificar saldo, liberar a catraca e debitar a refeição na passagem para garantir que apenas alunos com saldo entrem no RU. | Luis Eduardo Curi Serra | 5 |
| F07 | Como funcionário, quero visualizar o histórico de acessos registrados apenas na catraca que estou gerenciando para realizar auditorias ou conferências locais de fluxo. | Luis Eduardo Curi Serra | 5 |
| F08 | Como administrador, quero cadastrar, editar e remover restaurantes e suas catracas físicas para que os funcionários possam selecioná-las na aplicação de controle. | Weldo Gonçalves da Silva Junior | — |
| F09 | Como administrador, quero visualizar o relatório global de operação dos restaurantes, filtrando por data, turno e unidade, para ter uma visão gerencial consolidada. | Tarsila Marques de Oliveira Alves | — |
| F10 | Como estudante, quero ver o cardápio da refeição servida agora, incluindo as opções padrão, ovolactovegetariano e vegetariano estrito. | Leonardo Tome Sampaio | 5 |
| F11 | Como estudante, quero exportar meu extrato e histórico de refeições em PDF para controlar melhor minhas finanças. | Weldo Gonçalves da Silva Junior | — |
| F12 | Como administrador geral, quero exportar o Relatório Global de Operação em PDF para realizar auditorias internas. | Daniel Dezan Baby | 5 |
| | | **Total (Velocity da Sprint)** | **34** |

> **Velocity** = soma dos pontos das histórias de usuário concluídas na sprint.

**Papéis Scrum na sprint:**

- **Scrum Master (Daniel Dezan Baby):** organização da reunião, condução do rito ágil e orquestração do time.
- **Product Owner (Leonardo Tome Sampaio):** mapeamento das issues do backlog e divisão entre os colegas.

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
- [Relatório da segunda etapa: modelo ER e spike de views Rails](../docs/sprint-1/relatorio-etapa-2.md)
- [Relatório da segunda etapa em PDF](../docs/sprint-1/relatorio-etapa-2.pdf)
  
## 6. Uso de IA na sprint

- O [relatório da segunda etapa](../docs/sprint-1/relatorio-etapa-2.md), os diagramas ER e o spike documental de views Rails foram elaborados com apoio do **OpenAI Codex**, a partir do enunciado, do template LaTeX, da wiki e das 12 features. A estratégia e os limites da investigação estão registrados no Apêndice E; as decisões propostas e divergências entre requisitos estão identificadas para revisão pelo grupo.

- Tempalte da wiki montado pelo Claude Code Sonnet 5.5 Medium
- Seção F06 — Validação de Entrada (descrição e regras de negócio) e os cenários BDD de `features/validacao_entrada.feature` escritos com apoio do Claude Code Sonnet 5, a partir da história de usuário fornecida e revisados/ajustados manualmente pelo integrante responsável.
- Seção F07 — Histórico Local da Catraca (descrição e regras de negócio) escrita wiki com apoio do Claude Code Opus 5.5, a partir dos cenários BDD de `features/historico_local_catraca.feature`, e revisada pelo integrante responsável.

- A especificação F12 (descrição, regras de negócio, história e cenários de `features/exportacao_pdf_relatorio_operacao.feature`) foi produzida com apoio do **OpenAI Codex**. Estratégia: leitura das issues e das instruções da sprint, comparação com as branches dos colegas, divisão da análise e da redação entre agentes, revisão cruzada de consistência e validação da sintaxe com o parser Gherkin. As premissas que detalham a história estão indicadas na seção da funcionalidade para revisão pelo grupo.
- A especificação F05 (descrição, regras de negócio, história e cenários de `features/configuracao_ponto_acesso.feature`) foi produzida com apoio do **OpenAI Codex**. Estratégia: leitura das issues e das instruções da sprint, comparação com as branches dos colegas, divisão da análise e da redação entre agentes, revisão cruzada de consistência e validação da sintaxe com o parser Gherkin. As premissas que detalham a história estão indicadas na seção da funcionalidade para revisão pelo grupo.
- A especificação F04 (descrição, regras de negócio, história e cenários de `features/autenticacao_funcionario.feature`) foi produzida com apoio do **OpenAI Codex**. Estratégia: leitura das issues e das instruções da sprint, comparação com as branches dos colegas, divisão da análise e da redação entre agentes, revisão cruzada de consistência e validação da sintaxe com o parser Gherkin. As premissas que detalham a história estão indicadas na seção da funcionalidade para revisão pelo grupo.
