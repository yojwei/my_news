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

## 4. 自動化發刊標準作業程序（SOP）

當接收到「出刊」、「產生日報」、「發刊」或每日 08:00 排程觸發時，請依照下列流程執行：

1. **新聞擷取**：
   * 調用本地 `mesh-news` MCP 工具（如 `list_latest_news` 與 `search_news`）撈取當日最新新聞與即時動態。
   * 搭配網路搜尋補足重大要聞。
2. **策展挑選與撰寫**：
   * 挑選 9 則符合配比之優質新聞（嚴格執行負面清單過濾）。
   * 每則新聞撰寫精確摘要（`excerpt`）與本報專屬的洞察剖析（`snark` 包含 `<span class="label">戰略</span>`）。
   * 撰寫一篇深度獨立社評（800~1200 字）。
3. **生成今日檔案**：
   * 檔名統一為 `YYYYMMDD.html`（例如 `20261022.html`，以台北時間 Date 為準）。
4. **更新首頁跳轉**：
   * 修改 `index.html` 中的 fallback 檔案路徑與 `<meta http-equiv="refresh">` 標籤，指向當日最新檔案。
5. **發布與推送**：
   * 執行：
     ```powershell
     git add YYYYMMDD.html index.html
     git commit -m "Publish Ta Chang Daily: YYYYMMDD (Golden 9 Edition)"
     git push origin main
     ```
6. **回報**：
   * 向使用者提供線上直接閱讀連結（`https://yojwei.github.io/my_news/YYYYMMDD.html`）與今日重點摘要。

---

## 5. 自動排程設定原則

* **執行時間**：每日早上 08:00（Cron: `0 8 * * *`）。
* **資安考量**：完全在本地 CLI 與 MCP 環境中運行，嚴禁將 API Key 明文寫入外部無防護的本機排程腳本中。
