--EXEMPLO DE UTILIZA��O DE TABELAS TEMPOR�RIAS, PARA EXTRA��O COMPLEXA

--========================================================================================================================
IF OBJECT_ID('TEMPDB.DBO.#INDE','U') IS NOT NULL
 DROP TABLE #INDE;

SELECT 
	REPLACE(REPLACE(REPLACE(CODIGO_CLIENTE,'.',''),'-',''),'/','') AS CPF_CNPJ
	,COUNT(ASSUNTO_PROCESSO) AS QTDE
INTO #INDE

FROM [TABULACOES].[TB_TABULACOES_DIARIAS_DETALHE]

WHERE
	ASSUNTO_PROCESSO IN (
'CLIENTE ENCERROU A LIGA��O',
'PREFERE AG�NCIA',
'N�O DESEJA CONTATO DO CALL CENTER',
'PREFERE INTERNET',
'CR�DITO - SEM INTERESSE',
'CR�DITO - PREFERE AG�NCIA',
'CR�DITO - CLIENTE RETORNA CONTATO',
'CLIENTE INSATISFEITO',
'CREDITO - CLIENTE INSATISFEITO',
'PRE�O ALTO'
)
	AND OPERACAO = 'CR�DITO PROTEGIDO'
	AND DATA BETWEEN '2019-01-01' AND '2019-12-31'
	AND ORIGEM_TABULACAO NOT IN ('CRED INADIMPL�NCIA ATV','CRED INADIMPL�NCIA ATV MAN','CRED INADIMPL�NCIA RECP')

GROUP BY
	REPLACE(REPLACE(REPLACE(CODIGO_CLIENTE,'.',''),'-',''),'/','') 

ORDER BY 
	COUNT(ASSUNTO_PROCESSO) DESC

--==============================================================================================================================
IF OBJECT_ID('TEMPDB.DBO.#ML','U') IS NOT NULL
 DROP TABLE #ML;

SELECT
	CAST(#INDE.CPF_CNPJ AS FLOAT) AS CPF_CNPJ
	,MAILING
INTO #ML

FROM #INDE
INNER JOIN [TABULACOES].[TB_TABULACOES_DIARIAS_DETALHE] ON #INDE.CPF_CNPJ = REPLACE(REPLACE(REPLACE([TABULACOES].[TB_TABULACOES_DIARIAS_DETALHE].CODIGO_CLIENTE,'.',''),'-',''),'/','')

WHERE	
	OPERACAO = 'CR�DITO PROTEGIDO'
	AND DATA BETWEEN '2019-01-01' AND '2019-12-31'
	AND MAILING NOT IN ('','0')
	AND ORIGEM_TABULACAO NOT IN ('CRED INADIMPL�NCIA ATV','CRED INADIMPL�NCIA ATV MAN','CRED INADIMPL�NCIA RECP')

GROUP BY
 	CAST(#INDE.CPF_CNPJ AS FLOAT)
	,MAILING
--==============================================================================================================================
IF OBJECT_ID('TEMPDB.DBO.#ML2','U') IS NOT NULL
 DROP TABLE #ML2;
SELECT
	#ML.CPF_CNPJ
	,COUNT(#ML.MAILING) AS QTDE_MAILINGS
INTO #ML2

FROM #ML

GROUP BY
	#ML.CPF_CNPJ
--==============================================================================================================================
IF OBJECT_ID('TEMPDB.DBO.#LIGA','U') IS NOT NULL
 DROP TABLE #LIGA;

SELECT
	#ML.CPF_CNPJ
	,QUANT_TENTATIVAS
	,MAX(DATA_EXTRACAO) AS DATA
INTO #LIGA

FROM #ML
INNER JOIN [MAILLING].[TB_MAILLING] ON (#ML.MAILING = [MAILLING].[TB_MAILLING].MAILING_ID)

GROUP BY
	#ML.CPF_CNPJ
	,QUANT_TENTATIVAS

ORDER BY
	SUM(QUANT_TENTATIVAS) DESC
--==============================================================================================================================
IF OBJECT_ID('TEMPDB.DBO.#LIGA2','U') IS NOT NULL
 DROP TABLE #LIGA2;

SELECT
	CPF_CNPJ
	,SUM(QUANT_TENTATIVAS) AS QUANT_TENTATIVAS
INTO #LIGA2

FROM #LIGA

GROUP BY
	CPF_CNPJ
--==============================================================================================================================
IF OBJECT_ID('TEMPDB.DBO.#OUT','U') IS NOT NULL
 DROP TABLE #OUT;

SELECT
	CAST(#INDE.CPF_CNPJ AS FLOAT) AS CPF_CNPJ
	,COUNT(ASSUNTO_PROCESSO) AS QTDE_OUT_TAB
INTO #OUT

FROM #INDE
INNER JOIN [TABULACOES].[TB_TABULACOES_DIARIAS_DETALHE] ON #INDE.CPF_CNPJ = REPLACE(REPLACE(REPLACE([TABULACOES].[TB_TABULACOES_DIARIAS_DETALHE].CODIGO_CLIENTE,'.',''),'-',''),'/','')

WHERE
	ASSUNTO_PROCESSO NOT IN (
'CLIENTE ENCERROU A LIGA��O',
'PREFERE AG�NCIA',
'N�O DESEJA CONTATO DO CALL CENTER',
'PREFERE INTERNET',
'CR�DITO - SEM INTERESSE',
'CR�DITO - PREFERE AG�NCIA',
'CR�DITO - CLIENTE RETORNA CONTATO',
'CLIENTE INSATISFEITO',
'CREDITO - CLIENTE INSATISFEITO',
'PRE�O ALTO',
'CONTRATOU',
'CR�DITO - CONTRATOU',
'RESIDENCIAL - CONTRATOU'
)
	AND OPERACAO = 'CR�DITO PROTEGIDO'
	AND DATA BETWEEN '2019-01-01' AND '2019-12-31'
	AND CPF_CNPJ NOT IN ('0','')
	AND ORIGEM_TABULACAO NOT IN ('CRED INADIMPL�NCIA ATV','CRED INADIMPL�NCIA ATV MAN','CRED INADIMPL�NCIA RECP')

GROUP BY
	CAST(#INDE.CPF_CNPJ AS FLOAT)

ORDER BY
	COUNT(ASSUNTO_PROCESSO) DESC

--==============================================================================================================================
IF OBJECT_ID('TEMPDB.DBO.#CONT','U') IS NOT NULL
 DROP TABLE #CONT;

SELECT
	CAST(#INDE.CPF_CNPJ AS FLOAT) AS CPF_CNPJ
	,COUNT(ASSUNTO_PROCESSO) AS QTDE_CONT
INTO #CONT

FROM #INDE
INNER JOIN [TABULACOES].[TB_TABULACOES_DIARIAS_DETALHE] ON #INDE.CPF_CNPJ = REPLACE(REPLACE(REPLACE([TABULACOES].[TB_TABULACOES_DIARIAS_DETALHE].CODIGO_CLIENTE,'.',''),'-',''),'/','')

WHERE
	ASSUNTO_PROCESSO IN (
'CONTRATOU',
'CR�DITO - CONTRATOU',
'RESIDENCIAL - CONTRATOU'
)
	AND OPERACAO = 'CR�DITO PROTEGIDO'
	AND DATA BETWEEN '2019-01-01' AND '2019-12-31'
	AND CPF_CNPJ NOT IN ('0','')
	AND ORIGEM_TABULACAO NOT IN ('CRED INADIMPL�NCIA ATV','CRED INADIMPL�NCIA ATV MAN','CRED INADIMPL�NCIA RECP')

GROUP BY
	CAST(#INDE.CPF_CNPJ AS FLOAT)

ORDER BY
	COUNT(ASSUNTO_PROCESSO) DESC

--==============================================================================================================================

SELECT 
	CAST(#INDE.CPF_CNPJ AS FLOAT) AS CPF_CNPJ
	,ISNULL(#ML2.QTDE_MAILINGS,0) AS QTDE_MAILINGS
	,SUM(#INDE.QTDE) AS QTDE_INCOMODO
	,#LIGA2.QUANT_TENTATIVAS
	,ISNULL(#OUT.QTDE_OUT_TAB,0) AS QTDE_OUT_TAB
	,ISNULL(#CONT.QTDE_CONT,0) AS QTDE_CONTRATACOES

FROM
	#INDE
	LEFT JOIN #OUT ON (CAST(#INDE.CPF_CNPJ AS FLOAT) = #OUT.CPF_CNPJ)
	LEFT JOIN #CONT ON (CAST(#INDE.CPF_CNPJ AS FLOAT) = #CONT.CPF_CNPJ)
	LEFT JOIN #ML2 ON (CAST(#INDE.CPF_CNPJ AS FLOAT) = #ML2.CPF_CNPJ)
	INNER JOIN #LIGA2 ON (CAST(#INDE.CPF_CNPJ AS FLOAT) = #LIGA2.CPF_CNPJ)

GROUP BY 
	CAST(#INDE.CPF_CNPJ AS FLOAT)
	,#ML2.QTDE_MAILINGS
	,#LIGA2.QUANT_TENTATIVAS
	,#OUT.QTDE_OUT_TAB
	,#CONT.QTDE_CONT

ORDER BY
	SUM(#INDE.QTDE) DESC

