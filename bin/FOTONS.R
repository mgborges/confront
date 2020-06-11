# Se Não tiver Bolus...
if (length(grep("Bolus", texto)) == 0)
{
  # Fatores genéricos para fótons
  UM_XiO <- buscaDeParametrosNumericos("Integer MU")
  colnames (UM_XiO) <- "Dose Monitor"
  
  F_BANDEJA     <- buscaDeParametrosNumericos("Tray Factor")
  CAMPO_EQUIVALENTE_XiO   <- buscaDeParametrosNumericos("Coll. Eq.")
  # Para o caso de o campo ser aberto (e.g. Sem colimação)
  if (length(grep("Blk. Eq.", texto)) == 0)
  {
    Campo_COLIMADO_XiO <- CAMPO_EQUIVALENTE_XiO
  } else  Campo_COLIMADO_XiO <- buscaDeParametrosNumericos("Blk. Eq.")
  
  TAMANHOS_DE_CAMPO <- TAMANHOS_DE_CAMPO(paginas)
  
  # Filtos e orientação
  if (is.na(grep("Wedge ID", paginas)[1]) != TRUE)
  {
    FILTROS <- sapply(buscaDeParametros("Wedge ID"), function(x) {x <- gsub("/","  ",x)})
    FILTROS <- sapply(FILTROS, function(x) {x <- gsub("HC....","  ",x)})
    FILTROS <- t(as.data.frame(strsplit(FILTROS, " +")))
    ORIENTACAO_FILTROS <- FILTROS[,2] 
    ORIENTACAO_FILTROS <- sapply(ORIENTACAO_FILTROS, function(x) {x <- gsub("Toe-","",x)})
    ORIENTACAO_FILTROS <- as.data.frame(ORIENTACAO_FILTROS); colnames(ORIENTACAO_FILTROS) <- "Orientacao Filtros"; row.names(ORIENTACAO_FILTROS) <- NULL
    
    FILTROS <- matrix(sapply(FILTROS[,1], function(x) {x <- gsub("W", "",x)})); FILTROS <- as.data.frame(mapply(FILTROS, FUN=as.numeric)); colnames(FILTROS) <- "Filtros"; row.names(FILTROS) <- NULL
    
    FILTROS[is.na(FILTROS[,1]),1] <- "---"
    
    FILTROS_COM_ORIENTACAO <- cbind(FILTROS, ORIENTACAO_FILTROS)
    FILTROS_COM_ORIENTACAO <- paste0(FILTROS_COM_ORIENTACAO$Filtros, "-", FILTROS_COM_ORIENTACAO$`Orientacao Filtros`)
    FILTROS_COM_ORIENTACAO[FILTROS_COM_ORIENTACAO=="-------"] <- "---"
    FILTROS_COM_ORIENTACAO <- as.data.frame(FILTROS_COM_ORIENTACAO)
  } else {
    FILTROS <- as.data.frame(rep("---", dim(ENERGIA)[1])); colnames(FILTROS) <- "Filtros"; row.names(FILTROS) <- NULL
    ORIENTACAO_FILTROS <- as.data.frame(rep("---", dim(ENERGIA)[1])); colnames(ORIENTACAO_FILTROS) <- "Orientacao Filtros"; row.names(ORIENTACAO_FILTROS) <- NULL
    FILTROS_COM_ORIENTACAO <- as.data.frame(rep("---", dim(ENERGIA)[1])); colnames(FILTROS_COM_ORIENTACAO) <- "Filtros"; row.names(FILTROS_COM_ORIENTACAO) <- NULL
  }
  
  # Medidas de deslocamento OFF-AXIS com um campo aberto
  OFF_AXIS_CAMPO_ABERTO <- NULL
  for (i in 1:dim(PONTO_DE_CALCULO)[1])
  {
    G <- GANTRY[i,1] * pi/180 + pi/2
    M <- MESA[i,1] * pi/180 + pi/2
    ROT_GRANTRY <- rbind(c(sin(G), 0, -cos(G)), c(0,1,0), c(cos(G), 0, sin(G)))
    ROT_MESA <- rbind(c(sin(M), -cos(M), 0), c(cos(M), sin(M), 0), c(0,0,1))
    D <- ISO[i,] - PONTO_DE_CALCULO[i,]
    VETOR_DISTANCIA <- cbind(D$X, D$Y, D$Z)
    VETOR_RODADO <- VETOR_DISTANCIA %*% ROT_GRANTRY %*% ROT_MESA
    VETOR_PROJETADO <- VETOR_RODADO * (cbind(sin(G) , 1,  cos(G)) %*% ROT_GRANTRY)
    OFF_AXIS_CAMPO_ABERTO[i] <- sqrt(rowSums((VETOR_PROJETADO)^2))
  }
  OFF_AXIS_CAMPO_ABERTO <- as.data.frame(OFF_AXIS_CAMPO_ABERTO)
  
  # Medidas de deslocamento OFF-AXIS com um campo com filtro
  OFF_AXIS_FILTRO <- NULL
  DIRECAO_CUNHA <- NULL
  for (i in 1:dim(PONTO_DE_CALCULO)[1])
  {
    G <- GANTRY[i,1] * pi/180 + pi/2
    M <- MESA[i,1] * pi/180 + pi/2
    C <- COLIMADOR[i,1] * pi/180 + pi/2
    ROT_GRANTRY <- rbind(c(sin(G), 0, -cos(G)), c(0,1,0), c(cos(G), 0, sin(G)))
    ROT_MESA <- rbind(c(sin(M), cos(M), 0), c(-cos(M), sin(M), 0), c(0,0,1))
    ROT_COL <- rbind(c(sin(C), cos(C), 0), c(-cos(C), sin(C), 0), c(0,0,1))
    D <- ISO[i,] - PONTO_DE_CALCULO[i,]
    VETOR_DISTANCIA <- cbind(D$X, D$Y, D$Z)
    VETOR_RODADO <- VETOR_DISTANCIA %*% ROT_GRANTRY %*% ROT_MESA
    VETOR_PROJETADO <- VETOR_RODADO * (cbind(sin(G) , 1,  cos(G)) %*% ROT_GRANTRY %*% ROT_COL)
    
    VETOR_FILTRO <- cbind(1,0,0)
    if (rowSums(VETOR_PROJETADO*VETOR_FILTRO) > 0 & ORIENTACAO_FILTROS[i,1] == "Left")   {
      DIRECAO_CUNHA[i] <- "Grossa"
    } else if (rowSums(VETOR_PROJETADO*VETOR_FILTRO) < 0 & ORIENTACAO_FILTROS[i,1] == "Left")   {
      DIRECAO_CUNHA[i] <- "Fina"
    } else if (rowSums(VETOR_PROJETADO*VETOR_FILTRO) > 0 & ORIENTACAO_FILTROS[i,1] == "Right")   {
      DIRECAO_CUNHA[i] <- "Fina"
    } else if (rowSums(VETOR_PROJETADO*VETOR_FILTRO) < 0 & ORIENTACAO_FILTROS[i,1] == "Right")   {
      DIRECAO_CUNHA[i] <- "Grossa"
    } else if (rowSums(VETOR_PROJETADO*VETOR_FILTRO) > 0 & ORIENTACAO_FILTROS[i,1] == "Out")   {
      DIRECAO_CUNHA[i] <- "Grossa"
    } else if (rowSums(VETOR_PROJETADO*VETOR_FILTRO) < 0 & ORIENTACAO_FILTROS[i,1] == "Out")   {
      DIRECAO_CUNHA[i] <- "Fina"
    } else if (rowSums(VETOR_PROJETADO*VETOR_FILTRO) > 0 & ORIENTACAO_FILTROS[i,1] == "In")   {
      DIRECAO_CUNHA[i] <- "Fina"
    } else if (rowSums(VETOR_PROJETADO*VETOR_FILTRO) < 0 & ORIENTACAO_FILTROS[i,1] == "In")   {
      DIRECAO_CUNHA[i] <- "Grossa"
    } else   {
      VETOR_FILTRO <- cbind(1,1,1)
      DIRECAO_CUNHA[i] <- "---"
    }
    OFF_AXIS_FILTRO[i] <- sqrt(rowSums((VETOR_PROJETADO*VETOR_FILTRO)^2))
  }
  OFF_AXIS_FILTRO <- as.data.frame(OFF_AXIS_FILTRO)
  
  PDP_OU_TMR <- NULL
  F_DISTANCIA <- NULL
  SSD <- obterSSD()
  
  for (i in 1:NUMERO_CAMPOS)
  {
    if ((SETUP[i] == "SSD") & (ENERGIA[i,1] == "6 MV"))
    {
      PDP_OU_TMR[i] <- obterDadosTabela(TABELA = PDP_OPEN_06, COLUNA = Campo_COLIMADO_XiO[i,1], LINHA = PROFUNDIDADE[i,1])
      F_DISTANCIA[i] <- ((100 + 1.5)/(SSD[i,1] + 1.5))^2
    } else if ((SETUP[i] == "SSD") & (ENERGIA[i,1] == "10 MV"))
    {
      PDP_OU_TMR[i] <- obterDadosTabela(TABELA = PDP_OPEN_10, COLUNA = Campo_COLIMADO_XiO[i,1], LINHA = PROFUNDIDADE[i,1])
      F_DISTANCIA[i] <- ((100 + 2.5)/(SSD[i,1] + 2.5))^2
    } else if ((SETUP[i] == "SAD") & (ENERGIA[i,1] == "6 MV"))
    {
      PDP_OU_TMR[i] <- obterDadosTabela(TABELA = TMR_OPEN_06, COLUNA = Campo_COLIMADO_XiO[i,1], LINHA = PROFUNDIDADE[i,1])
      F_DISTANCIA[i] <- (100/SSD[i,1])^2
    } else if ((SETUP[i] == "SAD") & (ENERGIA[i,1] == "10 MV"))
    {
      PDP_OU_TMR[i] <- obterDadosTabela(TABELA = TMR_OPEN_10, COLUNA = Campo_COLIMADO_XiO[i,1], LINHA = PROFUNDIDADE[i,1])
      F_DISTANCIA[i] <- (100/SSD[i,1])^2
    } else 
    {
      PDP_OU_TMR[i] <- 1
      F_DISTANCIA[i] <- 1
    }
  }
  
  # FATORES COM DEPENDÊNCIA ENERGÉTICA
  F_ABERTURA_COLIMADOR <- NULL
  F_RETROESPALHAMENTO <- NULL
  F_FILTRO <- NULL
  F_OFF_AXIS <- NULL
  
  for (i in 1:NUMERO_CAMPOS)
  {
    if (ENERGIA[i,1] == "6 MV")
    {
      F_ABERTURA_COLIMADOR[i] <- obterDadosRendimento(TABELA = RENDIMENTO_06, CAMPO = CAMPO_EQUIVALENTE_XiO[i,1], FATOR = 1)
      F_RETROESPALHAMENTO[i] <- obterDadosRendimento(TABELA = RENDIMENTO_06, CAMPO = Campo_COLIMADO_XiO[i,1], FATOR = 2)
      # FATOR FILTRO e OFF-AXIS
      if (FILTROS[i,1] == "---")
      {
        F_FILTRO[i] <- 1
        if (ISO[i,] - PONTO_DE_CALCULO[i,] == c(0,0,0)) {
          F_OFF_AXIS[i] <- 1
        } else {
          F_OFF_AXIS[i] <- obterOFFAxisCampoAberto(TABELA = FOA_OPEN_06, COLUNA = PROFUNDIDADE[i,1], LINHA = OFF_AXIS_CAMPO_ABERTO[i,1])
        }
      } else {
        F_FILTRO[i] <- obterFatorFiltro(TABELA = FATOR_FILTRO_06, FILTRO = FILTROS[i,1], CAMPO = Campo_COLIMADO_XiO[i,1])
        if (ISO[i,] - PONTO_DE_CALCULO[i,] == c(0,0,0)) {
          F_OFF_AXIS[i] <- 1
        } else {
          F_OFF_AXIS[i] <- obterFatorFiltro_OFFAXIS(ENERGIA = ENERGIA[i,1], FILTRO = FILTROS[i,1], DIRECAO_CUNHA = DIRECAO_CUNHA[i], PROFUNDIDADE = PROFUNDIDADE[i,1], DISTANCIA = OFF_AXIS_FILTRO[i,1])
        }
      }
    } else if (ENERGIA[i,1] == "10 MV")
    {
      F_ABERTURA_COLIMADOR[i] <- obterDadosRendimento(TABELA = RENDIMENTO_10, CAMPO = CAMPO_EQUIVALENTE_XiO[i,1], FATOR = 1)
      F_RETROESPALHAMENTO[i] <- obterDadosRendimento(TABELA = RENDIMENTO_10, CAMPO = Campo_COLIMADO_XiO[i,1], FATOR = 2)
      # FATOR FILTRO e OFF-AXIS
      if (FILTROS[i,1] == "---")
      {
        F_FILTRO[i] <- 1
        if (ISO[i,] - PONTO_DE_CALCULO[i,] == c(0,0,0)) {
          F_OFF_AXIS[i] <- 1
        } else {
          F_OFF_AXIS[i] <- obterOFFAxisCampoAberto(TABELA = FOA_OPEN_06, COLUNA = PROFUNDIDADE[i,1], LINHA = OFF_AXIS_CAMPO_ABERTO[i,1])
        }
      } else {
        F_FILTRO[i] <- obterFatorFiltro(TABELA = FATOR_FILTRO_10, FILTRO = FILTROS[i,1], CAMPO = Campo_COLIMADO_XiO[i,1])
        if (ISO[i,] - PONTO_DE_CALCULO[i,] == c(0,0,0)) {
          F_OFF_AXIS[i] <- 1
        } else {
          F_OFF_AXIS[i] <- obterFatorFiltro_OFFAXIS(ENERGIA = ENERGIA[i,1], FILTRO = FILTROS[i,1], DIRECAO_CUNHA = DIRECAO_CUNHA[i], PROFUNDIDADE = PROFUNDIDADE[i,1], DISTANCIA = OFF_AXIS_FILTRO[i,1])
        }
      }
    }
  }
  
  F_CALIBRACAO <- obterFatorCalibracao()
  
  # CÁLCULO DIRETO PARA FÓTONS
  UM_CALCULADA <- (DOSE / FRACOES)/(PDP_OU_TMR * F_OFF_AXIS * F_CALIBRACAO * F_ABERTURA_COLIMADOR * F_RETROESPALHAMENTO * F_BANDEJA * F_FILTRO * F_DISTANCIA)
  UM_CALCULADA_INT <- round(UM_CALCULADA, digits=0)
  DESVIOS_DIRETO <- (1 - UM_XiO/UM_CALCULADA_INT) * 100
  
  # CALCULO INVERSO PARA FÓTONS
  DOSE_CALCULADA <- UM_XiO * FRACOES * PDP_OU_TMR * F_OFF_AXIS * F_CALIBRACAO * F_ABERTURA_COLIMADOR * F_RETROESPALHAMENTO * F_BANDEJA * F_FILTRO * F_DISTANCIA
  DESVIOS_INVERSO <- (1 - DOSE/DOSE_CALCULADA) * 100
  
  # Definição dos critérios de aprovação ou não do cálculo
  APROVACAO <- (abs(DESVIOS_DIRETO)>=DESVIO_ACEITO) + (abs(DESVIOS_INVERSO)>=DESVIO_ACEITO)
  APROVACAO[APROVACAO==0] <- "OK"
  APROVACAO[APROVACAO!="OK"] <- "ERRO"
} else {
  # Se tenho bolus...
  # Fatores genéricos para fótons
  PONTO_DE_CALCULO <- obterPontoCalculoBOLUS()
    
  UM_XiO <- t(as.data.frame(strsplit(sapply(buscaDeParametrosBOLUS("Integer MU")[3,], function(x) {x <- gsub("/"," ",x)}), " "))[2,])
  UM_XiO <- as.data.frame(as.numeric(as.character(UM_XiO[1,])))
  rownames (UM_XiO) <- NULL; colnames (UM_XiO) <- "Dose Monitor"
  
  DOSE <- t(as.data.frame(strsplit(sapply(buscaDeParametrosBOLUS("Weight ")[3,], function(x) {x <- gsub("/"," ",x)}), " "))[1,])
  DOSE <- as.data.frame(as.numeric(as.character(DOSE[1,])))
  rownames (DOSE) <- NULL; colnames (DOSE) <- "Dose"
  
  FRACOES <- t(as.data.frame(strsplit(sapply(buscaDeParametrosBOLUS("Weight ")[3,], function(x) {x <- gsub("/"," ",x)}), " "))[2,])
  FRACOES <- as.data.frame(as.numeric(as.character(FRACOES[1,])))
  rownames (FRACOES) <- NULL; colnames (FRACOES) <- "Frações"
  
  GANTRY <- t(as.data.frame(strsplit(sapply(buscaDeParametros("Gantry"), function(x) {x <- gsub("/"," ",x)}), " "))[1,])
  GANTRY <- as.data.frame(as.numeric(as.character(GANTRY[1,])))
  rownames (GANTRY) <- NULL; colnames (GANTRY) <- "Gantry"
  
  COLIMADOR <- t(as.data.frame(strsplit(sapply(buscaDeParametros("Gantry"), function(x) {x <- gsub("/"," ",x)}), " "))[2,])
  COLIMADOR <- as.data.frame(as.numeric(as.character(COLIMADOR[1,])))
  rownames (COLIMADOR) <- NULL; colnames (COLIMADOR) <- "Colimador"
  
  F_BANDEJA     <- buscaDeParametrosNumericos("Tray Factor")
  CAMPO_EQUIVALENTE_XiO   <- buscaDeParametrosNumericos("Coll. Eq.")
  
  # Para o caso de o campo ser aberto (e.g. Sem colimação)
  if (length(grep("Blk. Eq.", texto)) == 0)
  {
    Campo_COLIMADO_XiO <- CAMPO_EQUIVALENTE_XiO
  } else  Campo_COLIMADO_XiO <- buscaDeParametrosNumericos("Blk. Eq.")
  
  TAMANHOS_DE_CAMPO <- TAMANHOS_DE_CAMPO(paginas)
  
  # Filtos e orientação
  if (is.na(grep("Wedge ID", paginas)[1]) != TRUE)
  {
    FILTROS <- sapply(buscaDeParametros("Wedge ID"), function(x) {x <- gsub("/","  ",x)})
    FILTROS <- sapply(FILTROS, function(x) {x <- gsub("HC....","  ",x)})
    FILTROS <- t(as.data.frame(strsplit(FILTROS, " +")))
    ORIENTACAO_FILTROS <- FILTROS[,2] 
    ORIENTACAO_FILTROS <- sapply(ORIENTACAO_FILTROS, function(x) {x <- gsub("Toe-","",x)})
    ORIENTACAO_FILTROS <- as.data.frame(ORIENTACAO_FILTROS); colnames(ORIENTACAO_FILTROS) <- "Orientacao Filtros"; row.names(ORIENTACAO_FILTROS) <- NULL
    
    FILTROS <- matrix(sapply(FILTROS[,1], function(x) {x <- gsub("W", "",x)})); FILTROS <- as.data.frame(mapply(FILTROS, FUN=as.numeric)); colnames(FILTROS) <- "Filtros"; row.names(FILTROS) <- NULL
    
    FILTROS[is.na(FILTROS[,1]),1] <- "---"
    
    FILTROS_COM_ORIENTACAO <- cbind(FILTROS, ORIENTACAO_FILTROS)
    FILTROS_COM_ORIENTACAO <- paste0(FILTROS_COM_ORIENTACAO$Filtros, "-", FILTROS_COM_ORIENTACAO$`Orientacao Filtros`)
    FILTROS_COM_ORIENTACAO[FILTROS_COM_ORIENTACAO=="-------"] <- "---"
    FILTROS_COM_ORIENTACAO <- as.data.frame(FILTROS_COM_ORIENTACAO)
  } else {
    FILTROS <- as.data.frame(rep("---", dim(ENERGIA)[1])); colnames(FILTROS) <- "Filtros"; row.names(FILTROS) <- NULL
    ORIENTACAO_FILTROS <- as.data.frame(rep("---", dim(ENERGIA)[1])); colnames(ORIENTACAO_FILTROS) <- "Orientacao Filtros"; row.names(ORIENTACAO_FILTROS) <- NULL
    FILTROS_COM_ORIENTACAO <- as.data.frame(rep("---", dim(ENERGIA)[1])); colnames(FILTROS_COM_ORIENTACAO) <- "Filtros"; row.names(FILTROS_COM_ORIENTACAO) <- NULL
  }
  
  # Medidas de deslocamento OFF-AXIS com um campo aberto
  OFF_AXIS_CAMPO_ABERTO <- NULL
  for (i in 1:dim(PONTO_DE_CALCULO)[1])
  {
    G <- GANTRY[i,1] * pi/180 + pi/2
    M <- MESA[i,1] * pi/180 + pi/2
    ROT_GRANTRY <- rbind(c(sin(G), 0, -cos(G)), c(0,1,0), c(cos(G), 0, sin(G)))
    ROT_MESA <- rbind(c(sin(M), -cos(M), 0), c(cos(M), sin(M), 0), c(0,0,1))
    # PRECISO CONSIDERAR A ROTAÇÃO DO COLIMADOR????
    D <- ISO[i,] - PONTO_DE_CALCULO[i,]
    VETOR_DISTANCIA <- cbind(D$X, D$Y, D$Z)
    VETOR_RODADO <- VETOR_DISTANCIA %*% ROT_GRANTRY %*% ROT_MESA
    VETOR_PROJETADO <- VETOR_RODADO * (cbind(sin(G) , 1,  cos(G)) %*% ROT_GRANTRY)
    OFF_AXIS_CAMPO_ABERTO[i] <- sqrt(rowSums((VETOR_PROJETADO)^2))
  }
  OFF_AXIS_CAMPO_ABERTO <- as.data.frame(OFF_AXIS_CAMPO_ABERTO)
  
  # Medidas de deslocamento OFF-AXIS com um campo com filtro
  OFF_AXIS_FILTRO <- NULL
  DIRECAO_CUNHA <- NULL
  for (i in 1:dim(PONTO_DE_CALCULO)[1])
  {
    G <- GANTRY[i,1] * pi/180 + pi/2
    M <- MESA[i,1] * pi/180 + pi/2
    C <- COLIMADOR[i,1] * pi/180 + pi/2
    ROT_GRANTRY <- rbind(c(sin(G), 0, -cos(G)), c(0,1,0), c(cos(G), 0, sin(G)))
    ROT_MESA <- rbind(c(sin(M), cos(M), 0), c(-cos(M), sin(M), 0), c(0,0,1))
    ROT_COL <- rbind(c(sin(C), cos(C), 0), c(-cos(C), sin(C), 0), c(0,0,1))
    D <- ISO[i,] - PONTO_DE_CALCULO[i,]
    VETOR_DISTANCIA <- cbind(D$X, D$Y, D$Z)
    VETOR_RODADO <- VETOR_DISTANCIA %*% ROT_GRANTRY %*% ROT_MESA
    VETOR_PROJETADO <- VETOR_RODADO * (cbind(sin(G) , 1,  cos(G)) %*% ROT_GRANTRY %*% ROT_COL)
    
    VETOR_FILTRO <- cbind(1,0,0)
    if (rowSums(VETOR_PROJETADO*VETOR_FILTRO) > 0 & ORIENTACAO_FILTROS[i,1] == "Left")   {
      DIRECAO_CUNHA[i] <- "Grossa"
    } else if (rowSums(VETOR_PROJETADO*VETOR_FILTRO) < 0 & ORIENTACAO_FILTROS[i,1] == "Left")   {
      DIRECAO_CUNHA[i] <- "Fina"
    } else if (rowSums(VETOR_PROJETADO*VETOR_FILTRO) > 0 & ORIENTACAO_FILTROS[i,1] == "Right")   {
      DIRECAO_CUNHA[i] <- "Fina"
    } else if (rowSums(VETOR_PROJETADO*VETOR_FILTRO) < 0 & ORIENTACAO_FILTROS[i,1] == "Right")   {
      DIRECAO_CUNHA[i] <- "Grossa"
    } else if (rowSums(VETOR_PROJETADO*VETOR_FILTRO) > 0 & ORIENTACAO_FILTROS[i,1] == "Out")   {
      DIRECAO_CUNHA[i] <- "Grossa"
    } else if (rowSums(VETOR_PROJETADO*VETOR_FILTRO) < 0 & ORIENTACAO_FILTROS[i,1] == "Out")   {
      DIRECAO_CUNHA[i] <- "Fina"
    } else if (rowSums(VETOR_PROJETADO*VETOR_FILTRO) > 0 & ORIENTACAO_FILTROS[i,1] == "In")   {
      DIRECAO_CUNHA[i] <- "Fina"
    } else if (rowSums(VETOR_PROJETADO*VETOR_FILTRO) < 0 & ORIENTACAO_FILTROS[i,1] == "In")   {
      DIRECAO_CUNHA[i] <- "Grossa"
    } else   {
      VETOR_FILTRO <- cbind(1,1,1)
      DIRECAO_CUNHA[i] <- "---"
    }
    OFF_AXIS_FILTRO[i] <- sqrt(rowSums((VETOR_PROJETADO*VETOR_FILTRO)^2))
  }
  OFF_AXIS_FILTRO <- as.data.frame(OFF_AXIS_FILTRO)
  
  PDP_OU_TMR <- NULL
  F_DISTANCIA <- NULL

  SSD <- obterSSD()
  
  # Profundidade
  PROFUNDIDADE <- sapply(buscaDeParametrosBOLUS("Effective"), function(x) {x <- gsub("/"," ",x)})
  PROFUNDIDADE <- t(as.data.frame(strsplit(PROFUNDIDADE, " ")))
  PROFUNDIDADE <- data.frame(as.numeric(PROFUNDIDADE[2,2])); colnames(PROFUNDIDADE) <- "PROFUNDIDADE"
  
  for (i in 1:NUMERO_CAMPOS)
  {
    if ((SETUP[i] == "SSD") & (ENERGIA[i,1] == "6 MV"))
    {
      PDP_OU_TMR[i] <- obterDadosTabela(TABELA = PDP_OPEN_06, COLUNA = Campo_COLIMADO_XiO[i,1], LINHA = PROFUNDIDADE[i,1])
      F_DISTANCIA[i] <- ((100 + 1.5)/(SSD[i,1] + 1.5))^2
    } else if ((SETUP[i] == "SSD") & (ENERGIA[i,1] == "10 MV"))
    {
      PDP_OU_TMR[i] <- obterDadosTabela(TABELA = PDP_OPEN_10, COLUNA = Campo_COLIMADO_XiO[i,1], LINHA = PROFUNDIDADE[i,1])
      F_DISTANCIA[i] <- ((100 + 2.5)/(SSD[i,1] + 2.5))^2
    } else if ((SETUP[i] == "SAD") & (ENERGIA[i,1] == "6 MV"))
    {
      PDP_OU_TMR[i] <- obterDadosTabela(TABELA = TMR_OPEN_06, COLUNA = Campo_COLIMADO_XiO[i,1], LINHA = PROFUNDIDADE[i,1])
      F_DISTANCIA[i] <- (100/SSD[i,1])^2
    } else if ((SETUP[i] == "SAD") & (ENERGIA[i,1] == "10 MV"))
    {
      PDP_OU_TMR[i] <- obterDadosTabela(TABELA = TMR_OPEN_10, COLUNA = Campo_COLIMADO_XiO[i,1], LINHA = PROFUNDIDADE[i,1])
      F_DISTANCIA[i] <- (100/SSD[i,1])^2
    } else 
    {
      PDP_OU_TMR[i] <- 1
      F_DISTANCIA[i] <- 1
    }
  }
  
  # FATORES COM DEPENDÊNCIA ENERGÉTICA
  F_ABERTURA_COLIMADOR <- NULL
  F_RETROESPALHAMENTO <- NULL
  F_FILTRO <- NULL
  F_OFF_AXIS <- NULL
  
  for (i in 1:NUMERO_CAMPOS)
  {
    if (ENERGIA[i,1] == "6 MV")
    {
      F_ABERTURA_COLIMADOR[i] <- obterDadosRendimento(TABELA = RENDIMENTO_06, CAMPO = CAMPO_EQUIVALENTE_XiO[i,1], FATOR = 1)
      F_RETROESPALHAMENTO[i] <- obterDadosRendimento(TABELA = RENDIMENTO_06, CAMPO = Campo_COLIMADO_XiO[i,1], FATOR = 2)
      # FATOR FILTRO e OFF-AXIS
      if (FILTROS[i,1] == "---")
      {
        F_FILTRO[i] <- 1
        if (ISO[i,] - PONTO_DE_CALCULO[i,] == c(0,0,0)) {
          F_OFF_AXIS[i] <- 1
        } else {
          F_OFF_AXIS[i] <- obterOFFAxisCampoAberto(TABELA = FOA_OPEN_06, COLUNA = PROFUNDIDADE[i,1], LINHA = OFF_AXIS_CAMPO_ABERTO[i,1])
        }
      } else {
        F_FILTRO[i] <- obterFatorFiltro(TABELA = FATOR_FILTRO_06, FILTRO = FILTROS[i,1], CAMPO = Campo_COLIMADO_XiO[i,1])
        if (ISO[i,] - PONTO_DE_CALCULO[i,] == c(0,0,0)) {
          F_OFF_AXIS[i] <- 1
        } else {
          F_OFF_AXIS[i] <- obterFatorFiltro_OFFAXIS(ENERGIA = ENERGIA[i,1], FILTRO = FILTROS[i,1], DIRECAO_CUNHA = DIRECAO_CUNHA[i], PROFUNDIDADE = PROFUNDIDADE[i,1], DISTANCIA = OFF_AXIS_FILTRO[i,1])
        }
      }
    } else if (ENERGIA[i,1] == "10 MV")
    {
      F_ABERTURA_COLIMADOR[i] <- obterDadosRendimento(TABELA = RENDIMENTO_10, CAMPO = CAMPO_EQUIVALENTE_XiO[i,1], FATOR = 1)
      F_RETROESPALHAMENTO[i] <- obterDadosRendimento(TABELA = RENDIMENTO_10, CAMPO = Campo_COLIMADO_XiO[i,1], FATOR = 2)
      # FATOR FILTRO e OFF-AXIS
      if (FILTROS[i,1] == "---")
      {
        F_FILTRO[i] <- 1
        if (ISO[i,] - PONTO_DE_CALCULO[i,] == c(0,0,0)) {
          F_OFF_AXIS[i] <- 1
        } else {
          F_OFF_AXIS[i] <- obterOFFAxisCampoAberto(TABELA = FOA_OPEN_06, COLUNA = PROFUNDIDADE[i,1], LINHA = OFF_AXIS_CAMPO_ABERTO[i,1])
        }
      } else {
        F_FILTRO[i] <- obterFatorFiltro(TABELA = FATOR_FILTRO_10, FILTRO = FILTROS[i,1], CAMPO = Campo_COLIMADO_XiO[i,1])
        if (ISO[i,] - PONTO_DE_CALCULO[i,] == c(0,0,0)) {
          F_OFF_AXIS[i] <- 1
        } else {
          F_OFF_AXIS[i] <- obterFatorFiltro_OFFAXIS(ENERGIA = ENERGIA[i,1], FILTRO = FILTROS[i,1], DIRECAO_CUNHA = DIRECAO_CUNHA[i], PROFUNDIDADE = PROFUNDIDADE[i,1], DISTANCIA = OFF_AXIS_FILTRO[i,1])
        }
      }
    }
  }
  
  F_CALIBRACAO <- obterFatorCalibracao()
  
  # CÁLCULO DIRETO PARA FÓTONS
  UM_CALCULADA <- (DOSE / FRACOES)/(PDP_OU_TMR * F_OFF_AXIS * F_CALIBRACAO * F_ABERTURA_COLIMADOR * F_RETROESPALHAMENTO * F_BANDEJA * F_FILTRO * F_DISTANCIA)
  UM_CALCULADA_INT <- round(UM_CALCULADA, digits=0)
  DESVIOS_DIRETO <- (1 - UM_XiO/UM_CALCULADA_INT) * 100
  
  # CALCULO INVERSO PARA FÓTONS
  # Este desvio deve ser calculado para as unidades que serão entregues 
  # para o paciente, no caso, as do XiO
  DOSE_CALCULADA <- UM_XiO * FRACOES * PDP_OU_TMR * F_OFF_AXIS * F_CALIBRACAO * F_ABERTURA_COLIMADOR * F_RETROESPALHAMENTO * F_BANDEJA * F_FILTRO * F_DISTANCIA
  DESVIOS_INVERSO <- (1 - DOSE/DOSE_CALCULADA) * 100
  
  # Definição dos critérios de aprovação ou não do cálculo
  APROVACAO <- (abs(DESVIOS_DIRETO)>=DESVIO_ACEITO) + (abs(DESVIOS_INVERSO)>=DESVIO_ACEITO)
  APROVACAO[APROVACAO==0] <- "OK"
  APROVACAO[APROVACAO!="OK"] <- "ERRO"
}

GANTRY_COLIMADOR_MESA <- cbind(GANTRY, COLIMADOR, MESA)
GANTRY_COLIMADOR_MESA <- as.data.frame(paste(GANTRY_COLIMADOR_MESA$Gantry, GANTRY_COLIMADOR_MESA$Colimador, GANTRY_COLIMADOR_MESA$Mesa, sep = "/"))