-- ============================================================
-- M&A AI マッチングシステム - データベース作成スクリプト
-- MySQL Workbench で実行してください
-- ============================================================

-- 1. データベース作成
CREATE DATABASE IF NOT EXISTS ma_matching
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE ma_matching;

-- ============================================================
-- 2. マスタテーブル
-- ============================================================

-- 業種マスタ
CREATE TABLE IF NOT EXISTS m_industry (
  industry_code VARCHAR(10) PRIMARY KEY,
  industry_name VARCHAR(100) NOT NULL,
  target_count INT NOT NULL,
  ratio DECIMAL(4,2) NOT NULL
) ENGINE=InnoDB;

-- サブ業種マスタ
CREATE TABLE IF NOT EXISTS m_sub_industry (
  id INT AUTO_INCREMENT PRIMARY KEY,
  industry_code VARCHAR(10) NOT NULL,
  sub_industry_name VARCHAR(100) NOT NULL,
  FOREIGN KEY (industry_code) REFERENCES m_industry(industry_code)
) ENGINE=InnoDB;

-- 地域マスタ
CREATE TABLE IF NOT EXISTS m_region (
  prefecture_code VARCHAR(4) PRIMARY KEY,
  prefecture_name VARCHAR(20) NOT NULL,
  area_name VARCHAR(20) NOT NULL,
  area_weight DECIMAL(4,2) NOT NULL
) ENGINE=InnoDB;

-- 譲渡理由マスタ
CREATE TABLE IF NOT EXISTS m_transfer_reason (
  reason_code VARCHAR(10) PRIMARY KEY,
  reason_name VARCHAR(100) NOT NULL,
  target_count INT NOT NULL,
  ratio DECIMAL(4,2) NOT NULL
) ENGINE=InnoDB;

-- 買収目的マスタ
CREATE TABLE IF NOT EXISTS m_acquisition_purpose (
  purpose_code VARCHAR(10) PRIMARY KEY,
  purpose_name VARCHAR(100) NOT NULL,
  target_count INT NOT NULL,
  ratio DECIMAL(4,2) NOT NULL
) ENGINE=InnoDB;

-- 売上規模帯マスタ
CREATE TABLE IF NOT EXISTS m_revenue_band (
  id INT AUTO_INCREMENT PRIMARY KEY,
  label VARCHAR(50) NOT NULL,
  min_value DECIMAL(12,2) NOT NULL,
  max_value DECIMAL(12,2) NOT NULL,
  target_count INT NOT NULL,
  ratio DECIMAL(4,2) NOT NULL
) ENGINE=InnoDB;

-- ============================================================
-- 3. 売り手企業テーブル（2,000社）
-- ============================================================

CREATE TABLE IF NOT EXISTS sellers (
  seller_id VARCHAR(10) PRIMARY KEY COMMENT '一意のID（S-0001〜S-2000）',
  company_name VARCHAR(200) NOT NULL UNIQUE COMMENT '架空の企業名',
  industry_code VARCHAR(10) NOT NULL COMMENT '業種コード',
  industry_name VARCHAR(100) NOT NULL COMMENT '業種名称',
  sub_industry VARCHAR(100) DEFAULT NULL COMMENT 'サブ業種',
  prefecture VARCHAR(20) NOT NULL COMMENT '本社所在地（都道府県）',
  city VARCHAR(50) DEFAULT NULL COMMENT '市区町村',
  established_year INT NOT NULL COMMENT '設立年（1950〜2020）',
  employee_count INT NOT NULL COMMENT '従業員数（1〜5000）',
  revenue_latest DECIMAL(12,2) NOT NULL COMMENT '直近期売上高（百万円）',
  revenue_2y_ago DECIMAL(12,2) DEFAULT NULL COMMENT '2期前売上高（百万円）',
  revenue_3y_ago DECIMAL(12,2) DEFAULT NULL COMMENT '3期前売上高（百万円）',
  operating_profit DECIMAL(12,2) DEFAULT NULL COMMENT '直近期営業利益（百万円）',
  net_assets DECIMAL(12,2) DEFAULT NULL COMMENT '純資産（百万円）',
  business_description TEXT NOT NULL COMMENT '事業内容（100〜500文字）',
  key_strengths TEXT NOT NULL COMMENT '強み・特徴（50〜300文字）',
  customer_base VARCHAR(20) DEFAULT NULL COMMENT '主要顧客層（BtoB/BtoC/両方）',
  transfer_reason_code VARCHAR(10) NOT NULL COMMENT '譲渡理由コード',
  transfer_reason_text TEXT NOT NULL COMMENT '譲渡理由の説明',
  desired_scheme VARCHAR(30) NOT NULL COMMENT '希望スキーム',
  desired_price_min DECIMAL(12,2) DEFAULT NULL COMMENT '希望譲渡価格の下限（百万円）',
  desired_price_max DECIMAL(12,2) DEFAULT NULL COMMENT '希望譲渡価格の上限（百万円）',
  desired_timeline VARCHAR(30) NOT NULL COMMENT '希望時期',
  must_conditions TEXT DEFAULT NULL COMMENT '譲れない条件',
  owner_age INT DEFAULT NULL COMMENT 'オーナー年齢（40〜80）',
  key_licenses TEXT DEFAULT NULL COMMENT '保有許認可',
  embedding_text TEXT COMMENT 'Bi-Encoder用テキスト（自動生成）',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  FOREIGN KEY (industry_code) REFERENCES m_industry(industry_code),
  FOREIGN KEY (transfer_reason_code) REFERENCES m_transfer_reason(reason_code),

  INDEX idx_sellers_industry (industry_code),
  INDEX idx_sellers_prefecture (prefecture),
  INDEX idx_sellers_revenue (revenue_latest),
  INDEX idx_sellers_reason (transfer_reason_code)
) ENGINE=InnoDB;

-- ============================================================
-- 4. 買い手候補テーブル（10,000件）
-- ============================================================

CREATE TABLE IF NOT EXISTS buyers (
  buyer_id VARCHAR(10) PRIMARY KEY COMMENT '一意のID（B-00001〜B-10000）',
  company_name VARCHAR(200) NOT NULL COMMENT '架空の企業名',
  buyer_type VARCHAR(30) NOT NULL COMMENT '事業会社/PE・ファンド/個人',
  industry_code VARCHAR(10) NOT NULL COMMENT '買い手自身の業種コード',
  revenue DECIMAL(12,2) DEFAULT NULL COMMENT '買い手の売上高（百万円）',
  acquisition_purpose_code VARCHAR(10) NOT NULL COMMENT '買収目的コード',
  target_industries JSON NOT NULL COMMENT '対象業種コードリスト',
  target_regions JSON DEFAULT NULL COMMENT '対象地域リスト',
  budget_min DECIMAL(12,2) DEFAULT NULL COMMENT '予算下限（百万円）',
  budget_max DECIMAL(12,2) NOT NULL COMMENT '予算上限（百万円）',
  preferred_scheme VARCHAR(30) DEFAULT NULL COMMENT '希望スキーム',
  preferred_timeline VARCHAR(30) DEFAULT NULL COMMENT '希望時期',
  must_conditions TEXT NOT NULL COMMENT '譲れない条件',
  nice_to_have TEXT DEFAULT NULL COMMENT 'あれば望ましい条件',
  deal_experience VARCHAR(20) DEFAULT NULL COMMENT 'M&A実績',
  description TEXT NOT NULL COMMENT '買収ニーズの詳細（100〜500文字）',
  embedding_text TEXT COMMENT 'Bi-Encoder用テキスト（自動生成）',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  FOREIGN KEY (industry_code) REFERENCES m_industry(industry_code),
  FOREIGN KEY (acquisition_purpose_code) REFERENCES m_acquisition_purpose(purpose_code),

  INDEX idx_buyers_industry (industry_code),
  INDEX idx_buyers_purpose (acquisition_purpose_code),
  INDEX idx_buyers_budget (budget_max),
  INDEX idx_buyers_type (buyer_type)
) ENGINE=InnoDB;

-- ============================================================
-- 5. 正解データ（Ground Truth）テーブル
-- ============================================================

CREATE TABLE IF NOT EXISTS ground_truth (
  id INT AUTO_INCREMENT PRIMARY KEY,
  seller_id VARCHAR(10) NOT NULL,
  buyer_id VARCHAR(10) NOT NULL,
  pair_type ENUM('A','B','C','D') NOT NULL COMMENT 'A:明確マッチ B:条件付き C:境界 D:ミスマッチ',

  -- 5軸スコア（各1〜5）
  score_synergy INT NOT NULL COMMENT '事業シナジー',
  score_financial INT NOT NULL COMMENT '財務整合性',
  score_conditions INT NOT NULL COMMENT '条件適合性',
  score_feasibility INT NOT NULL COMMENT '実行可能性',
  score_culture INT NOT NULL COMMENT '文化的適合性',
  score_total DECIMAL(3,1) GENERATED ALWAYS AS (
    (score_synergy + score_financial + score_conditions + score_feasibility + score_culture) / 5.0
  ) STORED COMMENT '総合スコア（自動計算）',

  match_reason TEXT NOT NULL COMMENT 'マッチ/ミスマッチの根拠',
  expected_rank_min INT DEFAULT NULL COMMENT 'Stage 3後の期待順位（下限）',
  expected_rank_max INT DEFAULT NULL COMMENT 'Stage 3後の期待順位（上限）',

  -- Stage通過の期待値
  stage1_expected ENUM('pass','partial','fail') NOT NULL COMMENT 'Stage 1通過想定',
  stage2_expected ENUM('pass','partial','fail') NOT NULL COMMENT 'Stage 2通過想定',
  stage3_expected ENUM('top','appear','rare','none') NOT NULL COMMENT 'Stage 3出現想定',

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (seller_id) REFERENCES sellers(seller_id),
  FOREIGN KEY (buyer_id) REFERENCES buyers(buyer_id),
  UNIQUE INDEX idx_gt_pair (seller_id, buyer_id),
  INDEX idx_gt_type (pair_type)
) ENGINE=InnoDB;

-- ============================================================
-- 6. パイプライン結果テーブル（評価用）
-- ============================================================

-- Stage 1 結果
CREATE TABLE IF NOT EXISTS stage1_results (
  id INT AUTO_INCREMENT PRIMARY KEY,
  seller_id VARCHAR(10) NOT NULL,
  buyer_id VARCHAR(10) NOT NULL,
  cosine_similarity DECIMAL(6,4) NOT NULL,
  rank_position INT NOT NULL COMMENT '売り手ごとの順位',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (seller_id) REFERENCES sellers(seller_id),
  FOREIGN KEY (buyer_id) REFERENCES buyers(buyer_id),
  INDEX idx_s1_seller (seller_id),
  INDEX idx_s1_score (cosine_similarity DESC)
) ENGINE=InnoDB;

-- Stage 2 結果
CREATE TABLE IF NOT EXISTS stage2_results (
  id INT AUTO_INCREMENT PRIMARY KEY,
  seller_id VARCHAR(10) NOT NULL,
  buyer_id VARCHAR(10) NOT NULL,
  cross_encoder_score DECIMAL(8,4) NOT NULL,
  rank_position INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (seller_id) REFERENCES sellers(seller_id),
  FOREIGN KEY (buyer_id) REFERENCES buyers(buyer_id),
  INDEX idx_s2_score (cross_encoder_score DESC)
) ENGINE=InnoDB;

-- Stage 3 結果（LLMマルチエージェント）
CREATE TABLE IF NOT EXISTS stage3_results (
  id INT AUTO_INCREMENT PRIMARY KEY,
  seller_id VARCHAR(10) NOT NULL,
  buyer_id VARCHAR(10) NOT NULL,

  -- 各エージェントのスコア
  synergy_score INT DEFAULT NULL,
  synergy_reason TEXT DEFAULT NULL,
  financial_score INT DEFAULT NULL,
  financial_reason TEXT DEFAULT NULL,
  risk_score INT DEFAULT NULL,
  risk_reason TEXT DEFAULT NULL,
  culture_score INT DEFAULT NULL,
  culture_reason TEXT DEFAULT NULL,

  -- 統括エージェントの最終判定
  final_score DECIMAL(3,1) DEFAULT NULL,
  final_grade ENUM('A','B','C','D') DEFAULT NULL,
  final_reason TEXT DEFAULT NULL,
  debate_required BOOLEAN DEFAULT FALSE COMMENT 'ディベートが発生したか',
  rank_position INT DEFAULT NULL,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (seller_id) REFERENCES sellers(seller_id),
  FOREIGN KEY (buyer_id) REFERENCES buyers(buyer_id),
  INDEX idx_s3_grade (final_grade),
  INDEX idx_s3_rank (rank_position)
) ENGINE=InnoDB;

-- 提案資料テーブル
CREATE TABLE IF NOT EXISTS proposals (
  id INT AUTO_INCREMENT PRIMARY KEY,
  seller_id VARCHAR(10) NOT NULL,
  buyer_id VARCHAR(10) NOT NULL,
  executive_summary TEXT NOT NULL,
  buyer_overview TEXT NOT NULL,
  synergy_analysis TEXT NOT NULL,
  financial_alignment TEXT NOT NULL,
  risks_and_mitigation TEXT NOT NULL,
  cultural_fit TEXT NOT NULL,
  recommended_actions TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (seller_id) REFERENCES sellers(seller_id),
  FOREIGN KEY (buyer_id) REFERENCES buyers(buyer_id)
) ENGINE=InnoDB;

-- ============================================================
-- 7. 確認
-- ============================================================

SELECT
  TABLE_NAME,
  TABLE_ROWS,
  TABLE_COMMENT
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'ma_matching'
ORDER BY TABLE_NAME;
