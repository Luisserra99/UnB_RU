---
title: "Referência futura — spike de views Rails e decisões pendentes"
subtitle: "Material retirado do relatório da Sprint 1, segunda etapa"
lang: pt-BR
---

Este arquivo guarda os antigos Apêndices C e D do relatório `relatorio-etapa-2.md`, removidos da versão entregue para consulta nas próximas sprints. O texto foi mantido como estava. As menções a seções `A.x` referem-se ao Apêndice A — Integridade e ciclos de negócio, disponível na versão do relatório no commit `b1374f8`.

# Spike: implementação das views em Rails

## C.1 Pergunta, método e resultado

**Pergunta:** como transformar as telas do protótipo UnB RU em views Rails, preservando os fluxos e estados das 12 features sem concentrar regras financeiras ou de autorização no navegador?

**Investigação realizada:** leitura dos cenários e da wiki, identificação dos componentes e estados necessários e consulta à documentação oficial de Action View, formulários, Turbo, Stimulus e bloqueios transacionais. O link do Figma foi extraído do PDF, mas seu conteúdo não foi acessível pela consulta web. O plugin Figma foi localizado, porém não estava conectado nesta sessão. Assim, o mapeamento abaixo deriva das features; cores, tipografia, espaçamento, ícones e fidelidade dos frames ainda não foram verificados.

**Resultado:** propõe-se Rails com templates ERB, layouts por área e partials compartilhados. `form_with` atende cadastros e filtros; Turbo Frames permite atualizar partes das páginas; Stimulus atende comportamentos locais, como quantidades, cópia do PIX e seleção dependente. A solução foi investigada documentalmente; não foi executada uma aplicação Rails ou comprovada integração com equipamentos, pagamentos ou assinatura.

## C.2 Organização das telas

| Área/tela | Views propostas | Componentes e estados relevantes |
|:---|:---|:---|
| Cadastro do estudante | `cadastros/new.html.erb` | Matrícula, email, senha, erros por campo, envio em andamento e sucesso. |
| Login de funcionário | `controle/sessoes/new.html.erb` | Identificação/senha, campos obrigatórios, falha de autenticação e redirecionamento à configuração. |
| Ponto de acesso | `controle/pontos_acesso/edit.html.erb` | Restaurante, catraca dependente, nenhuma opção, seleção incompleta, reconfiguração e confirmação rejeitada. |
| Operação da catraca | `controle/acessos/new.html.erb` | Aguardando identificação, negado, liberado, passagem realizada e acesso cancelado. |
| Histórico local | `controle/historicos/index.html.erb` | Validação da credencial, tabela restrita à catraca atual, flags/timestamps e vazio. |
| Recarga | `estudante/recargas/new.html.erb` e `show.html.erb` | Quantidades, subtotais, total, PIX/cartão, cobrança pendente, recusa, confirmação e expiração. |
| Extrato | `estudante/extratos/show.html.erb` | Saldo, filtros, total gasto, total recarregado, contagem de refeições, tabela, vazio e exportação. |
| Cardápio | `estudante/cardapios/show.html.erb` | Refeição atual, três alternativas, dieta indisponível e ausência de serviço. |
| Gestão física | `admin/restaurantes/index.html.erb`, `_form.html.erb` e `admin/catracas/_form.html.erb` | Pisos, capacidade, criação/edição, confirmação/cancelamento de remoção e erros de dependência. |
| Relatório global | `admin/relatorios/show.html.erb` | Filtros combinados, cards, consolidação, métodos, distribuição, online, vazio e exportações. |

Usar layouts `estudante`, `controle` e `admin`, com navegação adequada aos papéis do usuário. Partializar mensagens de erro, filtros, cartões de indicadores, status e tabelas. Uma pasta comum pode conter `_flash`, `_erros_formulario` e `_estado_vazio`. O recorte de componentes deve ser confirmado ao examinar os frames do Figma. A documentação de [layouts e partials do Rails](https://guides.rubyonrails.org/layouts_and_rendering.html) fundamenta essa organização.

## C.3 Formulários, atualizações e fronteiras de responsabilidade

`form_with` permite construir formulários associados aos objetos e exibir os erros retornados pelo servidor. Filtros usam GET para manter os critérios na URL; alterações e confirmações usam métodos de escrita e proteção CSRF. O servidor permite apenas parâmetros esperados e deriva usuário/estudante da sessão. Referência: [Action View Form Helpers](https://guides.rubyonrails.org/form_helpers.html).

Um único Turbo Frame deve conter os cards, a tabela e os painéis recalculados do relatório, garantindo que os filtros atualizem o conjunto. O frame da lista de catracas depende do restaurante e precisa retornar o mesmo ID esperado. Exportações saem do frame para uma resposta de download. Referência: [Turbo Frames](https://turbo.hotwired.dev/handbook/frames).

Controllers Stimulus podem calcular uma prévia dos subtotais em centavos inteiros, limpar a seleção de catraca ao mudar o restaurante, copiar o PIX e exibir um cronômetro. O preço final, a validade do pagamento e o saldo são calculados no servidor. O cronômetro nunca confirma pagamento ou lança débito. Referência: [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction).

O controle da catraca pode receber atualizações por eventos do servidor ou consultas periódicas. A escolha depende do protocolo do equipamento e da infraestrutura. O navegador apresenta o estado persistido; não interpreta um clique como passagem física. A concorrência financeira requer transações e bloqueio de linhas, conforme a [API de bloqueio pessimista do Active Record](https://api.rubyonrails.org/classes/ActiveRecord/Locking/Pessimistic.html).

## C.4 Esboço de fluxo para o relatório

O exemplo abaixo é pseudocódigo de organização, não um controller já implementado. Os objetos de consulta e autorização deverão ser criados e testados na próxima sprint.

```ruby
def show
  autorizar_relatorio_operacional!
  @filtros = FiltrosOperacao.validar!(parametros_permitidos)
  @relatorio = RelatorioOperacao.consultar(@filtros)
end

def exportar
  autorizar_exportacao_solicitada!
  filtros = FiltrosOperacao.validar!(parametros_permitidos)
  # A mesma consulta de show, antes de qualquer paginacao.
  relatorio = RelatorioOperacao.consultar(filtros)
  emitir_documento_completo!(relatorio, emissor: usuario_atual)
end
```

O objeto de consulta deve construir uma única base filtrada de acessos realizados, utilizando IDs validados para unidade, restaurante e catraca. Cards e exportação recebem essa base, com leitura consistente; a paginação afeta apenas a tabela visível. Autorização precisa ocorrer no servidor em cada endpoint, inclusive URLs diretas de download.

## C.5 Escolhas de apresentação a confirmar no Figma

1. Inventariar os frames por perfil e estado, incluindo telas vazias, mensagens e modais.
2. Extrair cores, fontes, escalas de espaçamento, raios, sombras e larguras para variáveis CSS, utilizando os valores reais do protótipo.
3. Definir grade responsiva e comportamento de tabelas em telas estreitas; confirmar se o protótipo prevê navegação móvel.
4. Mapear componentes repetidos para partials e estados interativos para controllers Stimulus pequenos.
5. Conferir labels associados a inputs, navegação por teclado, foco após erro e mensagens de estado anunciadas por tecnologias assistivas.
6. Comparar as telas implementadas aos frames em dimensões equivalentes e revisar diferenças com a equipe.

Não se propõe uma biblioteca visual específica sem conhecer os componentes do protótipo e as dependências da futura aplicação. A implementação pode começar com CSS próprio e evoluir conforme o inventário visual.

## C.6 Plano de validação da próxima sprint

| Experimento | Critério observável de conclusão |
|:---|:---|
| Formulário de cadastro | Reproduz campos do frame, mantém dados não sensíveis após erro e rejeita os três caminhos tristes de F01 no servidor. |
| Seleção dependente | Lista apenas catracas do restaurante; troca limpa seleção; confirmação revalida cadastro e bloqueia contexto pendente. |
| Fluxo da catraca | Simulação reproduz os quatro estados de A.4; débito aparece somente após evento de passagem válido. |
| Recarga pendente/confirmada | A interface não aumenta saldo por solicitação ou cronômetro; notificação repetida gera um crédito único. |
| Filtros do relatório | Cards, métodos, tabela e totais recebem o mesmo filtro, inclusive unidade e turno; restaurante sem resultado permanece zerado. |
| Exportações | Documento completo com mais registros que uma página; período inclusivo; acesso alheio negado; falha sem arquivo parcial. |
| Cardápio | Três grupos renderizados e ausência de itens de uma dieta sem esconder as demais; horário fora de serviço tratado. |
| Fidelidade visual | Comparação com os frames do Figma e revisão dos estados e comportamento responsivo. |

Esses experimentos são critérios futuros, não testes já executados. Testes de sistema Rails podem exercitar os fluxos de navegador, enquanto testes de serviço cobrem confirmação idempotente e corrida entre passagem/timeout. Referência: [Testing Rails Applications](https://guides.rubyonrails.org/testing.html).

# Divergências e decisões para revisão do grupo

| Ponto identificado nas fontes | Tratamento proposto e decisão necessária |
|:---|:---|
| F09 declara café de R$ 2,50, mas seus exemplos calculam todos os 4.820 acessos a R$ 4,50. | Com 650 cafés a R$ 2,50, 2.980 almoços e 1.190 jantares a R$ 4,50, o total seria R$ 20.390,00, não R$ 21.690,00. O modelo usa o débito histórico. O grupo deve corrigir tarifa ou resultados de teste. |
| F09 informa 72%/28% e R$ 15.616,80/R$ 6.073,20 para o total de R$ 21.690,00. | Esses valores dependem do total inconsistente. Se o total fosse R$ 20.390,00 e os percentuais fossem mantidos, os valores seriam R$ 14.680,80 e R$ 5.709,20. A distribuição real depende dos pagamentos/rateios. |
| F11 e F12 usam café de R$ 4,50 em seus exemplos; F06 usa refeição de R$ 2,50 sem fixar tipo. | Preservar valores de eventos e cenários como exemplos; não adotar um valor global a partir deles. Confirmar a política tarifária antes de integrar os dados de teste. |
| F02 permite PIX e cartão de crédito; F09 rotula crédito/débito. | Não habilitar débito sem requisito aprovado. O rótulo do painel deve ser alinhado ou F02 ampliada. |
| F09 fala em administrador para PDF oficial; F12 exige administrador geral para exportação operacional. | Proposta conservadora: administrador consulta relatório e exporta CSV; PDF operacional detalhado exige administrador geral. O alcance do PDF consolidado oficial de F09 precisa ser definido. |
| F07 solicita credenciais para histórico, além da autenticação de F04. | Tratar como revalidação da credencial para a consulta local; não aceitar credencial de outro funcionário que gerencie outra catraca. Confirmar a experiência de uso. |
| Saldo monetário ou créditos separados por refeição. | O modelo adota saldo monetário porque F02, F03 e F06 descrevem valores em reais; confirmar como o pacote “Almoço/Jantar” vira itens internos. |
| Métodos de liquidação e transações validadas em F09. | Rateio FIFO e contagem de débitos são interpretações propostas; confirmar se o painel deve representar consumo ou liquidação bancária. |
| Online, ativo e catraca em operação. | Estados distintos; definir frequência de verificação de conectividade e se catracas desativadas compõem o denominador do indicador. |
| Domínios institucionais, matrícula ativa, horários e sessão. | Não definidos integralmente. Fornecer lista de domínios, fonte de vínculo, agenda real e duração das sessões. |
| Passagem no limite de cinco segundos. | A tabela de F06 admite o limite. Definir relógio, precisão e resolução do empate com timeout. |
| “Registros auditáveis assinados digitalmente” em F11. | Definir certificado e mecanismo de assinatura; hash ou texto impresso não satisfazem assinatura criptográfica. |
| Política de remoção com dados históricos. | Proposta de exclusão restrita e desativação; alinhar mensagens para cenários não detalhados em F08. |

As divergências foram documentadas sem alterar os arquivos de aceitação dos integrantes. São pontos de revisão para tornar a especificação integrada consistente, não funcionalidades já aprovadas.

# Referências

- [Ruby on Rails — Layouts and Rendering](https://guides.rubyonrails.org/layouts_and_rendering.html).
- [Ruby on Rails — Action View Form Helpers](https://guides.rubyonrails.org/form_helpers.html).
- [Hotwire — Turbo Frames](https://turbo.hotwired.dev/handbook/frames).
- [Hotwire — Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction).
- [Active Record — Pessimistic Locking](https://api.rubyonrails.org/classes/ActiveRecord/Locking/Pessimistic.html).
- [Ruby on Rails — Testing Rails Applications](https://guides.rubyonrails.org/testing.html).
- Protótipo: [UnB RU no Figma](https://www.figma.com/design/Clozp7Rj1jOBz6l7LoT44t/UnB-RU---Engenharia-de-Software?node-id=0-1).
