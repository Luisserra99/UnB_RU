# Sprint 1 — Segunda etapa

O relatório segue a estrutura do template LaTeX fornecido em `TemplateRelatorioSprint1_1/ER-MyRottenPotatoes.tex` e contém o modelo ER das 12 features e o spike documental das views Rails.

- [Relatório em PDF](relatorio-etapa-2.pdf): versão para leitura e entrega no Aprender.
- [Relatório em Markdown](relatorio-etapa-2.md): fonte principal editável, com diagramas Mermaid.
- [Relatório em LaTeX](relatorio-etapa-2.tex): fonte gerada a partir do Markdown.
- [Diagramas](diagramas/): fontes Mermaid, SVGs e PDFs vetoriais utilizados no relatório.

As decisões propostas e divergências entre cenários estão explicitadas nos apêndices. A investigação Rails é documental; não foi validada visualmente contra o Figma nem executada uma aplicação Rails.

## Regenerar os arquivos

Requer Python 3, Pandoc, uma distribuição LaTeX com `pdflatex` e Mermaid CLI (`mmdc`). A instalação do Mermaid CLI segue sua [documentação oficial](https://github.com/mermaid-js/mermaid-cli).

Na raiz do repositório:

```sh
python3 docs/sprint-1/gerar_relatorio.py
```

Para utilizar executáveis fora do `PATH` ou um navegador já instalado:

```sh
python3 docs/sprint-1/gerar_relatorio.py \
  --mmdc /caminho/para/mmdc \
  --chromium /caminho/para/chromium
```

O script extrai os diagramas do Markdown, renderiza as imagens, produz o LaTeX e compila o PDF em duas passagens para resolver o sumário. As seções e o conteúdo do template são adaptados ao domínio UnB RU; o arquivo original do professor é preservado.
