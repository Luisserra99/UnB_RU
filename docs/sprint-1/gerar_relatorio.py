#!/usr/bin/env python3
"""Gera o LaTeX e o PDF a partir do relatório Markdown e de seus diagramas.

Dependências externas: pandoc, pdflatex e Mermaid CLI (mmdc).
Use --chromium para selecionar um navegador já instalado para o Mermaid CLI.
"""

import argparse
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unicodedata
import xml.etree.ElementTree as ET


BASE = Path(__file__).resolve().parent
NOME = "relatorio-etapa-2"


def executar(argumentos, cwd=BASE):
    resultado = subprocess.run(
        argumentos, cwd=cwd, text=True, encoding="utf-8", errors="replace", stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT, check=False,
    )
    if resultado.returncode:
        raise RuntimeError(f"Falha em {argumentos[0]}:\n{resultado.stdout[-12000:]}")
    return resultado.stdout


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mmdc", default="mmdc")
    parser.add_argument("--chromium", help="Caminho do executável Chromium/Chrome")
    argumentos = parser.parse_args()
    for ferramenta in (argumentos.mmdc, "pandoc", "pdflatex"):
        if not shutil.which(ferramenta):
            parser.error(f"Dependência não encontrada: {ferramenta}")

    texto = (BASE / f"{NOME}.md").read_text(encoding="utf-8")
    pasta = BASE / "diagramas"
    pasta.mkdir(exist_ok=True)
    padrao = re.compile(r"^## (Visão [^\n]+)\n\n```mermaid\n(.*?)\n```", re.M | re.S)
    visoes = list(padrao.finditer(texto))
    if len(visoes) != len(re.findall(r"^```mermaid$", texto, re.M)):
        raise RuntimeError("Há diagramas Mermaid sem título de visão reconhecido.")

    with tempfile.TemporaryDirectory(prefix="unb-ru-relatorio-") as temporario:
        temp = Path(temporario)
        configuracao = {"args": ["--no-sandbox"]}
        if argumentos.chromium:
            configuracao["executablePath"] = argumentos.chromium
        config = temp / "puppeteer.json"
        config.write_text(json.dumps(configuracao), encoding="utf-8")

        substituicoes = {}
        for visao in visoes:
            rotulo = unicodedata.normalize("NFKD", visao[1].split(" — ")[0])
            nome = rotulo.encode("ascii", "ignore").decode().lower().replace(" ", "-")
            fonte = pasta / f"{nome}.mmd"
            conteudo = visao[2] + "\n"
            atualizado = fonte.exists() and fonte.read_text(encoding="utf-8") == conteudo
            fonte.write_text(conteudo, encoding="utf-8")
            for extensao in ("svg", "pdf"):
                if atualizado and (pasta / f"{nome}.{extensao}").exists():
                    continue
                comando = [argumentos.mmdc, "-i", str(fonte), "-o",
                           str(pasta / f"{nome}.{extensao}"), "-p", str(config),
                           "-b", "white", "-t", "neutral", "--pdfFit"]
                executar(comando)
            raiz = ET.parse(pasta / f"{nome}.svg").getroot()
            _, _, largura, altura = map(float, raiz.attrib["viewBox"].split())
            paisagem = largura / altura > 1.1
            inicio = "\\begin{landscape}\n" if paisagem else ""
            fim = "\\end{landscape}\n" if paisagem else ""
            substituicoes[visao[0]] = (
                "\\clearpage\n" + inicio
                + f"\\subsection*{{{visao[1]}}}\n"
                + "\\begin{center}\n"
                + "\\includegraphics[width=\\linewidth,height=0.88\\textheight,"
                  "keepaspectratio]{diagramas/" + nome + ".pdf}\n"
                + "\\end{center}\n" + fim + "\\clearpage\n"
            )
            print(f"Diagrama {nome}: validado e renderizado.")

        for original, substituicao in substituicoes.items():
            texto = texto.replace(original, substituicao)
        entrada = temp / "relatorio.md"
        entrada.write_text(texto, encoding="utf-8")
        cabecalho = temp / "cabecalho.tex"
        cabecalho.write_text(r"""
\usepackage{caption}
\usepackage{graphicx}
\usepackage{pdflscape}
\usepackage{etoolbox}
\usepackage{fancyvrb}
\fvset{fontsize=\small}
\AtBeginEnvironment{longtable}{\footnotesize}
\setlength{\emergencystretch}{3em}
\setlength{\parskip}{0.4em}
\AtBeginDocument{\def\UrlBreaks{\do\_\do\/\do\.\do\-}\Urlmuskip=0mu}
""", encoding="utf-8")
        filtro = temp / "quebrar-identificadores.lua"
        filtro.write_text(r"""
function Code(el)
  if #el.text > 16 and not el.text:find('[%s{}|]') then
    return pandoc.RawInline('latex', '\\path|' .. el.text .. '|')
  end
end
""", encoding="utf-8")
        destino_tex = BASE / f"{NOME}.tex"
        executar([
            "pandoc", str(entrada), "--standalone", "--from=markdown+raw_tex",
            "--to=latex", "--toc", "--toc-depth=2", "--lua-filter", str(filtro),
            "--include-in-header", str(cabecalho),
            "-V", "documentclass=article", "-V", "fontsize=12pt",
            "-V", "papersize=a4", "-V", "geometry=margin=1in",
            "-V", "colorlinks=true", "-V", "linkcolor=black",
            "-V", "urlcolor=blue", "-o", str(destino_tex),
        ])
        # A terceira passagem corrige os números do sumário, que ocupa mais de uma página.
        for _ in range(3):
            executar(["pdflatex", "-interaction=nonstopmode", "-halt-on-error",
                      "-output-directory", str(temp), str(destino_tex)])
        shutil.copy2(temp / f"{NOME}.pdf", BASE / f"{NOME}.pdf")
        log = (temp / f"{NOME}.log").read_text(encoding="utf-8", errors="replace")
        avisos = [linha for linha in log.splitlines() if "Overfull" in linha]
        print(f"PDF e LaTeX gerados em {BASE}.")
        if avisos:
            print("Avisos de layout a verificar:\n" + "\n".join(avisos))


if __name__ == "__main__":
    main()
