--
-- PostgreSQL database dump
--

\restrict Y7OK19vHLyX9fiPr5bUrcCupbZDJjfJKnJwEgjtOPOJDwaR4xbMwWx9q7pem2zp

-- Dumped from database version 15.18
-- Dumped by pg_dump version 15.18

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: agent_strategy_installations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.agent_strategy_installations (
    id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    tenant_id uuid NOT NULL,
    provider character varying(127) NOT NULL,
    plugin_unique_identifier character varying(255),
    plugin_id character varying(255)
);


ALTER TABLE public.agent_strategy_installations OWNER TO postgres;

--
-- Name: ai_model_installations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ai_model_installations (
    id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    provider character varying(127) NOT NULL,
    tenant_id uuid NOT NULL,
    plugin_unique_identifier character varying(255),
    plugin_id character varying(255)
);


ALTER TABLE public.ai_model_installations OWNER TO postgres;

--
-- Name: datasource_installations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.datasource_installations (
    id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    tenant_id uuid NOT NULL,
    provider character varying(127) NOT NULL,
    plugin_unique_identifier character varying(255),
    plugin_id character varying(255)
);


ALTER TABLE public.datasource_installations OWNER TO postgres;

--
-- Name: endpoints; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.endpoints (
    id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name character varying(127) DEFAULT 'default'::character varying,
    hook_id character varying(127),
    tenant_id character varying(64),
    user_id character varying(64),
    plugin_id character varying(64),
    expired_at timestamp with time zone,
    enabled boolean,
    settings text
);


ALTER TABLE public.endpoints OWNER TO postgres;

--
-- Name: install_tasks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.install_tasks (
    id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    status character varying(50) NOT NULL,
    tenant_id uuid NOT NULL,
    total_plugins bigint NOT NULL,
    completed_plugins bigint NOT NULL,
    plugins text
);


ALTER TABLE public.install_tasks OWNER TO postgres;

--
-- Name: plugin_declarations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plugin_declarations (
    id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    plugin_unique_identifier character varying(255),
    plugin_id character varying(255),
    declaration text
);


ALTER TABLE public.plugin_declarations OWNER TO postgres;

--
-- Name: plugin_installations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plugin_installations (
    id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    tenant_id uuid,
    plugin_id character varying(255),
    plugin_unique_identifier character varying(255),
    runtime_type character varying(127),
    endpoints_setups bigint,
    endpoints_active bigint,
    source character varying(63),
    meta text
);


ALTER TABLE public.plugin_installations OWNER TO postgres;

--
-- Name: plugin_readme_records; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plugin_readme_records (
    id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    plugin_unique_identifier character varying(255) NOT NULL,
    language character varying(10) NOT NULL,
    content text NOT NULL
);


ALTER TABLE public.plugin_readme_records OWNER TO postgres;

--
-- Name: plugins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plugins (
    id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    plugin_unique_identifier character varying(255),
    plugin_id character varying(255),
    refers bigint DEFAULT 0,
    install_type character varying(127),
    manifest_type character varying(127),
    remote_declaration text,
    source character varying(63) DEFAULT ''::character varying
);


ALTER TABLE public.plugins OWNER TO postgres;

--
-- Name: serverless_runtimes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.serverless_runtimes (
    id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    plugin_unique_identifier character varying(255),
    function_url character varying(255),
    function_name character varying(127),
    type character varying(127),
    checksum character varying(127)
);


ALTER TABLE public.serverless_runtimes OWNER TO postgres;

--
-- Name: tenant_storages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tenant_storages (
    id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    tenant_id character varying(255) NOT NULL,
    plugin_id character varying(255) NOT NULL,
    size bigint NOT NULL
);


ALTER TABLE public.tenant_storages OWNER TO postgres;

--
-- Name: tool_installations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tool_installations (
    id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    tenant_id uuid NOT NULL,
    provider character varying(127) NOT NULL,
    plugin_unique_identifier character varying(255),
    plugin_id character varying(255)
);


ALTER TABLE public.tool_installations OWNER TO postgres;

--
-- Name: trigger_installations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trigger_installations (
    id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    tenant_id uuid NOT NULL,
    provider character varying(127) NOT NULL,
    plugin_unique_identifier character varying(255),
    plugin_id character varying(255)
);


ALTER TABLE public.trigger_installations OWNER TO postgres;

--
-- Data for Name: agent_strategy_installations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.agent_strategy_installations (id, created_at, updated_at, tenant_id, provider, plugin_unique_identifier, plugin_id) FROM stdin;
019f64ee-f265-776e-89b2-e265f2694d66	2026-07-15 08:40:09.061489+00	2026-07-15 08:40:09.061489+00	baeb15b8-2e7b-49cc-a015-61bbab3debb0	agent	langgenius/agent:0.0.40@d00a70e81bfb28fadd52cba7fd7a1f7c344c67b051e4a2e356a06c690736a7c4	langgenius/agent
\.


--
-- Data for Name: ai_model_installations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ai_model_installations (id, created_at, updated_at, provider, tenant_id, plugin_unique_identifier, plugin_id) FROM stdin;
019fa29f-c060-74f5-9329-87f0828f4345	2026-07-27 08:10:06.304328+00	2026-07-27 08:10:06.304328+00	ollama	baeb15b8-2e7b-49cc-a015-61bbab3debb0	langgenius/ollama:1.0.0@ae50a2db261bffa7289677f2b0a60e60762ceb187b602113b72425ccbe772dc3	langgenius/ollama
\.


--
-- Data for Name: datasource_installations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.datasource_installations (id, created_at, updated_at, tenant_id, provider, plugin_unique_identifier, plugin_id) FROM stdin;
\.


--
-- Data for Name: endpoints; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.endpoints (id, created_at, updated_at, name, hook_id, tenant_id, user_id, plugin_id, expired_at, enabled, settings) FROM stdin;
\.


--
-- Data for Name: install_tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.install_tasks (id, created_at, updated_at, status, tenant_id, total_plugins, completed_plugins, plugins) FROM stdin;
\.


--
-- Data for Name: plugin_declarations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.plugin_declarations (id, created_at, updated_at, plugin_unique_identifier, plugin_id, declaration) FROM stdin;
019f64ee-e5e0-73a0-9172-dc66f45e3172	2026-07-15 08:40:05.856244+00	2026-07-15 08:40:05.856244+00	langgenius/agent:0.0.40@d00a70e81bfb28fadd52cba7fd7a1f7c344c67b051e4a2e356a06c690736a7c4	langgenius/agent	{"version":"0.0.40","type":"plugin","author":"langgenius","name":"agent","label":{"en_US":"Dify Agent Strategies","zh_Hans":"Dify Agent 策略"},"description":{"en_US":"Dify official Agent strategies collection","zh_Hans":"Dify 官方 Agent 策略集合"},"icon":"e74e644589f5d78cd6019be7b92050c2b54b2645139af705fe610649a73282cf.svg","icon_dark":"","resource":{"memory":1048576,"permission":{"tool":{"enabled":true},"model":{"enabled":true,"llm":true,"text_embedding":false,"rerank":false,"tts":false,"speech2text":false,"moderation":false}}},"plugins":{"tools":null,"models":null,"endpoints":null,"agent_strategies":["provider/agent.yaml"],"datasources":null,"triggers":null},"meta":{"version":"0.0.2","arch":["amd64","arm64"],"runner":{"language":"python","version":"3.12","entrypoint":"main"},"minimum_dify_version":"1.7.0"},"tags":["agent"],"created_at":"2025-01-08T15:22:00Z","verified":true,"agent_strategy":{"identity":{"author":"langgenius","name":"agent","description":{"en_US":"Agent","zh_Hans":"Agent","pt_BR":"Agent"},"icon":"e74e644589f5d78cd6019be7b92050c2b54b2645139af705fe610649a73282cf.svg","icon_dark":"","label":{"en_US":"Agent","zh_Hans":"Agent","pt_BR":"Agent"},"tags":[]},"strategies":[{"identity":{"author":"Dify","name":"function_calling","label":{"en_US":"FunctionCalling","zh_Hans":"FunctionCalling","pt_BR":"FunctionCalling"}},"description":{"en_US":"Recommended. Uses the model's native function calling capability for tool invocation. Works best with most modern models (GPT-4o, Claude, Qwen, etc.).","zh_Hans":"推荐使用。通过模型原生的函数调用能力来调用工具，适用于大多数主流模型（GPT-4o、Claude、Qwen 等）。","pt_BR":"Recomendado. Usa a capacidade nativa de chamada de função do modelo para invocar ferramentas. Funciona melhor com a maioria dos modelos modernos (GPT-4o, Claude, Qwen, etc.)."},"parameters":[{"name":"model","label":{"en_US":"Model","zh_Hans":"模型","pt_BR":"Model"},"help":{"en_US":""},"type":"model-selector","auto_generate":null,"template":null,"scope":"tool-call\\u0026llm","required":true,"default":null,"min":null,"max":null,"precision":null,"options":null},{"name":"tools","label":{"en_US":"Tool list","zh_Hans":"工具列表","pt_BR":"Tool list"},"help":{"en_US":""},"type":"array[tools]","auto_generate":null,"template":null,"scope":null,"required":true,"default":null,"min":null,"max":null,"precision":null,"options":null},{"name":"instruction","label":{"en_US":"Instruction","zh_Hans":"指令","pt_BR":"Instruction"},"help":{"en_US":""},"type":"string","auto_generate":{"type":"prompt_instruction"},"template":{"enabled":true},"scope":null,"required":true,"default":null,"min":null,"max":null,"precision":null,"options":null},{"name":"context","label":{"en_US":"Context","zh_Hans":"上下文","pt_BR":"Context"},"help":{"en_US":""},"type":"any","auto_generate":null,"template":null,"scope":"array[object]","required":false,"default":null,"min":null,"max":null,"precision":null,"options":null},{"name":"query","label":{"en_US":"Query","zh_Hans":"查询","pt_BR":"Query"},"help":{"en_US":""},"type":"string","auto_generate":null,"template":null,"scope":null,"required":true,"default":null,"min":null,"max":null,"precision":null,"options":null},{"name":"maximum_iterations","label":{"en_US":"Maximum Iterations","zh_Hans":"最大迭代次数","pt_BR":"Maximum Iterations"},"help":{"en_US":""},"type":"number","auto_generate":null,"template":null,"scope":null,"required":true,"default":3,"min":1,"max":500,"precision":null,"options":null}],"output_schema":null,"features":["history-messages"]},{"identity":{"author":"Dify","name":"ReAct","label":{"en_US":"ReAct","zh_Hans":"ReAct","pt_BR":"ReAct"}},"description":{"en_US":"Text-based reasoning strategy (Thought → Action → Observation loop). Best for models that do NOT support function calling. If your model supports function calling, use the FunctionCalling strategy instead for better results.","zh_Hans":"基于文本的推理策略（Thought → Action → Observation 循环）。适用于不支持函数调用的模型。如果您的模型支持函数调用，建议使用 FunctionCalling 策略以获得更好的效果。","pt_BR":"Estratégia de raciocínio baseada em texto (ciclo Thought → Action → Observation). Melhor para modelos que NÃO suportam chamada de função. Se seu modelo suporta chamada de função, use a estratégia FunctionCalling para melhores resultados."},"parameters":[{"name":"model","label":{"en_US":"Model","zh_Hans":"模型","pt_BR":"Model"},"help":{"en_US":""},"type":"model-selector","auto_generate":null,"template":null,"scope":"llm","required":true,"default":null,"min":null,"max":null,"precision":null,"options":null},{"name":"tools","label":{"en_US":"Tool list","zh_Hans":"工具列表","pt_BR":"Tool list"},"help":{"en_US":""},"type":"array[tools]","auto_generate":null,"template":null,"scope":null,"required":true,"default":null,"min":null,"max":null,"precision":null,"options":null},{"name":"instruction","label":{"en_US":"Instruction","zh_Hans":"指令","pt_BR":"Instruction"},"help":{"en_US":""},"type":"string","auto_generate":{"type":"prompt_instruction"},"template":{"enabled":true},"scope":null,"required":true,"default":null,"min":null,"max":null,"precision":null,"options":null},{"name":"context","label":{"en_US":"Context","zh_Hans":"上下文","pt_BR":"Context"},"help":{"en_US":""},"type":"any","auto_generate":null,"template":null,"scope":"array[object]","required":false,"default":null,"min":null,"max":null,"precision":null,"options":null},{"name":"query","label":{"en_US":"Query","zh_Hans":"查询","pt_BR":"Query"},"help":{"en_US":""},"type":"string","auto_generate":null,"template":null,"scope":null,"required":true,"default":null,"min":null,"max":null,"precision":null,"options":null},{"name":"maximum_iterations","label":{"en_US":"Maximum Iterations","zh_Hans":"最大迭代次数","pt_BR":"Maximum Iterations"},"help":{"en_US":""},"type":"number","auto_generate":null,"template":null,"scope":null,"required":true,"default":3,"min":1,"max":500,"precision":null,"options":null}],"output_schema":null,"features":["history-messages"]}]}}
019f69f1-a7de-75e5-aa1a-86fc0252efcd	2026-07-16 08:01:12.670401+00	2026-07-16 08:01:12.670401+00	langgenius/firecrawl_datasource:0.2.11@8fb56c3234e0c25776058ece857988c43309d520af6976cb30c0eed21aba253b	langgenius/firecrawl_datasource	{"version":"0.2.11","type":"plugin","author":"langgenius","name":"firecrawl_datasource","label":{"en_US":"Firecrawl","ja_JP":"Firecrawl","zh_Hans":"Firecrawl","pt_BR":"Firecrawl"},"description":{"en_US":"Firecrawl Datasource","ja_JP":"Firecrawl Datasource","zh_Hans":"Firecrawl Datasource","pt_BR":"Firecrawl Datasource"},"icon":"d0f13ece19d7764fcfc3e07c0b5b6d7cd5441c5a0ee1bf84e30d7e8e93b3c928.svg","icon_dark":"","resource":{"memory":268435456,"permission":{"model":{"enabled":true,"llm":false,"text_embedding":false,"rerank":false,"tts":false,"speech2text":false,"moderation":false}}},"plugins":{"tools":null,"models":null,"endpoints":null,"agent_strategies":null,"datasources":["provider/firecrawl_datasource.yaml"],"triggers":null},"meta":{"version":"0.0.1","arch":["amd64","arm64"],"runner":{"language":"python","version":"3.12","entrypoint":"main"},"minimum_dify_version":"1.9.0"},"tags":["rag"],"created_at":"2025-05-14T16:03:40.268524+08:00","privacy":"PRIVACY.md","verified":true,"datasource":{"identity":{"author":"langgenius","name":"firecrawl","description":{"en_US":"Firecrawl Datasource","zh_Hans":"Firecrawl Datasource","pt_BR":"Firecrawl Datasource"},"icon":"d0f13ece19d7764fcfc3e07c0b5b6d7cd5441c5a0ee1bf84e30d7e8e93b3c928.svg","label":{"en_US":"Firecrawl","zh_Hans":"Firecrawl","pt_BR":"Firecrawl"},"tags":[]},"credentials_schema":[{"name":"base_url","type":"text-input","scope":null,"required":false,"default":null,"options":null,"multiple":false,"label":{"en_US":"Firecrawl server's Base URL","zh_Hans":"Firecrawl服务器的API URL"},"help":null,"url":null,"placeholder":{"en_US":"https://api.firecrawl.dev"}},{"name":"firecrawl_api_key","type":"secret-input","scope":null,"required":true,"default":null,"options":null,"multiple":false,"label":{"en_US":"Firecrawl API Key","zh_Hans":"Firecrawl API 密钥"},"help":{"en_US":"Get your Firecrawl API key from your Firecrawl account settings.If you are using a self-hosted version, you may enter any key at your convenience.","zh_Hans":"从您的 Firecrawl 账户设置中获取 Firecrawl API 密钥。如果是自托管版本，可以随意填写密钥。"},"url":"https://www.firecrawl.dev/account","placeholder":{"en_US":"Please input your Firecrawl API key","zh_Hans":"请输入您的 Firecrawl API 密钥，如果是自托管版本，可以随意填写密钥"}}],"oauth_schema":null,"provider_type":"website_crawl","datasources":[{"identity":{"author":"langgenius","name":"crawl","label":{"en_US":"Firecrawl","zh_Hans":"Firecrawl"},"icon":""},"parameters":[{"name":"url","label":{"en_US":"Start URL","zh_Hans":"起始URL"},"type":"string","scope":null,"required":true,"auto_generate":null,"template":null,"default":null,"min":null,"max":null,"precision":null,"options":null,"description":{"en_US":"The base URL to start crawling from.","zh_Hans":"要爬取网站的起始URL。"}},{"name":"crawl_subpages","label":{"en_US":"Crawl Subpages","zh_Hans":"爬取子页面"},"type":"boolean","scope":null,"required":false,"auto_generate":null,"template":null,"default":true,"min":null,"max":null,"precision":null,"options":null,"description":{"en_US":"is crawl subpages","zh_Hans":"是否爬取子页面"}},{"name":"exclude_paths","label":{"en_US":"URL patterns to exclude","zh_Hans":"排除路径"},"type":"string","scope":null,"required":false,"auto_generate":null,"template":null,"default":null,"min":null,"max":null,"precision":null,"options":null,"description":{"en_US":"Pages matching these patterns will be skipped. Example: blog/*, about/*","zh_Hans":"匹配这些模式的页面将被跳过。示例：blog/*, about/*"}},{"name":"include_paths","label":{"en_US":"URL patterns to include","zh_Hans":"仅包含路径"},"type":"string","scope":null,"required":false,"auto_generate":null,"template":null,"default":null,"min":null,"max":null,"precision":null,"options":null,"description":{"en_US":"Only pages matching these patterns will be crawled. Example: blog/*, about/*","zh_Hans":"只有与这些模式匹配的页面才会被爬取。示例：blog/*, about/*"}},{"name":"max_depth","label":{"en_US":"Maximum crawl depth","zh_Hans":"最大深度"},"type":"number","scope":null,"required":false,"auto_generate":null,"template":null,"default":2,"min":0,"max":null,"precision":null,"options":null,"description":{"en_US":"Maximum depth to crawl relative to the entered URL. A maxDepth of 0 scrapes only the entered URL. A maxDepth of 1 scrapes the entered URL and all pages one level deep. A maxDepth of 2 scrapes the entered URL and all pages up to two levels deep. Higher values follow the same pattern.","zh_Hans":"相对于输入的URL，爬取的最大深度。maxDepth为0时，仅抓取输入的URL。maxDepth为1时，抓取输入的URL以及所有一级深层页面。maxDepth为2时，抓取输入的URL以及所有两级深层页面。更高值遵循相同模式。"}},{"name":"limit","label":{"en_US":"Maximum pages to crawl","zh_Hans":"限制数量"},"type":"number","scope":null,"required":false,"auto_generate":null,"template":null,"default":10,"min":1,"max":null,"precision":null,"options":null,"description":{"en_US":"Specify the maximum number of pages to crawl. The crawler will stop after reaching this limit.","zh_Hans":"指定要爬取的最大页面数。爬虫将在达到此限制后停止。"}},{"name":"only_main_content","label":{"en_US":"only Main Content","zh_Hans":"仅提取主要内容(无标题、导航、页脚等)"},"type":"boolean","scope":null,"required":false,"auto_generate":null,"template":null,"default":false,"min":null,"max":null,"precision":null,"options":null,"description":{"en_US":"Only return the main content of the page excluding headers, navs, footers, etc.","zh_Hans":"只返回页面的主要内容，不包括头部、导航栏、尾部等。"}}],"description":{"en_US":"Recursively search through a urls subdomains, and gather the content.","zh_Hans":"递归爬取一个网址的子域名，并收集内容。"},"output_schema":{"properties":{"content":{"description":"the content from the website","type":"string"},"description":{"description":"the description of the website","type":"string"},"source_url":{"description":"the source url of the website","type":"string"},"title":{"description":"the title of the website","type":"string"}},"type":"object"}}]}}
019fa26c-43fe-74dc-8d89-d29ceac768dc	2026-07-27 07:13:52.126329+00	2026-07-27 07:13:52.126329+00	langgenius/wikipedia:0.0.8@f7df00299f261c4f0f462f5496de26f1c1013f50a737fa7d40436d1c44963aeb	langgenius/wikipedia	{"version":"0.0.8","type":"plugin","author":"langgenius","name":"wikipedia","label":{"en_US":"Wikipedia","zh_Hans":"维基百科","pt_BR":"Wikipedia"},"description":{"en_US":"Wikipedia is a free online encyclopedia, created and edited by volunteers around the world.","zh_Hans":"维基百科是一个由全世界的志愿者创建和编辑的免费在线百科全书。","pt_BR":"Wikipedia is a free online encyclopedia, created and edited by volunteers around the world."},"icon":"a83ac9eac258f6710e51050e914e9b97d978fcbfc2b53923f4f320c8eef44424.svg","icon_dark":"","resource":{"memory":1048576,"permission":{"tool":{"enabled":true},"model":{"enabled":true,"llm":true,"text_embedding":false,"rerank":false,"tts":false,"speech2text":false,"moderation":false}}},"plugins":{"tools":["provider/wikipedia.yaml"],"models":null,"endpoints":null,"agent_strategies":null,"datasources":null,"triggers":null},"meta":{"version":"0.0.1","arch":["amd64","arm64"],"runner":{"language":"python","version":"3.12","entrypoint":"main"},"minimum_dify_version":null},"tags":["social"],"created_at":"2024-09-20T08:03:44.658609186Z","verified":true,"tool":{"identity":{"author":"langgenius","name":"wikipedia","description":{"en_US":"Wikipedia is a free online encyclopedia, created and edited by volunteers around the world.","zh_Hans":"维基百科是一个由全世界的志愿者创建和编辑的免费在线百科全书。","pt_BR":"Wikipedia is a free online encyclopedia, created and edited by volunteers around the world."},"icon":"a83ac9eac258f6710e51050e914e9b97d978fcbfc2b53923f4f320c8eef44424.svg","icon_dark":"","label":{"en_US":"Wikipedia","zh_Hans":"维基百科","pt_BR":"Wikipedia"},"tags":["social"]},"credentials_schema":[],"oauth_schema":null,"tools":[{"identity":{"author":"langgenius","name":"wikipedia_search","label":{"en_US":"WikipediaSearch","zh_Hans":"维基百科搜索","pt_BR":"WikipediaSearch"}},"description":{"human":{"en_US":"A tool for performing a Wikipedia search and extracting snippets and webpages.","zh_Hans":"一个用于执行维基百科搜索并提取片段和网页的工具。","pt_BR":"A tool for performing a Wikipedia search and extracting snippets and webpages."},"llm":"A tool for performing a Wikipedia search and extracting snippets and webpages. Input should be a search query."},"parameters":[{"name":"query","label":{"en_US":"Query string","zh_Hans":"查询语句","pt_BR":"Query string"},"human_description":{"en_US":"key words for searching","zh_Hans":"查询关键词","pt_BR":"key words for searching"},"type":"string","scope":null,"form":"llm","llm_description":"key words for searching, this should be in the language of \\"language\\" parameter","required":true,"auto_generate":null,"template":null,"default":null,"min":null,"max":null,"multiple":false,"precision":null,"options":null},{"name":"language","label":{"en_US":"Language","zh_Hans":"语言"},"human_description":{"en_US":"The language of the Wikipedia to be searched","zh_Hans":"要搜索的维基百科语言"},"type":"string","scope":null,"form":"llm","llm_description":"language of the wikipedia to be searched, only \\"de\\" for German, \\"en\\" for English, \\"fr\\" for French, \\"hi\\" for Hindi, \\"ja\\" for Japanese, \\"ko\\" for Korean, \\"pl\\" for Polish, \\"pt\\" for Portuguese, \\"ro\\" for Romanian, \\"uk\\" for Ukrainian, \\"vi\\" for Vietnamese, and \\"zh\\" for Chinese are supported","required":true,"auto_generate":null,"template":null,"default":null,"min":null,"max":null,"multiple":false,"precision":null,"options":[{"value":"de","label":{"en_US":"German","zh_Hans":"德语"},"icon":""},{"value":"en","label":{"en_US":"English","zh_Hans":"英语"},"icon":""},{"value":"fr","label":{"en_US":"French","zh_Hans":"法语"},"icon":""},{"value":"hi","label":{"en_US":"Hindi","zh_Hans":"印地语"},"icon":""},{"value":"ja","label":{"en_US":"Japanese","zh_Hans":"日语"},"icon":""},{"value":"ko","label":{"en_US":"Korean","zh_Hans":"韩语"},"icon":""},{"value":"pl","label":{"en_US":"Polish","zh_Hans":"波兰语"},"icon":""},{"value":"pt","label":{"en_US":"Portuguese","zh_Hans":"葡萄牙语"},"icon":""},{"value":"ro","label":{"en_US":"Romanian","zh_Hans":"罗马尼亚语"},"icon":""},{"value":"uk","label":{"en_US":"Ukrainian","zh_Hans":"乌克兰语"},"icon":""},{"value":"vi","label":{"en_US":"Vietnamese","zh_Hans":"越南语"},"icon":""},{"value":"zh","label":{"en_US":"Chinese","zh_Hans":"中文"},"icon":""}]}],"has_runtime_parameters":false}]}}
019fa29f-bbc3-7bc9-b4e6-ccec4f035f1f	2026-07-27 08:10:05.123782+00	2026-07-27 08:10:05.123782+00	langgenius/ollama:1.0.0@ae50a2db261bffa7289677f2b0a60e60762ceb187b602113b72425ccbe772dc3	langgenius/ollama	{"version":"1.0.0","type":"plugin","author":"langgenius","name":"ollama","label":{"en_US":"Ollama"},"description":{"en_US":"Ollama"},"icon":"bfff83a66922c09cb5a5aa68829742b8b4f4e818579db42f53c7b8a30912cd8b.svg","icon_dark":"","resource":{"memory":268435456,"permission":{"model":{"enabled":true,"llm":true,"text_embedding":true,"rerank":true,"tts":false,"speech2text":false,"moderation":false}}},"plugins":{"tools":null,"models":["provider/ollama.yaml"],"endpoints":null,"agent_strategies":null,"datasources":null,"triggers":null},"meta":{"version":"0.0.1","arch":["amd64","arm64"],"runner":{"language":"python","version":"3.12","entrypoint":"main"},"minimum_dify_version":null},"tags":[],"created_at":"2025-11-21T00:00:00.29298939-04:00","verified":true,"model":{"provider":"ollama","label":{"en_US":"Ollama"},"description":{"en_US":"Ollama"},"icon_small":{"en_US":"bfff83a66922c09cb5a5aa68829742b8b4f4e818579db42f53c7b8a30912cd8b.svg"},"icon_large":{"en_US":"758825b9b095f55a1e391b138694e0d3c1cb07fd5eef27d7e5915aa7e2718a97.svg"},"icon_small_dark":null,"icon_large_dark":null,"background":"#F9FAFB","help":{"title":{"en_US":"How to integrate with Ollama","zh_Hans":"如何集成 Ollama"},"url":{"en_US":"https://docs.dify.ai/tutorials/model-configuration/ollama"}},"supported_model_types":["llm","text-embedding","rerank"],"configurate_methods":["customizable-model"],"provider_credential_schema":null,"model_credential_schema":{"model":{"label":{"en_US":"Model Name","zh_Hans":"模型名称"},"placeholder":{"en_US":"Enter your model name","zh_Hans":"输入模型名称"}},"credential_form_schemas":[{"variable":"base_url","label":{"en_US":"Base URL","zh_Hans":"基础 URL"},"type":"text-input","required":true,"default":null,"options":[],"placeholder":{"en_US":"Base url of Ollama server, e.g. http://192.168.1.100:11434","zh_Hans":"Ollama server 的基础 URL，例如 http://192.168.1.100:11434"},"max_length":0,"show_on":[]},{"variable":"api_key","label":{"en_US":"API Key (optional)","zh_Hans":"API 密钥（可选）"},"type":"secret-input","required":false,"default":null,"options":[],"placeholder":{"en_US":"Bearer token sent as Authorization header. Leave blank for unauthenticated Ollama deployments.","zh_Hans":"作为 Authorization 标头发送的 Bearer 令牌。如果 Ollama 没有身份验证，请留空。"},"max_length":0,"show_on":[]},{"variable":"mode","label":{"en_US":"Completion mode","zh_Hans":"模型类型"},"type":"select","required":true,"default":"chat","options":[{"label":{"en_US":"Completion","zh_Hans":"补全"},"value":"completion","show_on":[]},{"label":{"en_US":"Chat","zh_Hans":"对话"},"value":"chat","show_on":[]}],"placeholder":{"en_US":"Select completion mode","zh_Hans":"选择对话类型"},"max_length":0,"show_on":[{"variable":"__model_type","value":"llm"}]},{"variable":"context_size","label":{"en_US":"Model context size","zh_Hans":"模型上下文长度"},"type":"text-input","required":true,"default":"4096","options":[],"placeholder":{"en_US":"Enter your Model context size","zh_Hans":"在此输入您的模型上下文长度"},"max_length":0,"show_on":[]},{"variable":"max_tokens","label":{"en_US":"Upper bound for max tokens","zh_Hans":"最大 token 上限"},"type":"text-input","required":true,"default":"4096","options":[],"placeholder":null,"max_length":0,"show_on":[{"variable":"__model_type","value":"llm"}]},{"variable":"vision_support","label":{"en_US":"Vision support","zh_Hans":"是否支持 Vision"},"type":"radio","required":false,"default":"false","options":[{"label":{"en_US":"Yes","zh_Hans":"是"},"value":"true","show_on":[]},{"label":{"en_US":"No","zh_Hans":"否"},"value":"false","show_on":[]}],"placeholder":null,"max_length":0,"show_on":[{"variable":"__model_type","value":"llm"}]},{"variable":"function_call_support","label":{"en_US":"Function call support","zh_Hans":"是否支持函数调用"},"type":"radio","required":false,"default":"false","options":[{"label":{"en_US":"Yes","zh_Hans":"是"},"value":"true","show_on":[]},{"label":{"en_US":"No","zh_Hans":"否"},"value":"false","show_on":[]}],"placeholder":null,"max_length":0,"show_on":[{"variable":"__model_type","value":"llm"}]}]},"models":[]}}
\.


--
-- Data for Name: plugin_installations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.plugin_installations (id, created_at, updated_at, tenant_id, plugin_id, plugin_unique_identifier, runtime_type, endpoints_setups, endpoints_active, source, meta) FROM stdin;
019f64ee-f265-7190-8589-55b444956335	2026-07-15 08:40:09.061107+00	2026-07-15 08:40:09.061107+00	baeb15b8-2e7b-49cc-a015-61bbab3debb0	langgenius/agent	langgenius/agent:0.0.40@d00a70e81bfb28fadd52cba7fd7a1f7c344c67b051e4a2e356a06c690736a7c4	local	0	0	package	{}
019fa26c-4f64-75dd-89e9-5f79a92b23e5	2026-07-27 07:13:55.044388+00	2026-07-27 07:13:55.044388+00	baeb15b8-2e7b-49cc-a015-61bbab3debb0	langgenius/wikipedia	langgenius/wikipedia:0.0.8@f7df00299f261c4f0f462f5496de26f1c1013f50a737fa7d40436d1c44963aeb	local	0	0	marketplace	{"plugin_unique_identifier":"langgenius/wikipedia:0.0.8@f7df00299f261c4f0f462f5496de26f1c1013f50a737fa7d40436d1c44963aeb"}
019fa29f-c05f-79b5-ad79-8034804f41c9	2026-07-27 08:10:06.303641+00	2026-07-27 08:10:06.303641+00	baeb15b8-2e7b-49cc-a015-61bbab3debb0	langgenius/ollama	langgenius/ollama:1.0.0@ae50a2db261bffa7289677f2b0a60e60762ceb187b602113b72425ccbe772dc3	local	0	0	marketplace	{"plugin_unique_identifier":"langgenius/ollama:1.0.0@ae50a2db261bffa7289677f2b0a60e60762ceb187b602113b72425ccbe772dc3"}
\.


--
-- Data for Name: plugin_readme_records; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.plugin_readme_records (id, created_at, updated_at, plugin_unique_identifier, language, content) FROM stdin;
\.


--
-- Data for Name: plugins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.plugins (id, created_at, updated_at, plugin_unique_identifier, plugin_id, refers, install_type, manifest_type, remote_declaration, source) FROM stdin;
019f64ee-f264-7282-aa3c-ae376184a436	2026-07-15 08:40:09.06017+00	2026-07-15 08:40:09.06017+00	langgenius/agent:0.0.40@d00a70e81bfb28fadd52cba7fd7a1f7c344c67b051e4a2e356a06c690736a7c4	langgenius/agent	1	local		{"version":"","type":"","author":"","name":"","label":{"en_US":""},"description":{"en_US":""},"icon":"","icon_dark":"","resource":{"memory":0},"plugins":{"tools":null,"models":null,"endpoints":null,"agent_strategies":null,"datasources":null,"triggers":null},"meta":{"version":"","arch":null,"runner":{"language":"","version":"","entrypoint":""},"minimum_dify_version":null},"tags":null,"created_at":"0001-01-01T00:00:00Z","verified":false}	package
019fa26c-4f62-70d5-adec-f318d2bf7ac9	2026-07-27 07:13:55.04206+00	2026-07-27 07:13:55.04206+00	langgenius/wikipedia:0.0.8@f7df00299f261c4f0f462f5496de26f1c1013f50a737fa7d40436d1c44963aeb	langgenius/wikipedia	1	local		{"version":"","type":"","author":"","name":"","label":{"en_US":""},"description":{"en_US":""},"icon":"","icon_dark":"","resource":{"memory":0},"plugins":{"tools":null,"models":null,"endpoints":null,"agent_strategies":null,"datasources":null,"triggers":null},"meta":{"version":"","arch":null,"runner":{"language":"","version":"","entrypoint":""},"minimum_dify_version":null},"tags":null,"created_at":"0001-01-01T00:00:00Z","verified":false}	marketplace
019fa29f-c05e-7621-b1c5-983f36c95bed	2026-07-27 08:10:06.302406+00	2026-07-27 08:10:06.302406+00	langgenius/ollama:1.0.0@ae50a2db261bffa7289677f2b0a60e60762ceb187b602113b72425ccbe772dc3	langgenius/ollama	1	local		{"version":"","type":"","author":"","name":"","label":{"en_US":""},"description":{"en_US":""},"icon":"","icon_dark":"","resource":{"memory":0},"plugins":{"tools":null,"models":null,"endpoints":null,"agent_strategies":null,"datasources":null,"triggers":null},"meta":{"version":"","arch":null,"runner":{"language":"","version":"","entrypoint":""},"minimum_dify_version":null},"tags":null,"created_at":"0001-01-01T00:00:00Z","verified":false}	marketplace
\.


--
-- Data for Name: serverless_runtimes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.serverless_runtimes (id, created_at, updated_at, plugin_unique_identifier, function_url, function_name, type, checksum) FROM stdin;
\.


--
-- Data for Name: tenant_storages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tenant_storages (id, created_at, updated_at, tenant_id, plugin_id, size) FROM stdin;
\.


--
-- Data for Name: tool_installations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tool_installations (id, created_at, updated_at, tenant_id, provider, plugin_unique_identifier, plugin_id) FROM stdin;
019fa26c-4f65-7e9f-8cad-45ac97b4b231	2026-07-27 07:13:55.045961+00	2026-07-27 07:13:55.045961+00	baeb15b8-2e7b-49cc-a015-61bbab3debb0	wikipedia	langgenius/wikipedia:0.0.8@f7df00299f261c4f0f462f5496de26f1c1013f50a737fa7d40436d1c44963aeb	langgenius/wikipedia
\.


--
-- Data for Name: trigger_installations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.trigger_installations (id, created_at, updated_at, tenant_id, provider, plugin_unique_identifier, plugin_id) FROM stdin;
\.


--
-- Name: agent_strategy_installations agent_strategy_installations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.agent_strategy_installations
    ADD CONSTRAINT agent_strategy_installations_pkey PRIMARY KEY (id);


--
-- Name: ai_model_installations ai_model_installations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_model_installations
    ADD CONSTRAINT ai_model_installations_pkey PRIMARY KEY (id);


--
-- Name: datasource_installations datasource_installations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.datasource_installations
    ADD CONSTRAINT datasource_installations_pkey PRIMARY KEY (id);


--
-- Name: endpoints endpoints_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.endpoints
    ADD CONSTRAINT endpoints_pkey PRIMARY KEY (id);


--
-- Name: install_tasks install_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.install_tasks
    ADD CONSTRAINT install_tasks_pkey PRIMARY KEY (id);


--
-- Name: plugin_declarations plugin_declarations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plugin_declarations
    ADD CONSTRAINT plugin_declarations_pkey PRIMARY KEY (id);


--
-- Name: plugin_installations plugin_installations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plugin_installations
    ADD CONSTRAINT plugin_installations_pkey PRIMARY KEY (id);


--
-- Name: plugin_readme_records plugin_readme_records_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plugin_readme_records
    ADD CONSTRAINT plugin_readme_records_pkey PRIMARY KEY (id);


--
-- Name: plugins plugins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plugins
    ADD CONSTRAINT plugins_pkey PRIMARY KEY (id);


--
-- Name: serverless_runtimes serverless_runtimes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serverless_runtimes
    ADD CONSTRAINT serverless_runtimes_pkey PRIMARY KEY (id);


--
-- Name: tenant_storages tenant_storages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tenant_storages
    ADD CONSTRAINT tenant_storages_pkey PRIMARY KEY (id);


--
-- Name: tool_installations tool_installations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_installations
    ADD CONSTRAINT tool_installations_pkey PRIMARY KEY (id);


--
-- Name: trigger_installations trigger_installations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trigger_installations
    ADD CONSTRAINT trigger_installations_pkey PRIMARY KEY (id);


--
-- Name: endpoints uni_endpoints_hook_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.endpoints
    ADD CONSTRAINT uni_endpoints_hook_id UNIQUE (hook_id);


--
-- Name: plugin_declarations uni_plugin_declarations_plugin_unique_identifier; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plugin_declarations
    ADD CONSTRAINT uni_plugin_declarations_plugin_unique_identifier UNIQUE (plugin_unique_identifier);


--
-- Name: serverless_runtimes uni_serverless_runtimes_plugin_unique_identifier; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.serverless_runtimes
    ADD CONSTRAINT uni_serverless_runtimes_plugin_unique_identifier UNIQUE (plugin_unique_identifier);


--
-- Name: idx_agent_strategy_installations_plugin_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_agent_strategy_installations_plugin_id ON public.agent_strategy_installations USING btree (plugin_id);


--
-- Name: idx_agent_strategy_installations_plugin_unique_identifier; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_agent_strategy_installations_plugin_unique_identifier ON public.agent_strategy_installations USING btree (plugin_unique_identifier);


--
-- Name: idx_agent_strategy_installations_provider; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_agent_strategy_installations_provider ON public.agent_strategy_installations USING btree (provider);


--
-- Name: idx_agent_strategy_installations_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_agent_strategy_installations_tenant_id ON public.agent_strategy_installations USING btree (tenant_id);


--
-- Name: idx_ai_model_installations_plugin_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ai_model_installations_plugin_id ON public.ai_model_installations USING btree (plugin_id);


--
-- Name: idx_ai_model_installations_plugin_unique_identifier; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ai_model_installations_plugin_unique_identifier ON public.ai_model_installations USING btree (plugin_unique_identifier);


--
-- Name: idx_ai_model_installations_provider; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ai_model_installations_provider ON public.ai_model_installations USING btree (provider);


--
-- Name: idx_ai_model_installations_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ai_model_installations_tenant_id ON public.ai_model_installations USING btree (tenant_id);


--
-- Name: idx_datasource_installations_plugin_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_datasource_installations_plugin_id ON public.datasource_installations USING btree (plugin_id);


--
-- Name: idx_datasource_installations_plugin_unique_identifier; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_datasource_installations_plugin_unique_identifier ON public.datasource_installations USING btree (plugin_unique_identifier);


--
-- Name: idx_datasource_installations_provider; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_datasource_installations_provider ON public.datasource_installations USING btree (provider);


--
-- Name: idx_datasource_installations_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_datasource_installations_tenant_id ON public.datasource_installations USING btree (tenant_id);


--
-- Name: idx_endpoints_plugin_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_endpoints_plugin_id ON public.endpoints USING btree (plugin_id);


--
-- Name: idx_endpoints_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_endpoints_tenant_id ON public.endpoints USING btree (tenant_id);


--
-- Name: idx_endpoints_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_endpoints_user_id ON public.endpoints USING btree (user_id);


--
-- Name: idx_install_tasks_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_install_tasks_status ON public.install_tasks USING btree (status);


--
-- Name: idx_plugin_declarations_plugin_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_plugin_declarations_plugin_id ON public.plugin_declarations USING btree (plugin_id);


--
-- Name: idx_plugin_installations_plugin_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_plugin_installations_plugin_id ON public.plugin_installations USING btree (plugin_id);


--
-- Name: idx_plugin_installations_plugin_unique_identifier; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_plugin_installations_plugin_unique_identifier ON public.plugin_installations USING btree (plugin_unique_identifier);


--
-- Name: idx_plugin_installations_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_plugin_installations_tenant_id ON public.plugin_installations USING btree (tenant_id);


--
-- Name: idx_plugin_readme_records_plugin_unique_identifier; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_plugin_readme_records_plugin_unique_identifier ON public.plugin_readme_records USING btree (plugin_unique_identifier);


--
-- Name: idx_plugin_unique_identifier; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_plugin_unique_identifier ON public.plugins USING btree (plugin_unique_identifier);


--
-- Name: idx_plugins_install_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_plugins_install_type ON public.plugins USING btree (install_type);


--
-- Name: idx_plugins_plugin_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_plugins_plugin_id ON public.plugins USING btree (plugin_id);


--
-- Name: idx_serverless_runtimes_checksum; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_serverless_runtimes_checksum ON public.serverless_runtimes USING btree (checksum);


--
-- Name: idx_tenant_plugin; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_tenant_plugin ON public.plugin_installations USING btree (tenant_id, plugin_id);


--
-- Name: idx_tenant_storages_plugin_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tenant_storages_plugin_id ON public.tenant_storages USING btree (plugin_id);


--
-- Name: idx_tenant_storages_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tenant_storages_tenant_id ON public.tenant_storages USING btree (tenant_id);


--
-- Name: idx_tool_installations_plugin_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tool_installations_plugin_id ON public.tool_installations USING btree (plugin_id);


--
-- Name: idx_tool_installations_plugin_unique_identifier; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tool_installations_plugin_unique_identifier ON public.tool_installations USING btree (plugin_unique_identifier);


--
-- Name: idx_tool_installations_provider; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tool_installations_provider ON public.tool_installations USING btree (provider);


--
-- Name: idx_tool_installations_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tool_installations_tenant_id ON public.tool_installations USING btree (tenant_id);


--
-- Name: idx_trigger_installations_plugin_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_trigger_installations_plugin_id ON public.trigger_installations USING btree (plugin_id);


--
-- Name: idx_trigger_installations_plugin_unique_identifier; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_trigger_installations_plugin_unique_identifier ON public.trigger_installations USING btree (plugin_unique_identifier);


--
-- Name: idx_trigger_installations_provider; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_trigger_installations_provider ON public.trigger_installations USING btree (provider);


--
-- Name: idx_trigger_installations_tenant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_trigger_installations_tenant_id ON public.trigger_installations USING btree (tenant_id);


--
-- PostgreSQL database dump complete
--

\unrestrict Y7OK19vHLyX9fiPr5bUrcCupbZDJjfJKnJwEgjtOPOJDwaR4xbMwWx9q7pem2zp

