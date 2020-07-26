# Define a energia dos feixes empregados
# Note que o nome dos feixes e dado pelo usuario vai variar
ENERGIA     <- as.data.frame(sapply(buscaDeParametros("Machine"), function(x) {x <- gsub("HC6MVatual","6 MV",x)}))
ENERGIA     <- as.data.frame(sapply(ENERGIA, function(x) {x <- gsub("HC10MVatual","10 MV",x)}))
ENERGIA     <- as.data.frame(sapply(ENERGIA, function(x) {x <- gsub("E04HC","4 MeV",x)}))
ENERGIA     <- as.data.frame(sapply(ENERGIA, function(x) {x <- gsub("E06HC","6 MeV",x)}))
ENERGIA     <- as.data.frame(sapply(ENERGIA, function(x) {x <- gsub("E09HC","9 MeV",x)}))
ENERGIA     <- as.data.frame(sapply(ENERGIA, function(x) {x <- gsub("E12HC","12 MeV",x)}))
ENERGIA     <- as.data.frame(sapply(ENERGIA, function(x) {x <- gsub("E15HC","15 MeV",x)}))
colnames(ENERGIA) <- "Energia"
rownames(ENERGIA) <- NULL

# Define o tipo de feixe (fotons ou eletrons)
# O usuario deve adicionar ou modificar as energias conforme a disponibilidade
TIPOFEIXE <- ENERGIA
TIPOFEIXE     <- as.data.frame(sapply(TIPOFEIXE, function(x) {x <- gsub("6 MV", "FOTONS",x)}))
TIPOFEIXE     <- as.data.frame(sapply(TIPOFEIXE, function(x) {x <- gsub("10 MV", "FOTONS",x)}))
TIPOFEIXE     <- as.data.frame(sapply(TIPOFEIXE, function(x) {x <- gsub("4 MeV", "ELETRONS",x)}))
TIPOFEIXE     <- as.data.frame(sapply(TIPOFEIXE, function(x) {x <- gsub("6 MeV", "ELETRONS",x)}))
TIPOFEIXE     <- as.data.frame(sapply(TIPOFEIXE, function(x) {x <- gsub("9 MeV", "ELETRONS",x)}))
TIPOFEIXE     <- as.data.frame(sapply(TIPOFEIXE, function(x) {x <- gsub("12 MeV", "ELETRONS",x)}))
TIPOFEIXE     <- as.data.frame(sapply(TIPOFEIXE, function(x) {x <- gsub("15 MeV", "ELETRONS",x)}))
colnames(TIPOFEIXE) <- "Tipo do Feixe"
rownames(TIPOFEIXE) <- NULL

# OBTER FATORES DE CALIBRAcaO (Deve ser ajustado conforme calibracao no comissionamento)
obterFatorCalibracao <- function() {
  ## Profundidade de maximo
  PROFUNDIADE_MAX <- (ENERGIA == "6 MV")*1.5 + (ENERGIA == "10 MV")*2.5
  FATOR_CALIBRACAO <- ((100 + PROFUNDIADE_MAX)/100)^2
  FATOR_CALIBRACAO[SETUP == "SSD"] <- 1
  colnames(FATOR_CALIBRACAO) <- "Fator de Calibracao"
  return(FATOR_CALIBRACAO)
}

# Desvio percentual aceitavel para o desvio no calculo para cada campo
# Ex.: 3% considerado para este servico, lembrando que esta e a variacao por campo, nao no isocentro
DESVIO_ACEITO <- 3