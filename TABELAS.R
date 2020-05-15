# Extraindo informações

## PDP
PDP_OPEN_10 <- lerPDP_TMR("../Comissionamento_AL_2010/TRABALHADOS/10X/TABELAS/PDP-OPEN-10X.tab")
PDP_OPEN_06 <- lerPDP_TMR("../Comissionamento_AL_2010/TRABALHADOS/6X/TABELAS/PDP_OPEN_6X.tab")

# TMR
TMR_OPEN_10 <- lerPDP_TMR("../Comissionamento_AL_2010/TRABALHADOS/10X/TABELAS/TMR-OPEN-10X.tab")
TMR_OPEN_06 <- lerPDP_TMR("../Comissionamento_AL_2010/TRABALHADOS/6X/TABELAS/TMR_OPEN_6X.tab")

## OFF-AXIS
FOA_OPEN_10 <- lerPDP_TMR("../Comissionamento_AL_2010/TRABALHADOS/10X/TABELAS/FOA-OPEN-10X.tab")
FOA_W15_10 <- lerPDP_TMR("../Comissionamento_AL_2010/TRABALHADOS/10X/TABELAS/FOA-W15-10X.tab")
FOA_W30_10 <- lerPDP_TMR("../Comissionamento_AL_2010/TRABALHADOS/10X/TABELAS/FOA-W30-10X.tab")
FOA_W45_10 <- lerPDP_TMR("../Comissionamento_AL_2010/TRABALHADOS/10X/TABELAS/FOA-W45-10X.tab")
FOA_W60_10 <- lerPDP_TMR("../Comissionamento_AL_2010/TRABALHADOS/10X/TABELAS/FOA-W60-10X.tab")
FOA_OPEN_06 <- lerPDP_TMR("../Comissionamento_AL_2010/TRABALHADOS/6X/TABELAS/FOA_OPEN_6X.tab")
FOA_W15_06 <- lerPDP_TMR("../Comissionamento_AL_2010/TRABALHADOS/6X/TABELAS/FOA_W15_6X.tab")
FOA_W30_06 <- lerPDP_TMR("../Comissionamento_AL_2010/TRABALHADOS/6X/TABELAS/FOA_W30_6X.tab")
FOA_W45_06 <- lerPDP_TMR("../Comissionamento_AL_2010/TRABALHADOS/6X/TABELAS/FOA_W45_6X.tab")
FOA_W60_06 <- lerPDP_TMR("../Comissionamento_AL_2010/TRABALHADOS/6X/TABELAS/FOA_W60_6X.tab")

## RENDIMENTO
RENDIMENTO_06 <- read.csv("../Comissionamento_AL_2010/RENDIMENTO_6MV.csv", header = T, sep = ";")
RENDIMENTO_10 <- read.csv("../Comissionamento_AL_2010/RENDIMENTO_10MV.csv", header = T, sep = ";")

## ELETRONS
ELETRONS <- read.csv("../Comissionamento_AL_2010/ELETRONS.csv", sep = ",", header = T)
ELETRONS_CONES <- ELETRONS[-1,1]
ELETRONS <- as.data.frame(ELETRONS[-1,-1])
colnames(ELETRONS) <- c(4, 6, 9, 12, 15)
rownames(ELETRONS) <- ELETRONS_CONES

## FILTRO
FATOR_FILTRO_06 <- read.csv("../Comissionamento_AL_2010/FATOR_FILTRO_06.csv", sep = ",", header = T)
FATOR_FILTRO_06_CONES <- as.numeric(FATOR_FILTRO_06[,1])
FATOR_FILTRO_06 <- as.data.frame(FATOR_FILTRO_06[,-1])
colnames(FATOR_FILTRO_06) <- c(15.0, 30.0, 45.0, 60.0)
rownames(FATOR_FILTRO_06) <- FATOR_FILTRO_06_CONES

FATOR_FILTRO_10 <- read.csv("../Comissionamento_AL_2010/FATOR_FILTRO_10.csv", sep = ",", header = T)
FATOR_FILTRO_10_CONES <- as.numeric(FATOR_FILTRO_10[,1])
FATOR_FILTRO_10 <- as.data.frame(FATOR_FILTRO_10[,-1])
colnames(FATOR_FILTRO_10) <- c(15.0, 30.0, 45.0, 60.0)
rownames(FATOR_FILTRO_10) <- FATOR_FILTRO_10_CONES

# SALVANDO IMAGEM DO R
save.image(file = "TABELAS.RData")