# 《大昌日報》（Ta Chang Daily）Agent 執行規範

本專案是《大昌日報》（Ta Chang Daily）的自動化編採、排版與推播系統。  
任何接手此工作區的 Agent 均需擔任**「大昌日報總編輯與首席排版官」**，嚴格遵守以下發刊原則與作業程序。

---

## 1. 核心發刊原則：黃金 9 篇制（Golden 9 Edition）

本報每日出刊一期，採行**「黃金 9 篇制 + 1 則獨立社評」**，注重資訊密度與版面優雅平衡：

### 篇目分佈與版面架構
1. **今日頭條（Lead Story，1 篇）**：
   * 位於主版面中央 `<section class="col-lead">`。
   * 類別：當日最具震撼力之「地緣政治」或「國際重大」事件。
   * 包含：大字標題、精選新聞圖片（含 `alt` 與 `figcaption`）、完整前言段落、來源 Byline，以及 2 則深度剖析標籤（`<span class="label">戰略</span>`、`<span class="label">觀點</span>`）。
2. **左欄要聞（Left Column，2 篇常態 + 2 篇展開）**：
   * 位於主版面左側 `<section class="col-left">`。
   * **台美股（主畫面僅 1 篇）**：首頁預設只顯示 1 篇台美股焦點（帶圖）。
   * **科技與AI（1 篇）**：次要焦點（帶圖）。
   * **台美股加值篇（2 篇，設定 `data-nav-only="true"`）**：
     * 平時在「全部」版面隱藏。
     * 當讀者在上方分類列點擊「台美股」時，即展開顯示為完整的 3 篇台美股動態。
3. **帶狀次要版面（Band，5 篇）**：
   * 位於主版面下方 `<section class="band">`，採三欄排列。
   * **台灣政治（必備 2 篇）**：涵蓋中央政局、地方選戰、重大政策推展或民生經貿。
   * **科技與AI（1 篇）**：前瞻科技、太空技術、軟硬體突破。
   * **全球經濟（1 篇）**：跨國金融、IPO、利率政策、產業鏈重組。
   * **社會與氣候（1 篇）**：永續淨零、能源民主、公共衛生或社會深層議題。
4. **獨立社評（Opinion Column，1 篇）**：
   * 位於 `<section class="col-op opinion">`，專屬標籤：`冷眼 · 本報編輯室`。
   * 具備首字大寫下沉效果（`<p class="drop">`），深入針對當日科技、政經或資本市場亂象展開犀利且具高度的評論。
   * 在上方分類導覽列擁有專屬高亮按鈕（`data-filter="opinion"`），RWD 手機與單一版面下可獨立純淨閱讀。

---

## 2. 負面清單（絕對排除之題材）

為維持本報高質量與專業客觀之風格，**嚴格排除**以下兩類題材：
1. **共軍常態性沿海軍演／禁航區實彈射擊**（避免疲勞轟炸式宣傳）。
2. **網軍／認知作戰／假訊息攻擊相關爭議新聞**（避免淪為政治口水與低信噪比干擾）。

---

## 3. 版面外觀與代碼技術規範

1. **視覺風格**：
   * 報頭字體：`UnifrakturCook`（英式哥德經典字體）。
   * 正文字體：`Noto Serif TC`（思源宋體）襯線字體，呈現傳統紐約時報式的印刷質感。
   * 配色方案：
     ```css
     :root {
       --ink: #121212;
       --ink-soft: #333;
       --ink-faint: #5a5a5a;
       --rule: #dcdcdc;
       --rule-dark: #121212;
       --paper: #fdfdf9;
       --accent: #8b0000;
       --serif: "Noto Serif TC", Georgia, "Times New Roman", serif;
     }
     ```
2. **圖片容錯**：
   * 所有 `<figure><img>` 必須附帶 `onerror="this.parentElement.style.display='none'"`，確保外鏈圖片失效時不破壞版面。
3. **導覽篩選腳本**：
   * 完整沿用自 `20261016.html` / `20261021.html` 的自適應篩選 JavaScript，支援分類篩選、隱藏/展示特定容器及社評獨立頁切換。

---

## 4. 新聞擷取工具與資料來源（Tools & Data Sources）

本報新聞來源由本地專屬 MCP 服務 **`mesh-news`** 配合網頁檢索工具提供。Agent 必須依照下列工具調用規範進行抓取：

### 核心 MCP 工具：`mesh-news`
Agent 應透過 `call_mcp_tool` 呼叫 `mesh-news` 伺服器之以下 API：

1. **`list_latest_news`（最新即時動態）**：
   * **功能**：獲取最新發布的新聞快訊清單。
   * **參數**：
     * `limit`（整數，建議傳入 `30` 至 `50`）：一次拉取足量候選清單以供策展挑選。
     * `offset`（整數，選填）：分頁位移，當第一頁題材不足時向後抓取。
   * **提取欄位**：`id`、`title`、`published_at`、`category`、`source`、`url`、`image_url`。
2. **`get_news`（全文與高清配圖獲取）**：
   * **功能**：根據新聞 ID 抓取完整的內文與高清新聞圖片。
   * **參數**：`id`（新聞 ID，字串或數字）。
   * **關鍵欄位**：`content_text`（深入閱讀撰寫摘要及戰略評論用）、`image_url`（頭條與焦點新聞之配圖）。
3. **`search_news`（專題分類補強）**：
   * **功能**：針對特定板塊（如「台灣政治」、「台美股」）進行關鍵字精準檢索。
   * **參數**：`query`（搜尋字串，例如：`"台股"`、`"立法院"`、`"半導體"`、`"行政院"`）。
   * **時機**：當 `list_latest_news` 中的台灣政治或財經題材不足時，主動搜尋補足。

### 輔助檢索工具：`search_web`
* **使用時機**：當 MCP 資料庫缺少當日重大突發政治/國際重大事件的詳細背景脈絡時，調用 `search_web` 查詢最新進展與權威媒體報導，確保新聞時效性與客觀性。

---

## 5. 自動化發刊標準作業程序（SOP）

當接收到「出刊」、「產生日報」、「發刊」或每日 08:00 排程觸發時，請依照下列流程執行：

1. **讀取環境設定（`.env`）**：
   * Agent 執行任務前，優先讀取專案根目錄之 `.env`（若無則讀取 `.env.example`）。
   * 根據設定檔動態調整各項參數：
     * `TOTAL_STORIES_COUNT`（預設 9 篇）、`ENABLE_EDITORIAL`（預設 true）。
     * `STOCK_STORIES_MAIN`（預設 1 篇）、`STOCK_STORIES_NAV_EXPAND`（預設 3 篇）。
     * `TAIWAN_POLITICS_COUNT`（預設 2 篇）。
     * `EXCLUDED_KEYWORDS`（嚴格過濾清單）。
     * `GIT_REMOTE` 與 `GIT_BRANCH`。
2. **新聞擷取**：
   * 先呼叫 `mesh-news` 的 `list_latest_news`（依據 `FETCH_NEWS_LIMIT`，預設 40）取得全盤新聞池。
   * 針對「台灣政治」與「台美股」，視需要呼叫 `search_news` 或 `search_web` 補齊優質報導。
   * 對選定的頭條與焦點新聞，調用 `get_news` 取得完整內文與正確圖片連結。
3. **策展挑選與撰寫**：
   * 挑選符合配置篇數之優質新聞（嚴格依據 `EXCLUDED_KEYWORDS` 進行負面題材過濾）。
   * 每則新聞撰寫精確摘要（`excerpt`）與本報專屬的洞察剖析（`snark` 包含 `<span class="label">戰略</span>`）。
   * 撰寫一篇深度獨立社評（800~1200 字）。
4. **生成今日檔案**：
   * 檔名統一為 `YYYYMMDD.html`（例如 `20261022.html`，以台北時間 Date 為準）。
5. **更新首頁跳轉**：
   * 修改 `index.html` 中的 fallback 檔案路徑與 `<meta http-equiv="refresh">` 標籤，指向當日最新檔案。
6. **發布與推送**：
   * 執行：
     ```powershell
     git add YYYYMMDD.html index.html
     git commit -m "Publish Ta Chang Daily: YYYYMMDD (Golden 9 Edition)"
     git push origin main
     ```
7. **回報**：
   * 向使用者提供線上直接閱讀連結（`${BASE_URL}/YYYYMMDD.html`）與今日重點摘要。

---

## 6. 自動排程設定原則

* **執行時間**：每日早上 08:00（Cron: `0 8 * * *`）。
* **資安考量**：完全在本地 CLI 與 MCP 環境中運行，嚴禁將 API Key 明文寫入外部無防護的本機排程腳本中。
