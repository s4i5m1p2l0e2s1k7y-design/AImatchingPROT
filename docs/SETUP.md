# GitHub リポジトリ セットアップ手順

## 1. GitHubでリポジトリを作成

1. https://github.com/new にアクセス
2. Repository name: `ma-matching`（任意）
3. Private を選択
4. "Add a README file" は **チェックしない**（ローカルに既にある）
5. "Create repository" をクリック

## 2. ローカルで初期化＆プッシュ

コマンドプロンプト or PowerShell で以下を実行：

```powershell
# workspace フォルダに移動
cd C:\Users\User\Documents\Tech0\AIマッチングdraft\workspace

# ダウンロードしたファイル群をここに配置済みの前提で：

# Git 初期化
git init

# 全ファイルを追加
git add .

# 初回コミット
git commit -m "feat: プロジェクト初期セットアップ（フォルダ構成・マスタデータ・Notebook雛形）"

# リモートを追加（自分のリポジトリURLに変更）
git remote add origin https://github.com/<your-username>/ma-matching.git

# プッシュ
git branch -M main
git push -u origin main
```

## 3. 仮想環境のセットアップ

```powershell
# venv を作成
python -m venv .venv

# 有効化（PowerShell）
.venv\Scripts\Activate.ps1

# パッケージインストール
pip install -r requirements.txt
```

## 4. 環境変数の設定

```powershell
# .env ファイルを作成
copy .env.example .env

# .env を編集して ANTHROPIC_API_KEY を設定
```

## 5. 作業開始

```powershell
# Jupyter Notebook を起動
jupyter notebook notebooks/
```

`01_master_data.ipynb` から順番に進めていきます。
