#!/usr/bin/env bash
# ==============================================================
# 《大昌日報》隨機延遲自動推播腳本（Auto Push with Random Delay）
# ==============================================================

set -euo pipefail

# 設定專案目錄
REPO_DIR="/mnt/d/news"
cd "$REPO_DIR"

# 1. 隨機延遲設定（預設在 3 分鐘至 18 分鐘之間隨機浮動）
# MIN_WAIT: 最小等待秒數（180 秒 = 3 分鐘）
# MAX_RANDOM: 隨機增加秒數範圍（0 ~ 900 秒 = 0 ~ 15 分鐘）
MIN_WAIT=180
MAX_RANDOM=900
DELAY=$(( MIN_WAIT + (RANDOM % MAX_RANDOM) ))
DELAY_MIN=$(awk "BEGIN {printf \"%.1f\", $DELAY/60}")

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 觸發自動推播，預計隨機延遲 ${DELAY} 秒（約 ${DELAY_MIN} 分鐘）後執行..." >> "${REPO_DIR}/auto_push.log"

# 等待隨機時間
sleep "$DELAY"

# 2. 檢查是否有未提交的新聞檔案變更
if git status --porcelain | grep -E '\.html' > /dev/null; then
    # 取得最新生成的日報檔案名稱以擷取日期（例如 20261030）
    LATEST_DATE=$(ls -1 [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].html 2>/dev/null | sort -r | head -n 1 | sed 's/\.html//')
    
    if [ -z "$LATEST_DATE" ]; then
        LATEST_DATE=$(date '+%Y%m%d')
    fi

    COMMIT_MSG="Publish Ta Chang Daily: ${LATEST_DATE} (Golden 9 Edition)"

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 偵測到刊物更新，開始推送：${COMMIT_MSG}" >> "${REPO_DIR}/auto_push.log"

    git add .
    git commit -m "$COMMIT_MSG"
    git push origin main >> "${REPO_DIR}/auto_push.log" 2>&1

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 推送完成！" >> "${REPO_DIR}/auto_push.log"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 無新檔案需要推送，略過。" >> "${REPO_DIR}/auto_push.log"
fi
