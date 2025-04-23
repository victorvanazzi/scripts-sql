
-------------------------------
-- Aprendizado Aula Udemy SQL--
-------------------------------


----------------------------------
-- Criação das tabelas no SQLite--
----------------------------------

-- Empresas de ônibus
CREATE TABLE empresa (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL UNIQUE,
  telefone TEXT,
  cnpj TEXT UNIQUE,
  criado_em TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Paradas
CREATE TABLE parada (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  criado_em TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Rotas
CREATE TABLE rota (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  codigo TEXT NOT NULL UNIQUE,
  empresa_id INTEGER NOT NULL,
  origem_id INTEGER NOT NULL,
  destino_id INTEGER NOT NULL,
  distancia_km REAL NOT NULL,
  expressa INTEGER DEFAULT 0,
  criado_em TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (empresa_id) REFERENCES empresa(id),
  FOREIGN KEY (origem_id)  REFERENCES parada(id),
  FOREIGN KEY (destino_id) REFERENCES parada(id)
);

-- Índices úteis para performance
CREATE INDEX idx_rota_empresa   ON rota(empresa_id);
CREATE INDEX idx_rota_origem    ON rota(origem_id);
CREATE INDEX idx_rota_destino   ON rota(destino_id);

-- Paradas da rota
CREATE TABLE rota_parada (
  rota_id INTEGER NOT NULL,
  parada_id INTEGER NOT NULL,
  ordem INTEGER NOT NULL,
  tempo_prev_min INTEGER NOT NULL,
  PRIMARY KEY (rota_id, ordem),
  UNIQUE (rota_id, parada_id),
  FOREIGN KEY (rota_id) REFERENCES rota(id),
  FOREIGN KEY (parada_id) REFERENCES parada(id)
);

-- Ônibus
CREATE TABLE onibus (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  empresa_id INTEGER NOT NULL,
  placa TEXT NOT NULL UNIQUE,
  modelo TEXT,
  ano INTEGER,
  capacidade INTEGER NOT NULL,
  ativo INTEGER DEFAULT 1,
  criado_em TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (empresa_id) REFERENCES empresa(id)
);

-- Viagens
CREATE TABLE viagem (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  onibus_id INTEGER NOT NULL,
  rota_id INTEGER NOT NULL,
  partida TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  chegada_prev TEXT NOT NULL,
  chegada_real TEXT,
  status TEXT DEFAULT 'agendada',
  criado_em TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (onibus_id) REFERENCES onibus(id),
  FOREIGN KEY (rota_id) REFERENCES rota(id)
);

-- Índices adicionais
CREATE INDEX idx_viagem_data     ON viagem(partida);
CREATE INDEX idx_viagem_onibus   ON viagem(onibus_id);
CREATE INDEX idx_viagem_rota     ON viagem(rota_id);

---------------------------
-- População das tabelas --
---------------------------

-- Inserção de empresas
INSERT INTO empresa (nome, telefone, cnpj) VALUES
  ('TransBrasil', '61-4000-1234', '12.345.678/0001-01'),
  ('CidadeBus',   '61-4000-5678', '23.456.789/0001-02'),
  ('Expresso DF', '61-4000-9012', '34.567.890/0001-03');

-- Inserção de paradas
INSERT INTO parada (nome, latitude, longitude) VALUES
  ('Rodoviária do Plano Piloto', -15.793889, -47.882778),
  ('Esplanada',                  -15.798889, -47.864444),
  ('UNB',                        -15.765833, -47.870000),
  ('Asa Sul – 108',              -15.820278, -47.925833),
  ('Parque da Cidade',           -15.808611, -47.896111),
  ('Taguatinga Centro',          -15.832222, -48.058611),
  ('Ceilândia Norte',            -15.812222, -48.111389),
  ('Aeroporto JK',               -15.869722, -47.920833);

-- Inserção de rotas
INSERT INTO rota (codigo, empresa_id, origem_id, destino_id, distancia_km, expressa) VALUES
  ('100', 1, 1, 8, 14.5, 1),
  ('200', 2, 6, 1, 20.0, 0),
  ('300', 3, 7, 3, 26.0, 0);

-- Inserção de paradas nas rotas
INSERT INTO rota_parada (rota_id, parada_id, ordem, tempo_prev_min) VALUES
  (1, 1, 1, 0),
  (1, 2, 2, 5),
  (1, 8, 3, 25),
  (2, 6, 1, 0),
  (2, 5, 2, 15),
  (2, 4, 3, 25),
  (2, 1, 4, 35),
  (3, 7, 1, 0),
  (3, 6, 2, 10),
  (3, 5, 3, 22),
  (3, 3, 4, 35);

-- Inserção de ônibus
INSERT INTO onibus (empresa_id, placa, modelo, ano, capacidade) VALUES
  (1, 'ABC1D23', 'Volvo B8R',        2018, 48),
  (1, 'ABC2D34', 'Mercedes OF-1721', 2020, 46),
  (2, 'DEF3G45', 'Volks 17-230',     2019, 44),
  (3, 'GHI4J56', 'Scania K310',      2021, 50),
  (3, 'GHI5J67', 'Mercedes OF-1721', 2017, 46);

-- Inserção de viagens
INSERT INTO viagem (onibus_id, rota_id, partida, chegada_prev, status) VALUES
  (1, 1, '2025-04-24 07:00:00', '2025-04-24 07:25:00', 'agendada'),
  (2, 1, '2025-04-24 08:00:00', '2025-04-24 08:25:00', 'agendada'),
  (3, 2, '2025-04-24 06:30:00', '2025-04-24 07:05:00', 'agendada'),
  (4, 3, '2025-04-24 09:00:00', '2025-04-24 09:35:00', 'agendada');

--------------------------
-- Consultas para Testes--
--------------------------

-- Listar todas as rotas com suas empresas e pontos inicial/final
SELECT
  r.codigo AS codigo_rota,
  e.nome AS empresa,
  p_origem.nome AS origem,
  p_destino.nome AS destino,
  r.distancia_km,
  CASE r.expressa WHEN 1 THEN 'Sim' ELSE 'Não' END AS expressa
FROM rota r
JOIN empresa e       ON r.empresa_id = e.id
JOIN parada p_origem ON r.origem_id = p_origem.id
JOIN parada p_destino ON r.destino_id = p_destino.id;

-- Ver paradas ordenadas de uma rota específica (exemplo: rota 100)
SELECT
  r.codigo AS rota,
  rp.ordem,
  p.nome AS parada,
  rp.tempo_prev_min
FROM rota_parada rp
JOIN parada p ON rp.parada_id = p.id
JOIN rota r   ON rp.rota_id = r.id
WHERE r.codigo = '100'
ORDER BY rp.ordem;

-- Consultar viagens de hoje com detalhes de rota e empresa
SELECT
  v.id AS id_viagem,
  v.partida,
  v.chegada_prev,
  e.nome AS empresa,
  r.codigo AS rota,
  p_origem.nome AS origem,
  p_destino.nome AS destino,
  v.status
FROM viagem v
JOIN onibus o        ON v.onibus_id = o.id
JOIN empresa e       ON o.empresa_id = e.id
JOIN rota r          ON v.rota_id = r.id
JOIN parada p_origem ON r.origem_id = p_origem.id
JOIN parada p_destino ON r.destino_id = p_destino.id
WHERE DATE(v.partida) = DATE('now')
ORDER BY v.partida;

-- Ver total de viagens por empresa
SELECT
  e.nome AS empresa,
  COUNT(*) AS total_viagens
FROM viagem v
JOIN onibus o  ON v.onibus_id = o.id
JOIN empresa e ON o.empresa_id = e.id
GROUP BY e.nome
ORDER BY total_viagens DESC;

-- Ver todos os ônibus de uma empresa específica (exemplo: TransBrasil)
SELECT
  o.placa,
  o.modelo,
  o.ano,
  o.capacidade,
  CASE o.ativo WHEN 1 THEN 'Ativo' ELSE 'Inativo' END AS status
FROM onibus o
JOIN empresa e ON o.empresa_id = e.id
WHERE e.nome = 'TransBrasil';

