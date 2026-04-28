# Project Memory - fact

## プロジェクト概要
16歳〜25歳のZ世代をターゲットとした、音楽を媒介とした「感性の同期」を目的とするプラットフォーム。
Appleライクなミニマリズム、グラスモーフィズム、100%ユーザー投稿型を特徴とする。

## 現在の進捗
- [x] プロジェクト初期化 (Flutterデフォルト)
- [x] 要件定義書の読み込み
- [x] 基本設計・フォルダ構成の作成
- [x] デザインシステム（グラスモーフィズム、共通カラー）の実装
- [x] Apple Music API連携（モデル・サービス層）の実装
- [x] スワイプUI（タイムライン）の実装
- [x] Supabase Auth による認証基盤（Apple / Google）の実装

## 決定事項
- 技術スタック: Flutter
- 認証: Social Login (Apple / Google) のみ
- デザイン: グラスモーフィズム、アダプティブ背景
- 外部API: Apple Music API (音源・メタデータ), Apple Music/Spotify (プレイリスト同期)
- データベース/バックエンド: Supabase
- 状態管理: Riverpod
- HTTPクライアント: Dio

## 次のステップ
1. 実装計画の策定と承認
2. 基本的なフォルダ構成 of folder structure
3. グラスモーフィズムを基調としたデザインシステムの構築
