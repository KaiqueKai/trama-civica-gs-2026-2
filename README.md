# TRAMA CÍVICA — Global Solution 2026.2

**FIAP · CitizenTech · Prompt and Artificial Intelligence · Turma 1CCPJ**  
**Professor:** Jorge Luiz Gomes  
**Modalidade:** Trio  
**Tema:** mobilidade urbana acessível com evidência verificável

## 1. Visão geral

TRAMA CÍVICA é um protótipo acadêmico de assistência à mobilidade urbana no município fictício de Vale Sereno. O recorte funcional é a Linha 714. A aplicação responde perguntas sobre itinerário, horários, acessibilidade e alterações operacionais, procurando sustentar as respostas em documentos identificados e respeitando a validade temporal dos comunicados.

O município, a linha, os pontos, os horários, os comunicados e as operações apresentados na base são **dados sintéticos**, criados para a atividade. O sistema não é um serviço público real e não deve ser usado para planejar deslocamentos reais.

## 2. Integrantes e responsabilidades

## 5. Certificação — Contribuições dos integrantes

**Kaique da Silva Assis — RM 572718:** responsável pelo desenvolvimento técnico inicial do TRAMA CÍVICA, incluindo planejamento, arquitetura, implementação, integração dos componentes, organização da base documental, tratamento de erros e execução do notebook. Na etapa de fechamento, realiza a revisão técnica da implementação e a conferência da execução.

**Andre Debiazzi Baldi Negrini — RM 569062:** responsável pela auditoria da base documental MOB-001 a MOB-005, conferência da consistência das informações utilizadas nas respostas Q01–Q04 e revisão dos mecanismos de segurança e guardrails. Participa também da apresentação em vídeo.

**Vinicius Cristal de Oliveira — RM 572049:** responsável pela conferência do arquivo de avaliação RAGAS, validação dos resultados das 32 métricas, análise dos resultados das perguntas Q05–Q08 e revisão da documentação final e da estrutura de entrega. Participa também da apresentação em vídeo.

## 3. Arquitetura e tecnologias

**Ambiente de execução:** Google Colab, Python 3.13.  
**Modelo de geração e juiz RAGAS efetivamente validado:** Google Gemini Developer API, `gemini-3.5-flash-lite`.  
**Embeddings:** `sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2`.  
**Banco vetorial:** ChromaDB.  
**Orquestração:** LangChain e LCEL.  
**Interface:** Gradio.  
**Avaliação:** RAGAS, 8 perguntas e 4 métricas por pergunta.

Fluxo resumido:

```text
Pergunta do usuário
       ↓
Validação de entrada e guardrails
       ↓
Recuperação de trechos na base (embeddings + ChromaDB)
       ↓
Pipeline RAG / LCEL e agente com ferramentas
       ↓
Resposta fundamentada + fontes + rastreio da ferramenta
       ↓
Interface Gradio
       ↓
Avaliação diagnóstica com RAGAS
```

A indexação registrada na execução utilizou 13 chunks, chunking de 900 caracteres com overlap de 120 e `TOP_K=2` na avaliação de Context Precision. O agente foi configurado com três ferramentas. Os guardrails tiveram 6/6 testes aprovados, conforme os resultados registrados na execução.

## 4. Mudança de provedor: Ollama Cloud → Gemini

O briefing da Global Solution prescreve o uso do **Ollama Cloud**, autenticado por `OLLAMA_API_KEY` armazenada nos Secrets do Google Colab. A implementação foi inicialmente desenvolvida para seguir esse caminho, mas a execução dos modelos Cloud testados na conta utilizada retornou **HTTP 402**. Depois foi testada uma alternativa com Groq, mas a avaliação completa ficou inviável com o limite de tokens por minuto (TPM) encontrado na modalidade gratuita. Para concluir o protótipo e executar a avaliação de ponta a ponta, a integração foi adaptada para a Google Gemini Developer API. O modelo que efetivamente passou pelos testes e concluiu a avaliação foi `gemini-3.5-flash-lite`.

### O que a política do Ollama significa na prática

A documentação oficial de preços do Ollama, consultada em **13/11/2026**, esclarece que Ollama local e Ollama Cloud têm modelos de uso diferentes:

- **Ollama local:** executar modelos no próprio hardware não consome créditos Cloud; o limite prático é o hardware disponível.
- **Ollama Cloud gratuito:** inclui uma quantidade inicial de uso por mês e acesso a um conjunto limitado de modelos iniciais. Não significa acesso ilimitado e gratuito a todos os modelos Cloud.
- **Modelos Cloud adicionais:** podem exigir créditos de uso adquiridos ou um plano que inclua créditos. O consumo é calculado por tokens, conforme o preço publicado para cada modelo. A página oficial também descreve planos pagos com créditos mensais incluídos.

Assim, o HTTP 402 observado nos testes é compatível com uma exigência de pagamento/créditos ou de acesso ao modelo solicitado. **Não é possível determinar apenas pelo código HTTP qual condição específica existia na conta** (saldo, elegibilidade do modelo ou configuração de cobrança); isso dependeria da tela de uso e faturamento da conta Ollama. Portanto, não afirmamos que todo o Ollama é pago ou que não existe faixa gratuita. O problema encontrado foi não conseguir executar os modelos Cloud necessários naquela conta, sem adicionar custo.

Referências oficiais da política consultadas em 13/11/2026:

- [Ollama — Pricing e FAQ de uso](https://ollama.com/pricing)
- [Ollama — Transparent pricing (31/08/2026)](https://ollama.com/blog/transparent-pricing)
- [Ollama — Terms of Service](https://ollama.com/terms)

### Por que a equipe adotou Gemini

A mudança foi uma decisão de continuidade técnica: a alternativa Groq também encontrou um limite de uso que impediu terminar a avaliação; Gemini foi validado para geração, chamadas de ferramentas e juiz RAGAS, com tratamento de erros temporários HTTP 503 e salvamento por checkpoint. Com isso, foi possível obter a execução diagnóstica de 8/8 perguntas.

**Desvio em relação ao briefing:** Gemini não é Ollama Cloud. A solução executada é tecnicamente funcional, mas **não deve ser apresentada como aderente ao requisito de provedor Ollama Cloud**. A substituição depende de autorização expressa do professor. A equipe deve anexar ou indicar a evidência dessa autorização, caso tenha sido concedida. Não foi presumida autorização neste documento.

## 5. Configuração e reprodução

1. Abra `1_Notebook_GS2026_2.ipynb` no Google Colab.
2. Cadastre uma chave própria da Google Gemini Developer API nos Secrets do Colab com o nome `GEMINI_API_KEY` e habilite o acesso pelo notebook.
3. Não escreva a chave diretamente no notebook e não a inclua em prints, Git ou no ZIP.
4. Execute as células na ordem indicada. A execução usa dependências, autenticação, pipeline RAG, ferramentas, interface e avaliação conforme o notebook.
5. A avaliação salva checkpoints em `/content/3_avaliacao_ragas.json`. Para reproduzir uma avaliação interrompida, preserve o checkpoint existente e siga as instruções do próprio notebook.
6. O arquivo `3_avaliacao_ragas.json` da entrega deve ser o JSON original exportado do Colab. Não reconstruir esse arquivo a partir das tabelas deste README.

A disponibilidade e as cotas do Gemini Developer API podem variar conforme projeto, modelo e período. A execução concluída descrita neste documento não garante que uma nova execução terá a mesma cota ou disponibilidade.

## 6. Base documental

A pasta `2_base_documental/` contém cinco documentos sintéticos:

- `MOB-001` — itinerário da Linha 714;
- `MOB-002` — quadro de horários e partidas acessíveis;
- `MOB-003` — portaria operacional e situação dos pontos na data de publicação;
- `MOB-004` — condições de acessibilidade dos pontos;
- `MOB-005` — comunicado temporário de interdição e substituição do ponto P02.

Regra central de interpretação: quando documentos apresentarem informações diferentes para períodos distintos, deve prevalecer o comunicado posterior e específico durante sua vigência. A ausência de um novo comunicado não comprova que uma interdição foi encerrada ou que um ponto foi reaberto.

## 7. Avaliação diagnóstica RAGAS

A execução concluída registrada foi `MEDIDO_COMPLETO_8_DE_8_DIAGNOSTICO_GT_ASSISTIDO`: oito perguntas concluídas, com quatro métricas por pergunta (32 valores). As médias medidas foram:

| Métrica | Média |
|---|---:|
| Faithfulness | **0,7798** |
| Answer Relevancy | **0,7025** |
| Context Precision | **0,8750** |
| Context Recall | **0,5958** |

Resultados por pergunta:

| Pergunta | Faithfulness | Answer Relevancy | Context Precision | Context Recall |
|---|---:|---:|---:|---:|
| Q01 | 1,0000 | 0,9926 | 1,0000 | 0,6667 |
| Q02 | 0,7143 | 0,7694 | 1,0000 | 0,6667 |
| Q05 | 0,6667 | 0,7331 | 1,0000 | 0,6000 |
| Q06 | 1,0000 | 0,6422 | 1,0000 | 0,5000 |
| Q03 | 1,0000 | 1,0000 | 1,0000 | 1,0000 |
| Q04 | 0,5000 | 0,7519 | 1,0000 | 0,3333 |
| Q07 | 0,5000 | 0,7305 | 0,0000 | 0,5000 |
| Q08 | 0,8571 | 0,0000 | 1,0000 | 0,5000 |

### Como interpretar

A média mais baixa foi Context Recall (0,5958), o que indica que, neste conjunto de avaliação, parte das informações das referências não apareceu nos contextos recuperados. Q04 teve Context Recall de 0,3333; Q07 teve Context Precision de 0,0000; e Q08 teve Answer Relevancy de 0,0000. Esses casos justificam revisar a recuperação em perguntas temporais e compostas, verificando os contextos efetivamente retornados, a vigência dos documentos, a autoridade da fonte e a cobertura de todos os subitens antes de alterar `TOP_K` ou adicionar reranking.

### Limitação importante dos ground truths

Os oito ground truths usados nesta execução foram registrados como **rascunhos assistidos por IA**, com autoria do trio não declarada e revisão/validação manual pendente. A validação de autoria pelo trio estava marcada como `False`. Por isso, os números devem ser tratados como **diagnóstico técnico**, não como avaliação final baseada em ground truths comprovadamente escritos e validados pelo grupo. O grupo deve revisar e reescrever/validar manualmente as referências antes de afirmar que são autorais.

Os números acima correspondem aos resultados da execução informada. O arquivo `3_avaliacao_ragas.json` incluído na submissão deve ser o export original do Colab e deve ser conferido com estes valores antes de fechar o ZIP.

## 8. Segurança, privacidade e limitações

- Não incluir chaves de API ou outros segredos no notebook, no repositório, nos prints ou no ZIP.
- A base é inteiramente fictícia e não contém dados operacionais reais de transporte.
- Guardrails: 6/6 verificações aprovadas, segundo a execução registrada.
- Chatbot Gemini, juiz RAGAS em formato estruturado, vinculação de ferramentas e chamada real foram validados na execução informada.
- A avaliação dos ground truths é diagnóstica, pelas razões descritas na seção anterior.
- O uso do Gemini é uma substituição do provedor exigido no briefing e depende de autorização do professor.

## 9. Estrutura final da entrega

O ZIP a ser enviado ao portal deve conter os sete entregáveis oficiais:

```text
GS2026_2_1CCPJ_TRAMA_CIVICA.zip
├── 1_Notebook_GS2026_2.ipynb
├── 2_base_documental/
│   ├── doc_01_itinerario_linha_714.txt
│   ├── doc_02_quadro_horarios_714.txt
│   ├── doc_03_portaria_operacional_018_2026.txt
│   ├── doc_04_laudo_acessibilidade_pontos.txt
│   └── doc_05_comunicado_interdicao_praca_flores.txt
├── 3_avaliacao_ragas.json
├── 4_README.md
├── 5_certificacao.txt
├── 6_Chat_Log.txt
└── 7_demo_video_url.txt
```

O arquivo `MONTAR_ENTREGA.ps1` e este guia são auxiliares e não devem ser incluídos no ZIP oficial. O script ajuda a inserir o notebook e o JSON que já foram baixados pelo responsável e verifica se os links obrigatórios foram preenchidos.
