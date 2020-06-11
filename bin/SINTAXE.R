# Define a energia dos feixes empregados
# Note que o nome dos feixes é dado pelo usuário, e pode variar
ENERGIA     <- as.data.frame(sapply(buscaDeParametros("Machine"), function(x) {x <- gsub("HC6MVatual","6 MV",x)}))
ENERGIA     <- as.data.frame(sapply(ENERGIA, function(x) {x <- gsub("HC10MVatual","10 MV",x)}))
ENERGIA     <- as.data.frame(sapply(ENERGIA, function(x) {x <- gsub("E04HC","4 MeV",x)}))
ENERGIA     <- as.data.frame(sapply(ENERGIA, function(x) {x <- gsub("E06HC","6 MeV",x)}))
ENERGIA     <- as.data.frame(sapply(ENERGIA, function(x) {x <- gsub("E09HC","9 MeV",x)}))
ENERGIA     <- as.data.frame(sapply(ENERGIA, function(x) {x <- gsub("E12HC","12 MeV",x)}))
ENERGIA     <- as.data.frame(sapply(ENERGIA, function(x) {x <- gsub("E15HC","15 MeV",x)}))
colnames(ENERGIA) <- "Energia"
rownames(ENERGIA) <- NULL

# Define o tipo de feixe (fótons ou elétrons)
# O usuário deve adicionar ou modificar as energias conforme a disponibilidade
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

# OBTER FATORES DE CALIBRAÇÃO (Deve ser ajustado conforme calibração no comissionamento)
obterFatorCalibracao <- function() {
  ## Profundidade de máximo
  PROFUNDIADE_MAX <- (ENERGIA == "6 MV")*1.5 + (ENERGIA == "10 MV")*2.5
  FATOR_CALIBRACAO <- ((100 + PROFUNDIADE_MAX)/100)^2
  FATOR_CALIBRACAO[SETUP == "SSD"] <- 1
  colnames(FATOR_CALIBRACAO) <- "Fator de Calibração"
  return(FATOR_CALIBRACAO)
}

# Desvio percentual aceitável para o desvio no cálculo para cada campo
# Ex.: 3% considerado para este serviço, lembrando que esta é a variação por campo, não no isocentro
DESVIO_ACEITO <- 3