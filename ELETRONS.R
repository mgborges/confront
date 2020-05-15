# Se não tenho Bolus...
if (length(grep("Bolus", texto)) == 0)
{
  # Tamanho do cone de elétrons
  CONE <- buscaDeParametrosNumericos('Field Size [(]')
  
  # SSD ELETRONS
  SSD <- sapply(buscaDeParametros("SSD"), function(x) {x <- gsub("/"," ",x)})
  SSD <- t(as.data.frame(strsplit(SSD, " ")))
  SSD <- data.frame(as.numeric(SSD[,2])); colnames(SSD) <- "SSD"
  
  # Fator para campos de elétrons do XiO
  F_ELETRONS_XiO <- buscaDeParametrosNumericos('At effective')/100
  
  # Unidades monitoras do XiO
  UM_XiO <- buscaDeParametrosNumericos("Integer MU")
  colnames (UM_XiO) <- "Dose Monitor"
  
  F_RENDIMENTO_ELETRONS <- NULL
  F_DISTANCIA <- NULL
  for (i in 1:NUMERO_CAMPOS)
  {
    VALOR_ENERGIA <- sapply(ENERGIA[i,1], function(x) {x <- gsub(" MeV", "",x)})
    VALOR_CONE <- as.character(CONE[i,1])
    F_RENDIMENTO_ELETRONS[i] <- ELETRONS[VALOR_CONE, VALOR_ENERGIA]
    F_DISTANCIA[i] <- ((100 + PROFUNDIDADE[i,1])/(SSD[i,1] + PROFUNDIDADE[i,1]))^2
  }
  
  # CALCULO DIRETO PARA ELÉTRONS
  UM_CALCULADA <- (DOSE / FRACOES) / (F_RENDIMENTO_ELETRONS * F_ELETRONS_XiO * F_DISTANCIA)
  UM_CALCULADA_INT <- round(UM_CALCULADA, digits=0)
  DESVIOS_DIRETO <- (1 - UM_XiO/UM_CALCULADA_INT) * 100
  
  # CALCULO INVERSO PARA ELÉTRONS
  DOSE_CALCULADA <- (UM_XiO * FRACOES) * (F_RENDIMENTO_ELETRONS * F_ELETRONS_XiO * F_DISTANCIA)
  DESVIOS_INVERSO <- (1 - DOSE/DOSE_CALCULADA) * 100
  
  # Definição dos critérios de aprovação ou não do cálculo
  APROVACAO <- (abs(DESVIOS_DIRETO)>=DESVIO_ACEITO) + (abs(DESVIOS_INVERSO)>=DESVIO_ACEITO)
  APROVACAO[APROVACAO==0] <- "OK"
  APROVACAO[APROVACAO!="OK"] <- "ERRO"
} else {
  # SE TENHO BOLUS...
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
  
  CONE <- buscaDeParametrosNumericos('Field Size [(]')
  
  # Fator para campos de elétrons do XiO
  F_ELETRONS_XiO <- t(as.data.frame(strsplit(sapply(buscaDeParametrosBOLUS("At effective")[2,], function(x) {x <- gsub("/"," ",x)}), " "))[3,])
  F_ELETRONS_XiO <- as.data.frame(as.numeric(as.character(F_ELETRONS_XiO[1,])))
  rownames (F_ELETRONS_XiO) <- NULL; colnames (F_ELETRONS_XiO) <- "Colimador"
  F_ELETRONS_XiO <- F_ELETRONS_XiO/100
  
  # SSD ELETRONS
  SSD <- sapply(buscaDeParametros("SSD"), function(x) {x <- gsub("/"," ",x)})
  SSD <- t(as.data.frame(strsplit(SSD, " ")))
  SSD <- data.frame(as.numeric(SSD[,2])); colnames(SSD) <- "SSD"
  
  UM_XiO <- strsplit(sapply(buscaDeParametros("Integer MU"), function(x) {x <- gsub("/"," ",x)}), " ")[[1]][4]
  UM_XiO <- as.data.frame(as.numeric(UM_XiO))
  rownames (UM_XiO) <- NULL; colnames (UM_XiO) <- "Dose Monitor"
  
  # Profundidade
  PROFUNDIDADE <- sapply(buscaDeParametrosBOLUS("Effective"), function(x) {x <- gsub("/"," ",x)})
  PROFUNDIDADE <- t(as.data.frame(strsplit(PROFUNDIDADE, " ")))
  PROFUNDIDADE <- data.frame(as.numeric(PROFUNDIDADE[2,2])); colnames(PROFUNDIDADE) <- "PROFUNDIDADE"
  
  F_RENDIMENTO_ELETRONS <- NULL
  F_DISTANCIA <- NULL
  for (i in 1:NUMERO_CAMPOS)
  {
    VALOR_ENERGIA <- sapply(ENERGIA[i,1], function(x) {x <- gsub(" MeV", "",x)})
    VALOR_CONE <- as.character(CONE[i,1])
    F_RENDIMENTO_ELETRONS[i] <- ELETRONS[VALOR_CONE, VALOR_ENERGIA]
    F_DISTANCIA[i] <- ((100 + PROFUNDIDADE[i,1])/(SSD[i,1] + PROFUNDIDADE[i,1]))^2
  }
  
  # CALCULO DIRETO PARA ELÉTRONS
  UM_CALCULADA <- (DOSE / FRACOES) / (F_RENDIMENTO_ELETRONS * F_ELETRONS_XiO * F_DISTANCIA)
  UM_CALCULADA_INT <- round(UM_CALCULADA, digits=0)
  DESVIOS_DIRETO <- (1 - UM_XiO/UM_CALCULADA_INT) * 100
  
  # CALCULO INVERSO PARA ELÉTRONS
  DOSE_CALCULADA <- (UM_XiO * FRACOES) * (F_RENDIMENTO_ELETRONS * F_ELETRONS_XiO * F_DISTANCIA)
  DESVIOS_INVERSO <- (1 - DOSE/DOSE_CALCULADA) * 100
  
  # Definição dos critérios de aprovação ou não do cálculo
  APROVACAO <- (abs(DESVIOS_DIRETO)>=DESVIO_ACEITO) + (abs(DESVIOS_INVERSO)>=DESVIO_ACEITO)
  APROVACAO[APROVACAO==0] <- "OK"
  APROVACAO[APROVACAO!="OK"] <- "ERRO"
} 

GANTRY_COLIMADOR_MESA <- cbind(GANTRY, COLIMADOR, MESA)
GANTRY_COLIMADOR_MESA <- as.data.frame(paste(GANTRY_COLIMADOR_MESA$Gantry, GANTRY_COLIMADOR_MESA$Colimador, GANTRY_COLIMADOR_MESA$Mesa, sep = "/"))