![alt text][logo]

[logo]: https://github.com/mgborges/confront/blob/master/FIGs/CONFRONT.png "CONFRONT logo"

O CONFRONT é um conferidor automático para o cálculo das unidades monitoras e da dose no ponto de cálculo provenientes do sistema de planejamento XiO implementado em R. Como resultado final, o programa resulta um arquivo PDF com diversos parâmetros físicos extraídos do arquivo source do XiO e fatores das tabelas de comissionamento.

## Cite o trabalho

Borges, M. G., Lima, R. B. B., Pereira, F. O., Costa, P. A. F., Santos, T. A., Antonio, T. R. T. A., Biazotto, B., & Pereira, M. T. (2022). CONFRONT: Proposta e implementação de um conferidor automático de cálculo em R a partir do XiO®. Revista Brasileira De Física Médica, 16, 595. https://doi.org/10.29384/rbfm.2022.v16.19849001595

## Instalação

Abaixo é descrito o processo de instalação para o Windows. Para Linux e Mac o processo de instalação deve ser adaptado.

Você também pode contar com vídeos com o passo-a-passo do processo de instalação no Windows [acessando esta playlist do YouTube](https://www.youtube.com/playlist?list=PLi47ZczgdsHeVEIuRaNJRtDqjFl5L3IbU).

Antes da instalação, certifique-se de instalar os seguintes programas:

- [MikTex](https://miktex.org/download)

- [Adobe Reader](https://get.adobe.com/br/reader/)

- [R](https://cran.r-project.org/)

- [RStudio](https://rstudio.com/products/rstudio/download)

Após a instalação destes programas, reinicie o computador.

- Abra o “Rstudio”;

- Clique na aba “Console” e digite o seguinte comando:

```r
install.packages(c("kableExtra", "pdftools", "reticulate", "stringr"), dependencies = T)
```

- Aguarde a instalação de todos os pacotes ser concluída;

- Ao finalizar, digite o seguinte comando:

```r
reticulate::install_miniconda()
```

- Ao finalizar, finalmente digite:

```r
tinytex::install_tinytex()
```

- Pode ser que algumas mensagens de aviso apareçam. Aguarde a finalização da instalação.

- Feche o Rstudio.

- Faça o download do CONFRONT clicando [aqui](https://github.com/mgborges/confront/archive/master.zip). Extraia os arquivos no local onde o programa será instalado.

- Abra o arquivo `CONFRONT.Rmd`.

- Clique no botão `Knit` no RStudio ou pressione `CTRL + SHIFT + K`;

- Uma janela aparecerá pedindo para selecionar um PDF para conferência. Selecione o arquivo `TESTE_FOTONS.pdf`. O resultado para todos os campos deve ser “OK”. Note que a primeira execução pode instalar módulos adicionais das bibliotecas, e pode levar algum tempo para concluir;

- Repita o processo para o arquivo `TESTE_ELETRONS.pdf`. Este arquivo possui apenas um campo e o resultado deve ser “OK”;

## Criando um atalho para execução rápida no Windows

Você pode executar o conferidor da forma como foram feitos os testes acima, ou pode criar um atalho para tornar a tarefa mais automatizada.

Para tanto, edite o arquivo `CONFRONT.bat` (usando o notepad, por exemplo) na pasta de instalação como abaixo, em uma mesma linha:

```
"C:\Program Files\R\R-3.6.1\bin\Rscript.exe" -e "Sys.setenv(RSTUDIO_PANDOC='C:/Program Files/Rstudio/bin/pandoc'); rmarkdown::render('C:/Users/teste/master-confront/CONFRONT.Rmd')" && start acrord32 /A "page=1" "C:\Users\teste\master-confront\CONFRONT.pdf"
```

Note que o comando acima deve ser editado a depender de onde os programas são instalados e das pastas que contem os executáveis. Note que em alguns campos é necessário utilizar a barra invertida `\` e em outros a barra `/`;

Salve o arquivo .bat; Clique com o botão direito do mouse e crie um atalho para este arquivo; Renomeie o atalho e mova-o para onde for mais conveniente em seu computador.

## Alguns comandos úteis

Algumas funções disponíveis podem ser interessantes para o processo de cálculo e/ou conferência manual ou 2D. 

Abaixo listo algumas destas funcionalidades com exemplos:

* Obtenção da TPR, Fator abertura do colimador e Fator retroespalhamento
    * Suponha um campo equivalente igual a 15 cm² e um campo colimado de 13 cm². A profundidade é 5,5 cm e a energia é 6 MV:
        * ```dadosFicha(TABELA = TMR_OPEN_06, RENDIMENTO = RENDIMENTO_06, TAMANHOCAMPO = 15, EQUIVALENTE = 13, PROFUNDIDADE = 5.5)```
        * Retorna: `TMR = 0.9205; Sc = 1.0220; Sp = 1.0080`;
        * Note que o mesmo comando pode ser executado de forma simplificada como:
        * `dadosFicha(TMR_OPEN_06, RENDIMENTO_06, 15, 13, 5.5)`

* Obtenção da PDP, Fator abertura do colimador e Fator retroespalhamento
    * Suponha um campo equivalente igual a 7 cm² e um campo colimado de 6 cm². A profundidade é 10 cm e a energia é 10 MV:
        * ```dadosFicha(TABELA = PDP_OPEN_10, RENDIMENTO = RENDIMENTO_10, TAMANHOCAMPO = 7, EQUIVALENTE = 6, PROFUNDIDADE = 10)```
        * Retorna: `PDP = 0.7245; Sc = 0.9750; Sp = 0.9870`;
        * Note que o mesmo comando pode ser executado de forma simplificada como:
        * `dadosFicha(PDP_OPEN_10, RENDIMENTO_10, 7, 6, 10)`

* Obtenção do fator filtro
    * Suponha um campo colimado de 6 cm². O filtro de 45° e a energia é 6 MV:
        * ```obterFatorFiltro(TABELA_FATOR_FILTRO = FATOR_FILTRO_06, FILTRO = 45, CAMPO = 6)```
        * Retorna: `0.49068`;
        * Note que o mesmo comando pode ser executado de forma simplificada como:
        * `obterFatorFiltro(FATOR_FILTRO_06, 45, 6)`

* Obtenção do fator off-axis para campo aberto
    * Suponha um off-axis de 6 cm, na profundidade de 2 cm para energia de 6 MV:
        * `obterOFFAxisCampoAberto(TABELA = FOA_OPEN_06, LINHA = 6, COLUNA = 2)`
        * Retorna: `1.03495`;
        * Note que o mesmo comando pode ser executado de forma simplificada como:
        * `obterOFFAxisCampoAberto(FOA_OPEN_06, 6, 2)`

* Obtenção do fator rendimento para elétrons
    * Suponha um cone 10x10 cm² e energia de 12 MeV:
        * `obterDadosTabela(TABELA = ELETRONS, COLUNA = 12, LINHA = 10)`
        * Retorna: `1.011534`;
        * Note que o mesmo comando pode ser executado de forma simplificada como:
        * `obterDadosTabela(ELETRONS, 12, 10)`

## Observação para campos com bólus e feixes mistos

Esta ferramenta é capaz de realizar a conferência para um campo com bólus, mas os campos devem ser considerados um a um. Desta forma, a dose no isocentro deverá ser computada em conjunto com os demais campos sem bólus de um planejamento.

Esta ferramenta não é capaz de realizar a conferência para feixes mistos. Desta forma, você deve considerar os campos de elétrons e fótons separados e considerar a dose no isocentro como a somatória da contribuição para cada um dos campos.

E atenção! Não nos responsabilizamos por qualquer erro ou consequência da utilização desta ferramenta, bem como sua modificação e implementação.

## Considerações Éticas

Este projeto foi aprovado pelo Comitê de Ética em Pesquisa da Universidade Estadual de Campinas:

* **Título da Pesquisa**: PROPOSTA E IMPLEMENTAÇÃO DE UM CONFERIDOR AUTOMÁTICO DE CÁLCULO A PARTIR DO XiO

* **Pesquisador Responsável**: Murilo Guimarães Borges

* **CAAE**: 33408620.1.0000.5404

* **Submetido em**: 03/07/2020

* **Instituição Proponente**: Hospital de Clínicas - UNICAMP

* **Situação da Versão do Projeto**: Aprovado

## Quer utilizar esta ferramenta em seu serviço? :clap: Sinta-se _open-source_!

Esta ferramenta pode ser adaptada para uso em seu serviço! Para isso, você vai precisar saber um pouco de R e fornecer as tabelas necessárias para o CONFRONT funcionar. Entenda como os arquivos estão organizados:

- PACOTES.R
    - Onde são explícitos os pacotes necessários para execução da ferramenta;

- FUNCOES.R
    - Onde são explícitas as funções principais para extração de informações de um arquivo PDF, consultas as tabelas de comissionamento e funções de interpolação de dados;

- TABELAS.R
    - Onde são lidas todas as tabelas do comissionamento disponíveis para o cálculo;

- SINTAXE.R
    - Onde são definidos de forma explícita os parâmetros que caracterizam os nomes dos feixes e sua qualidade e energia, bem como parâmetros que podem ser transitórios ou modificados pelo serviço que utiliza a ferramenta (e.g. desvio máximo para o cálculo das UM ou dose no ponto de cálculo para cada campo);

- OPCOES_GENERICAS.R
    - Onde são definidas funções comuns para todas as energias e tipos de feixes e para as funções que processam os dados do cabeçalho e identificação do paciente e plano de tratamento;

- FOTONS.R
    - Onde são definidas as funções utilizadas para o cálculo das unidades monitoras e da dose no ponto de cálculo para fótons;

- ELETRONS.R
    - Onde são definidas as funções utilizadas para o cálculo das unidades monitoras e da dose no ponto de cálculo para elétrons;

Ao final do processamento, um arquivo PDF é compilado do LaTex contendo todas as informações físicas e fatores utilizados para o cálculo das unidades monitoras e dose no ponto de cálculo. 

As tabelas de comissionamento são basicamente `data.frames`, onde `rownames` e `colnames` contém os parâmetros de busca implementados pelas funções de consulta. Os comandos `class()` e `View()` podem ser muito úteis.

Um exemplo de tabela de TMR é:

|  | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|-|-|-|-|-|-|-|-|
| 0 | 0.4194 | 0.4266 | 0.4350 | 0.4434 | 0.4529 | 0.4622 | 0.4714 |
| 0.5 | 0.6908 | 0.6930 | 0.7005 | 0.7047 | 0.7087 | 0.7155 | 0.7222 |
| 1 | 0.9366 | 0.9345 | 0.9399 | 0.9403 | 0.9405 | 0.9428 | 0.9451 |
| 1.5 | 1.0000 | 1.0000 | 1.0000 | 1.0000 | 1.0000 | 1.0000 | 1.0000 |
| 2 | 1.0059 | 1.0046 | 1.0065 | 1.0060 | 1.0052 | 1.0042 | 1.0033 |
| 2.5 | 0.9932 | 0.9933 | 0.9953 | 0.9946 | 0.9935 | 0.9930 | 0.9931 |

onde a primeira linha é o tamanho de campo e a primeira coluna, a profundidade. Note que deve ser utilizado ponto ao invés de vírgula.

Outro ponto é o nome que é dado para cada um dos feixes disponíveis no serviço. Este parâmetro deve ser editado dentro os arquivos `FOTONS.R` e `ELETRONS.R`.

E se tiver qualquer dúvida, basta escrever! O cógido deste programa é livre e pode ser utilizado e alterado livremente. Para acessoria na implementação desta ferramenta, consulte preços e disponibilidade entrando em [contato](mailto:murilogborges@gmail.com).
