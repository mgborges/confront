# Retorna conteudo da pagina sem o cabecalho
retornarPagina <- function(paginas, numeroPagina) {
  if (numeroDePaginas == 1) {
    pagina <- paginas
  } else { pagina <- paginas[[numeroPagina]] }
  finalCabecalho <- grep("Beam weigh", pagina)
  pagina <- pagina[-(1:finalCabecalho)]
  return(pagina)
}

# Retorna o cabecalho de uma pagina sem seu conteudo
retornarCabecalho <- function(paginas, numeroPagina) {
  if (numeroDePaginas == 1) {
    pagina <- paginas
  } else { pagina <- paginas[[numeroPagina]] }
  finalCabecalho <- grep("Beam weigh", pagina)
  cabecalho <- pagina[1:finalCabecalho]
  return(cabecalho)
}

# Obtem as posicoes dentro de um data-frame para uma determinada observacao, seja nas linhas ou colunas
obterPosicoes <- function (CAMPOS, CAMPO) {
  POSICAO <- CAMPOS >= CAMPO & CAMPOS <= CAMPO
  if (sum(POSICAO)==1) {
    return (POSICAO)
  } else {
    posicoesMenores <- sum(CAMPOS <= CAMPO)-1
    return (c(rep(FALSE, posicoesMenores), TRUE, TRUE, rep(FALSE, length(CAMPOS) - posicoesMenores -2)))
  }
}

# Obtem dados interpolados de uma tabela (TMR, PDP, OFF-AXIS...)
obterDadosTabela <- function(TABELA, COLUNA, LINHA) {
  COLUNAS <- as.numeric(colnames(TABELA))
  LINHAS <- as.numeric(rownames(TABELA))
  OBSERVACOES <- as.data.frame(TABELA[obterPosicoes(LINHAS, LINHA),obterPosicoes(COLUNAS, COLUNA)])
  # LINHA
  if (dim(OBSERVACOES)[1]==2) {
    LINHA1 <- as.numeric(rownames(OBSERVACOES))[1]
    LINHA2 <- as.numeric(rownames(OBSERVACOES))[2]
    VALOR1 <- OBSERVACOES[1,]
    VALOR2 <- OBSERVACOES[2,]
    OBSERVACOES <- as.data.frame((VALOR1 + VALOR2)/2)
  }
  # COLUNA
  if (dim(OBSERVACOES)[2]==2) {
    COLUNA1 <- as.numeric(colnames(OBSERVACOES))[1]
    COLUNA2 <- as.numeric(colnames(OBSERVACOES))[2]
    VALOR1 <- OBSERVACOES[,1]
    VALOR2 <- OBSERVACOES[,2]
    OBSERVACOES <- as.data.frame((VALOR1 + VALOR2)/2)
  }
  return(as.numeric(OBSERVACOES))
}

# Obtem dados interpolados de uma tabela (TMR, PDP, OFF-AXIS...)
obterFatorFiltro <- function(TABELA_FATOR_FILTRO, FILTRO, CAMPO) {
  FILTROS <- as.numeric(colnames(TABELA_FATOR_FILTRO))
  CAMPOS <- as.numeric(rownames(TABELA_FATOR_FILTRO))
  OBSERVACOES <- as.data.frame(TABELA_FATOR_FILTRO[obterPosicoes(CAMPOS, CAMPO),obterPosicoes(FILTROS, FILTRO)])
  rownames(TABELA_FATOR_FILTRO[obterPosicoes(CAMPOS, CAMPO),])
  # CAMPO
  if (dim(OBSERVACOES)[1]==2) {
    CAMPO1 <- as.numeric(rownames(TABELA_FATOR_FILTRO[obterPosicoes(CAMPOS, CAMPO),])[1])
    CAMPO2 <- as.numeric(rownames(TABELA_FATOR_FILTRO[obterPosicoes(CAMPOS, CAMPO),])[2])
    VALOR1 <- OBSERVACOES[1,]
    VALOR2 <- OBSERVACOES[2,]
    OBSERVACOES <- as.data.frame(VALOR1 + (CAMPO-CAMPO1)*-(VALOR1-VALOR2)/(CAMPO2-CAMPO1))
  }
  return(as.numeric(OBSERVACOES))
}

# Obtem dados das tabelas de rendimento, onde os fatores sao: CAMPO = 1; ESPALHAMENTO = 2; RENDIMENTO = 3
obterDadosRendimento <- function(TABELA, CAMPO, FATOR) {
  CAMPOS <- TABELA$Campo
  OBSERVACOES <- as.data.frame(TABELA[obterPosicoes(CAMPOS, CAMPO), FATOR + 1])
  rownames(OBSERVACOES) <- TABELA$Campo[obterPosicoes(CAMPOS, CAMPO)]
  if (dim(OBSERVACOES)[1]==2) {
    CAMPO1 <- as.numeric(rownames(OBSERVACOES))[1]
    CAMPO2 <- as.numeric(rownames(OBSERVACOES))[2]
    VALOR1 <- OBSERVACOES[1,]
    VALOR2 <- OBSERVACOES[2,]
    OBSERVACOES <- as.data.frame(VALOR1 + (CAMPO-CAMPO1)*-(VALOR1-VALOR2)/(CAMPO2-CAMPO1))
  }
  return(as.numeric(OBSERVACOES))
}

# Obtem coordenadas do ponto de calculo
obterPontoCalculo <- function() {
  parametroDeBusca <- "X, Y"
  info <- NULL
  for (numeroDaPagina in 1:numeroDePaginas) {
    pagina <- retornarPagina(paginas, numeroDaPagina)
    numeroDaCOLUNA <- grep(parametroDeBusca, pagina)
    COLUNA <- strsplit(pagina[numeroDaCOLUNA], "  +")[[2]]
    if (COLUNA[1] == "") {
      info <- c(info, COLUNA[c(-1, -2)])
    } else {
      info <- c(info, COLUNA[-1])
    }
  }
  info <- as.data.frame(info)
  colnames(info) <- parametroDeBusca
  info <- sapply(info, function(x) {x <- gsub("/"," ",x)})
  info <- t(as.data.frame(strsplit(info, " ")))
  X <- as.numeric(info[,1])
  Y <- as.numeric(info[,2])
  Z <- as.numeric(info[,3])
  return(data.frame(X, Y, Z))
}

# OBTER PONTO DE CaLCULO QUANDO POSSUI BOLUS
obterPontoCalculoBOLUS <- function() {
  parametroDeBusca <- "X, Y, Z"
  info <- NULL
  for (numeroDaPagina in 1:numeroDePaginas) {
    pagina <- retornarPagina(paginas, numeroDaPagina)
    numeroDaCOLUNA <- grep(parametroDeBusca, pagina)[3]
    COLUNA <- strsplit(pagina[numeroDaCOLUNA], " ")[[1]][20]
    info <- c(info, COLUNA)
  }
  info <- as.data.frame(info)
  colnames(info) <- parametroDeBusca
  info <- sapply(info, function(x) {x <- gsub("/"," ",x)})
  info <- t(as.data.frame(strsplit(info, " ")))
  X <- as.numeric(info[,1])
  Y <- as.numeric(info[,2])
  Z <- as.numeric(info[,3])
  return(data.frame(X, Y, Z))
}

# Busca de parametros textuais dentro dos campos de pagina
buscaDeParametros <- function(parametroDeBusca) {
  info <- NULL
  for (numeroDaPagina in 1:numeroDePaginas) {
    pagina <- retornarPagina(paginas, numeroDaPagina)
    numeroDaCOLUNA <- grep(parametroDeBusca, pagina)
    COLUNA <- strsplit(pagina[numeroDaCOLUNA], "  +")[[1]]
    if (COLUNA[1] == "") {
      info <- c(info, COLUNA[c(-1, -2)])
    } else {
      info <- c(info, COLUNA[-1])
    }
  }
  info <- as.data.frame(info)
  colnames(info) <- parametroDeBusca
  return(info)
}

# Busca de parametros textuais dentro dos campos de pagina retornando a segunda instancia
buscaDeParametros_2 <- function(parametroDeBusca) {
  info <- NULL
  for (numeroDaPagina in 1:numeroDePaginas) {
    pagina <- retornarPagina(paginas, numeroDaPagina)
    numeroDaCOLUNA <- grep(parametroDeBusca, pagina)
    COLUNA <- strsplit(pagina[numeroDaCOLUNA], "  +")[[2]]
    if (COLUNA[1] == "") {
      info <- c(info, COLUNA[c(-1, -2)])
    } else {
      info <- c(info, COLUNA[-1])
    }
  }
  info <- as.data.frame(info)
  colnames(info) <- parametroDeBusca
  return(info)
}

# Busca de parametros numericos simples dentro dos campos de pagina
buscaDeParametrosNumericos <- function(parametroDeBusca) {
  info <- NULL
  for (numeroDaPagina in 1:numeroDePaginas) {
    pagina <- retornarPagina(paginas, numeroDaPagina)
    numeroDaCOLUNA <- grep(parametroDeBusca, pagina)
    COLUNA <- strsplit(pagina[numeroDaCOLUNA], "  +")[[1]]
    if (COLUNA[1] == "") {
      info <- c(info, as.numeric(COLUNA[c(-1, -2)]))
    } else {
      info <- c(info, as.numeric(COLUNA[-1]))
    }
  }
  info <- as.data.frame(info)
  colnames(info) <- parametroDeBusca
  return(info)
}

# Busca de parametros textuais dentro dos campos de pagina BOLUS
buscaDeParametrosBOLUS <- function(parametroDeBusca) {
  info <- NULL
  for (numeroDaPagina in 1:numeroDePaginas) {
    pagina <- retornarPagina(paginas, numeroDaPagina)
    numeroDaCOLUNA <- grep(parametroDeBusca, pagina)
    COLUNA <- strsplit(pagina[numeroDaCOLUNA], " +")[[1]]
    if (COLUNA[1] == "") {
      info <- c(info, COLUNA[c(-1, -2)])
    } else {
      info <- c(info, COLUNA[-1])
    }
  }
  info <- as.data.frame(info)
  colnames(info) <- parametroDeBusca
  return(info)
}

# Funcao implementada para ler PDP e TMR nos formatos expecificos fornecidos (pode nao se aplicar aos dados disponiveis para seu comissionamento)
lerPDP_TMR <- function(arquivo) {
  pdp <- read.delim2(arquivo, skip = 13, header = F, dec = ".")
  tamanhosDeCampo <- read.delim2(arquivo, skip = 12, header = F, dec = ".", nrows = 1)
  tamanhosDeCampo <- sapply(tamanhosDeCampo,function(x) {x <- gsub("-","",x)})
  tamanhosDeCampo <- sapply(tamanhosDeCampo,function(x) {x <- gsub("[.]","",x)})
  tamanhosDeCampo <- as.integer(tamanhosDeCampo)/10
  tamanhosDeCampo
  pdp <- pdp/100
  pdp[,1] <- pdp[,1]*10
  rownames(pdp) <- pdp[,1]
  pdp <- pdp[,-1]
  colnames(pdp) <- tamanhosDeCampo[-1]
  return(pdp)
}

# Retorna os valores do fator Off-axis de campo aberto fazendo a media entre os valores no eixo positivo e negativo de deslocamento
obterOFFAxisCampoAberto <- function(TABELA, COLUNA, LINHA) {
  return((obterDadosTabela(TABELA, COLUNA, LINHA) + obterDadosTabela(TABELA, COLUNA, -LINHA))/2)
}

# Busca para os tamanhos de campo para campos assimetricos e simetricos no XiO. Note que todos os campos tem que ser ou SIMeTRICOS ou ASSIMeTRICOS
TAMANHOS_DE_CAMPO <- function(paginas) {
  TMP <- t(as.data.frame(strsplit(sapply(buscaDeParametros("  Field Size"), function(x) {x <- gsub("/"," ",x)}), " ")))
  if (dim(TMP)[2] == 4) {
    TMP_X <- sapply(buscaDeParametros("X1/X2"), function(x) {x <- gsub("X1/X2","",x)})
    TMP_X <- t(as.data.frame(strsplit(TMP_X, "/")))
    TMP_Y <- sapply(buscaDeParametros("Y2/Y1"), function(x) {x <- gsub("Y2/Y1","",x)})
    TMP_Y <- t(as.data.frame(strsplit(TMP_Y, "/")))
    X1 <- as.numeric(TMP_X[,1])
    X2 <- as.numeric(TMP_X[,2])
    Y2 <- as.numeric(TMP_Y[,1])
    Y1 <- as.numeric(TMP_Y[,2])
    return(data.frame(X1, X2, Y1, Y2))
  } else {
    TMP_X <- sapply(buscaDeParametros(" Field Size"), function(x) {x <- gsub("X ","",x)})
    TMP_Y <- sapply(buscaDeParametros_2(" Field Size"), function(x) {x <- gsub("Y ","",x)})
    X <- as.numeric(TMP_X)
    Y <- as.numeric(TMP_Y)
    return(data.frame(X, Y))
  }
}

# Obtencao da distancia fonte-superficie (DFS)
obterSSD <- function() {
  DFS_SSD <- sapply(buscaDeParametros("SSD/Wt"), function(x) {x <- gsub("/"," ",x)})
  DFS_SSD <- t(as.data.frame(strsplit(DFS_SSD, " ")))
  DFS_SSD <- data.frame(as.numeric(DFS_SSD[,2])); colnames(DFS_SSD) <- "DFS_SSD"
  
  DFS_SAD <- sapply(buscaDeParametros("SCD"), function(x) {x <- gsub("/"," ",x)})
  DFS_SAD <- t(as.data.frame(strsplit(DFS_SAD, " ")))
  DFS_SAD <- data.frame(as.numeric(DFS_SAD[,2])); colnames(DFS_SAD) <- "DFS_SAD"
  
  SSD <- (SETUP == "SSD")*DFS_SSD + (SETUP == "SAD")*DFS_SAD
  
  return(SSD)
}

# Retorna o valor do fator Off-Axis na direcao da cunha para um campo com filtro
obterFatorFiltro_OFFAXIS <- function(ENERGIA, FILTRO, DIRECAO_CUNHA, PROFUNDIDADE, DISTANCIA)
{
  FOA_FILTRO <- NULL
  ORIENTACAO_CUNHA <- NULL
  if (DIRECAO_CUNHA == "Grossa") {
    ORIENTACAO_CUNHA <- -1
  } else ORIENTACAO_CUNHA <- 1
  
  if (ENERGIA == "6 MV")  {
    if (FILTRO == "15") FOA_FILTRO <- obterDadosTabela(TABELA = FOA_W15_06, LINHA = ORIENTACAO_CUNHA*DISTANCIA, COLUNA = PROFUNDIDADE)
    if (FILTRO == "30") FOA_FILTRO <- obterDadosTabela(TABELA = FOA_W30_06, LINHA = ORIENTACAO_CUNHA*DISTANCIA, COLUNA = PROFUNDIDADE)
    if (FILTRO == "45") FOA_FILTRO <- obterDadosTabela(TABELA = FOA_W45_06, LINHA = ORIENTACAO_CUNHA*DISTANCIA, COLUNA = PROFUNDIDADE)
    if (FILTRO == "60") FOA_FILTRO <- obterDadosTabela(TABELA = FOA_W60_06, LINHA = ORIENTACAO_CUNHA*DISTANCIA, COLUNA = PROFUNDIDADE)
  } else if (ENERGIA == "10 MV") {
    if (FILTRO == "15") FOA_FILTRO <- obterDadosTabela(TABELA = FOA_W15_10, LINHA = ORIENTACAO_CUNHA*DISTANCIA, COLUNA = PROFUNDIDADE)
    if (FILTRO == "30") FOA_FILTRO <- obterDadosTabela(TABELA = FOA_W30_10, LINHA = ORIENTACAO_CUNHA*DISTANCIA, COLUNA = PROFUNDIDADE)
    if (FILTRO == "45") FOA_FILTRO <- obterDadosTabela(TABELA = FOA_W45_10, LINHA = ORIENTACAO_CUNHA*DISTANCIA, COLUNA = PROFUNDIDADE)
    if (FILTRO == "60") FOA_FILTRO <- obterDadosTabela(TABELA = FOA_W60_10, LINHA = ORIENTACAO_CUNHA*DISTANCIA, COLUNA = PROFUNDIDADE)
  }
  return(FOA_FILTRO)
}

# Funcao generica para consulta das tabelas de calculo durante o calculo manual das UMs
dadosFicha <- function(TABELA, RENDIMENTO, TAMANHOCAMPO, EQUIVALENTE, PROFUNDIDADE) {
  return(rbind(obterDadosTabela(TABELA = TABELA, EQUIVALENTE, PROFUNDIDADE), obterDadosRendimento(TABELA = RENDIMENTO, TAMANHOCAMPO, FATOR = 1) , obterDadosRendimento(TABELA = RENDIMENTO, EQUIVALENTE, FATOR = 2)))
}