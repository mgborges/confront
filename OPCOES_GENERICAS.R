# Identificação do número de campos no qual ocorre a iteração
NUMERO_CAMPOS <- dim(ENERGIA)[1]

# Informações que constam no cabeçalho do PDF
CABECALHO <- retornarCabecalho(paginas, 1)
NOME_PACIENTE <- as.character(sapply(CABECALHO[grep("Name", retornarCabecalho(paginas, 1))], function(x) {x <- gsub("Name: ","",x)}))

HC <- as.numeric(sapply(CABECALHO[grep("Patient ID", retornarCabecalho(paginas, 1))], function(x) {x <- gsub("Patient ID: ","",x)}))

ID_PLANO <- as.character(sapply(CABECALHO[grep("Plan ID", retornarCabecalho(paginas, 1))], function(x) {x <- gsub("Plan ID: ","",x)}))
DESCRICAO_PLANO <- as.character(sapply(CABECALHO[grep("Plan description", retornarCabecalho(paginas, 1))], function(x) {x <- gsub("Plan description: ","",x)}))
if(DESCRICAO_PLANO == "Plan description:") DESCRICAO_PLANO <- "---"
if(ID_PLANO == "Plan ID:") ID_PLANO <- "---"

DATA_APROVACAO_PLANO <- as.character(sapply(CABECALHO[grep("Treatment Date", retornarCabecalho(paginas, 1))], function(x) {x <- gsub("Treatment Date: ","",x)}))

# Define se o setup é SSD ou SAD
SETUP <- t(as.data.frame(strsplit(sapply(buscaDeParametros("Setup"), function(x) {x <- gsub("/"," ",x)}), " "))[1,])
rownames (SETUP) <- NULL; colnames (SETUP) <- "Setup"

# Retorna o nome do campo, se disponível
NOME_CAMPO  <- buscaDeParametros("Description")
if (dim(NOME_CAMPO)[1]!=dim(ENERGIA)[1]) {
  NOME_CAMPO <- as.data.frame(rep("---", dim(ENERGIA)[1])); row.names(NOME_CAMPO) <- NULL
}
colnames(NOME_CAMPO) <- "Nome do Campo"

# Angulação da mesa
MESA <- buscaDeParametrosNumericos("Couch")
colnames(MESA) <- "Mesa"

# Profundidade do cálculo
PROFUNDIDADE <- buscaDeParametrosNumericos("Effective; skin")
colnames(PROFUNDIDADE) <- "Profundidade"

# Obtem coordenadas do isocentro
ISO <- sapply(buscaDeParametros("X, Y"), function(x) {x <- gsub("/"," ",x)})
ISO <- t(as.data.frame(strsplit(ISO, " ")))
X <- as.numeric(ISO[,1])
Y <- as.numeric(ISO[,2])
Z <- as.numeric(ISO[,3])
ISO <- data.frame(X, Y, Z)

# Coordenada do ponto de cálculo
PONTO_DE_CALCULO <- obterPontoCalculo()

# Numero dos campos inseridos no XiO
if (numeroDePaginas > 1)
{
  NUMERO_CAMPO_XIO <- NULL
  for (i in 1:numeroDePaginas)
  {
    pagina <- paginas[[i]]
    linha <- grep("Beam Number", pagina)+1
    info_linha <- strsplit(sapply(pagina[linha], function(x) {x <- gsub("  +"," ",x)}), " ")[[1]][-1]
    NUMERO_CAMPO_XIO <- c(NUMERO_CAMPO_XIO, info_linha)
  }
} else {
  NUMERO_CAMPO_XIO <- data.frame(strsplit(sapply(paginas[grep("Beam Number", paginas)+1,], function(x) {x <- gsub("  +"," ",x)}), " "))[-1,]
}

# Algoritmo de cálculo
ALGORITMO_CALCULO <- buscaDeParametros("Calc algorithm")
ALGORITMO_CALCULO <- as.data.frame(sapply(ALGORITMO_CALCULO, function(x) {x <- gsub("Convolution","Conv.",x)}))
ALGORITMO_CALCULO <- as.data.frame(sapply(ALGORITMO_CALCULO, function(x) {x <- gsub("Clarkson","Clark.",x)}))
