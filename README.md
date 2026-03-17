# M&A AI マッチングシステム

3段階スクリーニング（Bi-Encoder → Cross-Encoder → LLM マルチエージェント）により、  
売り手 2,000社 × 買い手 10,000件 = **2,000万件**の組み合わせから最適なマッチングを抽出するプロトタイプ。

## アーキテクチャ

```
20,000,000 件 ──▶ [Stage 1: Bi-Encoder]  ──▶ ~10,000 件
                         cos類似度で高速絞り込み

 ~10,000 件  ──▶ [Stage 2: Cross-Encoder] ──▶ ~100 件
                         ペア単位で精密スコアリング

    ~100 件  ──▶ [Stage 3: LLM Multi-Agent] ──▶ Top 3 + 提案資料
                         5エージェントによる多角評価・議論
```

## フォルダ構成

```
ma-matching/
├── README.md
├── .gitignore
├── requirements.txt
├── configs/
│   └── config.yaml          # パイプライン設定
├── data/
│   ├── master/              # マスタデータ（業種・地域等）
│   │   ├── industry_master.json
│   │   └── region_master.json
│   ├── generated/           # 生成済みテストデータ
│   │   ├── sellers.jsonl
│   │   └── buyers.jsonl
│   └── ground_truth/        # 正解データ
│       └── ground_truth.jsonl
├── docs/                    # 仕様書・設計ドキュメント
│   └── test_data_spec.md
├── notebooks/               # Jupyter Notebooks
│   ├── 01_master_data.ipynb       # マスタデータ作成
│   ├── 02_seller_generation.ipynb # 売り手データ生成
│   ├── 03_buyer_generation.ipynb  # 買い手データ生成
│   ├── 04_ground_truth.ipynb      # 正解データ設計
│   ├── 05_validation.ipynb        # データ品質検証
│   ├── 06_stage1_biencoder.ipynb  # Stage 1 実装
│   ├── 07_stage2_crossencoder.ipynb # Stage 2 実装
│   └── 08_stage3_llm_agents.ipynb # Stage 3 実装
├── src/
│   ├── pipeline/            # パイプライン処理
│   │   ├── __init__.py
│   │   ├── stage1_biencoder.py
│   │   ├── stage2_crossencoder.py
│   │   └── stage3_llm.py
│   ├── agents/              # マルチエージェント
│   │   ├── __init__.py
│   │   ├── synergy_agent.py       # 事業シナジー分析官
│   │   ├── financial_agent.py     # 財務分析官
│   │   ├── risk_agent.py          # リスク評価官
│   │   ├── culture_agent.py       # 文化適合性評価官
│   │   └── moderator_agent.py     # 統括エージェント
│   └── utils/               # ユーティリティ
│       ├── __init__.py
│       ├── data_loader.py
│       └── validators.py
├── tests/                   # テスト
│   └── test_validators.py
└── outputs/
    └── proposals/           # 生成された提案資料
```

## クイックスタート

```bash
# 1. リポジトリをクローン
git clone https://github.com/<your-username>/ma-matching.git
cd ma-matching

# 2. 仮想環境をセットアップ
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate

# 3. 依存パッケージをインストール
pip install -r requirements.txt

# 4. Jupyter を起動
jupyter notebook notebooks/
```

## 作業の進め方

| Step | Notebook | 内容 |
|------|----------|------|
| 1 | `01_master_data.ipynb` | 業種・地域マスタの作成 |
| 2 | `02_seller_generation.ipynb` | 売り手 2,000社のテストデータ生成 |
| 3 | `03_buyer_generation.ipynb` | 買い手 10,000件のテストデータ生成 |
| 4 | `04_ground_truth.ipynb` | 正解ペア 500件の設計・アノテーション |
| 5 | `05_validation.ipynb` | データ品質チェック（分布・整合性） |
| 6 | `06_stage1_biencoder.ipynb` | Bi-Encoder による一次スクリーニング |
| 7 | `07_stage2_crossencoder.ipynb` | Cross-Encoder による二次スクリーニング |
| 8 | `08_stage3_llm_agents.ipynb` | LLM マルチエージェントによる最終評価 |

## 設計思想

本プロジェクトは「AIツールを成功させる3つの条件」に基づいて設計：

1. **業務への組み込み** — 提案資料の自動生成まで行い、営業フローに直結
2. **データの質** — 構造化データ + 品質基準の明確化で GIGO を防止
3. **学習する設計** — 正解データと LLMOps サイクルで継続的に改善

## ライセンス

Private — 社内利用限定
